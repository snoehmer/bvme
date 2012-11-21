#include "classifier.h"
#include "filterbank.h"
#include "preprocessimage.h"

#include <iostream>
#include <dirent.h>

Classifier::Classifier()
{
}

int Classifier::nearestCluster(const cv::Mat& sample)
{
    //TODO:
    //return the index of the nearest cluster
    //in clusterCenters using the L2 norm.
}

cv::Mat Classifier::computeModel(const cv::Mat& img)
{
    cv::Mat* filterResponse = FilterBank::getInstance().apply(img);
    cv::Mat model = cv::Mat::zeros(1, clusterCenters.rows, CV_32F);

    //TODO:
    //compute the histogram of textons.
}

void Classifier::learnClass(int label, const std::string& classDir, int imagesPerClass)
{
  int count = 0;
  DIR* dirp = opendir(classDir.c_str());
  struct dirent* dp;
  while ((dp = readdir(dirp)) != NULL && count < imagesPerClass)
  {
    std::string fileName(dp->d_name);
    if (fileName != ".." && fileName != ".")
    {
      std::string imgFile = classDir + fileName;
      cv::Mat img = cv::imread(imgFile, CV_LOAD_IMAGE_GRAYSCALE);
      preprocess(img);

      cv::Mat model = computeModel(img);
      labels.push_back(label);
      models.push_back(model);

      count++;
    }
  }
  closedir(dirp);
}

void Classifier::learn(const std::vector<std::string>& classes, int imagesPerClass,
    const cv::Mat& clusterCenters)
{
  this->clusterCenters = clusterCenters;

  for (unsigned int i = 0; i < classes.size(); i++)
  {
    std::string classDir(dir + classes.at(i));
    learnClass(i, classDir, imagesPerClass);
  }
}

int Classifier::classify(const cv::Mat& img)
{
  cv::Mat imgClassify = img.clone();
  preprocess(imgClassify);

  //TODO:
  //return the index of the classified class.
  //use the chi^2 distance to get the best model.
}
