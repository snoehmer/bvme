#ifndef MEANSHIFTTRACKER_H
#define MEANSHIFTTRACKER_H

#include <opencv/cv.h>

class MeanShiftTracker
{
private:
    ///number of bins per color channel
    static const int QUANT = 16;

    ///the last center tracked
    cv::Point2i center_;
    ///the last bounding box tracked
    cv::Rect box_;
    ///target model - correspondends to q in Comaniciu et al.
    cv::Mat targetModel_;

    ///Epanechnikov profile
    ///@param x input of the profile
    ///@return k_E(x)
    double epanechnikovProfile(double x);

    ///Computes the model of the given region of interest
    ///The center is (roi.cols/2, roi.rows/2)
    ///@param roi the set of pixels for which the model should be calculated
    ///@return the model, which is a weighted color histogram
    cv::Mat model(const cv::Mat& roi);

    ///Calculates \rho[p, q] = \sum_{u=1}^n \sqrt{p_u * q_u}
    ///@param q the model p
    ///@param p the model q
    ///@return the evaluated \rho
    double rho(const cv::Mat& p, const cv::Mat& q);

    ///Helper method to create a cv::Rect centered at (cx, cy) with width and height.
    ///Note thate the Rect start coordinates differ from (cx, cy)
    ///@param frame frame to check image dimensions
    ///@param cx center of rect
    ///@param cy center of rect
    ///@param width width of rect
    ///@param height height of rect
    cv::Rect makeRect(const cv::Mat& frame, int cx, int cy, int width, int height);
public:

    ///Creates a new mean shift tracker, and inits the target model using the first frame
    ///and the provided bounding box
    ///@param frame frame to compute target model
    ///@param cx center of the object
    ///@param cy center of the object
    ///@param width width of the object
    ///@param height height of the object
    MeanShiftTracker(const cv::Mat& firstFrame, int cx, int cy, int width, int height);

    ///This method tracks the the target model in the current frame
    ///@param frame in this frame the object should be tracked, and annotated
    ///@param maxiter number of iteration mean shift should at most
    void track(cv::Mat& frame, int maxiter);
};

#endif // MEANSHIFTTRACKER_H
