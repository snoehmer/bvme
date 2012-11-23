#include "preprocessimage.h"
#include <cmath>

void preprocess(cv::Mat& img)
{
    img.convertTo(img, CV_64F);

    //TODO: done

    //  normalize image to zero mean
    cv::Scalar imgMean = cv::mean(img);
    cv::add(img, -imgMean, img);

    //  normalize image to an unit standard deviation
    cv::Scalar imgSum = cv::sum(cv::abs(img));
    cv::divide(img, imgSum, img);
}
