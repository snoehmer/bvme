#include "preprocessimage.h"
#include <cmath>

void preprocess(cv::Mat& img)
{
    img.convertTo(img, CV_64F);

    //TODO:
    //  normalize image to zero mean and
    //  an unit standard deviation
}
