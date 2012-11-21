#ifndef PREPROCESSIMAGE_H
#define PREPROCESSIMAGE_H

#include "opencv/cv.h"
#include "opencv/cxcore.h"

/// This function converts the matrix to CV_64F
/// and normalizes the image.
/// @params cv::Mat& img
///     image, that should be normalized
void preprocess(cv::Mat& img);

#endif // PREPROCESSIMAGE_H
