#ifndef CLASSIFIER_H
#define CLASSIFIER_H

#include <vector>

#include "opencv/cv.h"
#include "opencv/cxcore.h"
#include "opencv/highgui.h"

class Classifier
{
private:
    std::string dir;
    /// texton dictionary
    cv::Mat clusterCenters;
    /// learned models (texton histograms)
    std::vector<cv::Mat> models;
    /// associated model labels (class of the model)
    std::vector<int> labels;

    /// Returns the index of the nearest cluster center (cv::Mat clusterCenters)
    /// using the L2 norm as distance measure.
    /// @param cv::Mat& sample
    ///     sample, for which the nearest cluster should be returned
    /// @return int
    ///     index of the nearest cluster in clusterCenters
    int nearestCluster(const cv::Mat& sample);

    /// Computes the histogram of textons for the input image.
    /// @param cv::Mat& img
    ///     input image
    /// @return
    ///     the histogram of textons
    cv::Mat computeModel(const cv::Mat& img);

    /// This method iterates the given classDir for one class (label)
    /// and computes for every image a model.
    /// @param int label
    ///     label (class) for every image in the directory.
    ///     use the index of the classes vector
    /// @param std::string& classDir
    ///     directory which should be iterated
    /// @param int imagesPerClass
    ///     maximum number of images that should be learned
    void learnClass(int label, const std::string& classDir, int imagesPerClass);
public:
    Classifier();
    void setDir(const std::string& dir_)
    {
        dir = dir_;
    }

    /// Learns for every class in classes the maximum number of imagesPerClass models.
    /// @param std::vector<std::string>& classes
    ///     Classes, that should be learned
    /// @param int imagesPerClass
    ///     maximum number of images that should be learned per class
    /// @param cv::Mat& clusterCenters
    ///     learned texton dictionary
    void learn(const std::vector<std::string>& classes, int imagesPerClass, const cv::Mat& clusterCenters);

    /// This method uses the learned models to classify the input image.
    /// Uses the chi^2 distance.
    /// @param cv::Mat& img
    ///     input image, which should be classified
    /// @return int
    ///     index of the classified class in classes vector
    int classify(const cv::Mat& img);
};

#endif // Classifier
