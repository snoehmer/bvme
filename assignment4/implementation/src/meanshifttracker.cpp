#include "meanshifttracker.h"
#include <iostream>

MeanShiftTracker::MeanShiftTracker(const cv::Mat& firstFrame, int cx, int cy, int width, int height)
{    
    center_ = cv::Point2i(cx, cy);
    box_ = makeRect(firstFrame, cx, cy, width, height);

    //TODO: done
    //create target model using model(...)
    cv::Mat targetROI = firstFrame(box_);
    targetModel_ = model(targetROI);
}

double MeanShiftTracker::epanechnikovProfile(double x)
{
    if(x < 1.0)
        return (3./4.) * (1 - x);
    else
        return 0;
}

cv::Mat MeanShiftTracker::model(const cv::Mat& roi)
{

    double h = roi.rows * roi.cols;
    double cx = roi.cols / 2;
    double cy = roi.rows / 2;

    cv::Mat hist = cv::Mat_<double>::zeros(1, QUANT*QUANT*QUANT);
    //TODO: done?
    //Compute a weighted color histogram for the given ROI
    //Therefore you have to quantize the color values to
    //QUANT values and weight it using the epanechnikovProfile(...)
    //Don't forget to normalize the histogram.

    unsigned int hist_index;
    cv::Vec3b pixel;
    double dist2;

    // calculate histogram for the whole ROI
    for(int row = 0; row < roi.rows; row++)
    {
    	for(int col = 0; col < roi.cols; col++)
    	{
    		// get current BGR pixel
    		pixel = roi.at<cv::Vec3b>(row, col);

    		// calculate position in quantized histogram (uchar = 256 values)
    		hist_index = (pixel[0] / QUANT) * 1 +
    					 (pixel[1] / QUANT) * QUANT +
    					 (pixel[2] / QUANT) * QUANT * QUANT;

    		// calculate squared pixel distance for kernel
    		// TODO: h2?
    		dist2 = ((row - cy) * (row - cy) + (col - cx) * (col - cx)) / (h * h);

    		// add kernel value (weight) to histogram
    		hist.at<double>(0, hist_index) += epanechnikovProfile(dist2);
    	}
    }

    // normalize histogram
    double histSum = cv::sum(hist)[0];
    cv::divide(histSum, hist, hist);

    return hist;
}

double MeanShiftTracker::rho(const cv::Mat& p, const cv::Mat& q)
{
    double rho = 0;

    //TODO: done
    //Compute rho
    if(p.cols != QUANT * QUANT * QUANT || q.cols != QUANT * QUANT * QUANT)
    {
    	std::cerr << "[ERROR] rho: model dimension mismatch!" << std::endl;
    	return 0.;
    }

    for(unsigned int i = 0; i < QUANT * QUANT * QUANT; i++)
    {
    	rho += sqrt(p.at<double>(0,i) * q.at<double>(0,i));
    }

    return rho;
}

cv::Rect MeanShiftTracker::makeRect(const cv::Mat& frame, int cx, int cy, int width, int height)
{
    int x = cx-width/2;
    x = x < 0 ? 0 : x;
    if(x+width >= frame.cols) x = frame.cols - width - 1;

    int y = cy-height/2;
    y = y < 0 ? 0 : y;
    if(y+height >= frame.rows) y = frame.rows - height - 1;

    return cv::Rect(x, y, width, height);
}

void MeanShiftTracker::track(cv::Mat& frame, int maxiter)
{
    //TODO: done?
    //Implement the mean shift tracking algorithm by
    //Comaniciu et al. by Bhattacharyya coefficient maximization
    //Steps are:
    //(1) init target model and evaluate rho(p(y_0), q)
    //(2) compute the weights
    //(3) based on the mean shift vector, derive the new location
    //    of the target
    //(4) update y_1 while rho(p(y_1), q) < rho(p(y_0), q)
    //(5) check of the distance between two iteration is < eps
    //    if so, you can stop, else go to setp 1.

	cv::Point2i y0 = center_;
	cv::Point2i y1;
	cv::Mat p_y0;
	cv::Mat p_y1;
	double rho_y0;
	double rho_y1;

	cv::Rect y0_box = box_;
	cv::Rect y1_box;

	// get current ROI
	cv::Mat	y0_roi = frame(y0_box);
	cv::Mat y1_roi;

	cv::Mat weights = cv::Mat_<double>::zeros(1, QUANT*QUANT*QUANT);


	for(int cur_iter = 0; cur_iter < maxiter; cur_iter++)
	{
		// init target model
		p_y0 = model(y0_roi);
		rho_y0 = rho(p_y0, targetModel_);

		// compute weights and new target location
		double y1_row = 0;
		double y1_col = 0;
		double w_sum = 0;

		for(int row = 0; row < y0_box.height; row++)
		{
			for(int col = 0; col < y0_box.width; col++)
			{
				unsigned int hist_index;
				double q_u, p_y0_u;
				cv::Vec3b pixel;

				pixel = y0_roi.at<cv::Vec3b>(row, col);

				hist_index = (pixel[0] / QUANT) * 1 +
							 (pixel[1] / QUANT) * QUANT +
							 (pixel[2] / QUANT) * QUANT * QUANT;

				q_u = targetModel_.at<double>(0, hist_index);
				p_y0_u = p_y0.at<double>(0, hist_index);

				weights.at<double>(row,col) = sqrt(q_u / p_y0_u);

				w_sum += weights.at<double>(row,col);

				y1_row += row * weights.at<double>(row,col);
				y1_col += col * weights.at<double>(row,col);

			}
		}

		// compute new target location (divide by sum of weights)
		y1_row /= w_sum;
		y1_col /= w_sum;

		// calculate new center and bounding box
		y1.x = round(y1_col);
		y1.y = round(y1_row);

		y1_box = makeRect(frame, y1.x, y1.y, y0_box.width, y0_box.height);

		y1_roi = frame(y1_box);

		// calculate new y1 model
		p_y1 = model(y1_roi);
		rho_y1 = rho(p_y1, targetModel_);

		// update y1
		while(rho_y1 < rho_y0)
		{
			y1.x = round(0.5 * (y0.x + y1.x));
			y1.y = round(0.5 * (y0.y + y1.y));

			// update y1 stuff
			y1_box = makeRect(frame, y1.x, y1.y, y0_box.width, y0_box.height);
			y1_roi = frame(y1_box);

			p_y1 = model(y1_roi);
			rho_y1 = rho(p_y1, targetModel_);
		}

		// check distance to stop iteration (same pixel)
		if(y1 == y0)
		{
			// iteration finished
			break;
		}
		else
		{
			// new iteration with y0 <-- y1
			y0 = y1;

			y0_box = y1_box;
			y0_roi = frame(y0_box);
		}
	}


    //draw rect on tracked object
    cv::rectangle(frame, box_, cv::Scalar(255, 0, 0), 3, CV_AA);
}
