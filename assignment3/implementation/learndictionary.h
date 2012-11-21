#ifndef LEARNDICTIONARY_H
#define LEARNDICTIONARY_H

#include <string>
#include <vector>

#include "opencv/cv.h"
#include "opencv/cxcore.h"
#include "opencv/highgui.h"

class learndictionary
{
private:
    std::string dir;


    /// Computes the filter responses for one image.
    /// @param cv::Mat& img
    ///     matrix to compute the filter responses. filter bank input.
    /// @param cv::Mat& responses
    ///     the responses should be written into this matrix
    void addResponsesForImage(const cv::Mat& img, cv::Mat& responses);

    /// This function iterates the given directory to get the
    /// responses for each image.
    /// @param std::string& classDir
    ///     directory that should be iterated
    /// @param int imagesPerClass
    ///     how many images per class should be used for training
    /// @param cv::Mat& responses
    ///     the responses should be written into this matrix
    void addResponsesForClass(const std::string& classDir, int imagesPerClass, cv::Mat& responses);
public:
    /// Constructor
    /// @param std::string dir
    ///     directory of the training images
    learndictionary(std::string dir);

    /// Call this function to learn the texton dictionary
    /// @param std::vector<std::string>& classes
    ///     classes for which the textons should be learned
    /// @param int imagesPerClass
    ///     how many images per class should be used for training
    /// @param int clusterCentersPerClass
    ///     how many clusters should be learned for each class
    cv::Mat learn(const std::vector<std::string>& classes, int imagesPerClass, int clusterCentersPerClass);
};

#endif // LEARNDICTIONARY_H
