#include "meanshifttracker.h"
#include <iostream>

MeanShiftTracker::MeanShiftTracker(const cv::Mat& firstFrame, int cx, int cy, int width, int height)
{    
    center_ = cv::Point2i(cx, cy);
    box_ = makeRect(firstFrame, cx, cy, width, height);

    //TODO:
    //create target model using model(...)
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
    //TODO:
    //Compute a weighted color histogram for the given ROI
    //Therefore you have to quantize the color values to
    //QUANT values and weight it using the epanechnikovProfile(...)
    //Don't forget to normalize the histogram.

    return hist;
}

double MeanShiftTracker::rho(const cv::Mat& p, const cv::Mat& q)
{
    double rho = 0;

    //TODO
    //Compute rho

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
    //TODO
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



    //draw rect on tracked object
    cv::rectangle(frame, box_, cv::Scalar(255, 0, 0), 3, CV_AA);
}
