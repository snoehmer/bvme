#include <iostream>
#include <string>

//#include <opencv/highgui.h>
#include <opencv2/highgui/highgui.hpp>

#include "helper.h"
#include "filterbank.h"
#include "learndictionary.h"
#include "preprocessimage.h"
#include "classifier.h"

int selX1 = -1;
int selY1 = -1;
cv::Mat imgClassify;
std::vector<std::string> classes;
Classifier classifier;

/// Callback for imshow mouse events
void onSelect(int event, int x, int y, int, void*)
{
  int x1, y1, x2, y2;
  if (selX1 != -1)
  {
    if (selX1 < x)
    {
      x1 = selX1;
      x2 = x;
    }
    else
    {
      x1 = x;
      x2 = selX1;
    }
    if (selY1 < y)
    {
      y1 = selY1;
      y2 = y;
    }
    else
    {
      y1 = y;
      y2 = selY1;
    }

    if (x2 - x1 > 0 && y2 - y1 > 0)
    {
      cv::Rect selection(x1, y1, x2 - x1, y2 - y1);
      cv::Mat imgShow = imgClassify.clone();
      cv::Mat roi(imgShow, selection);
      cv::bitwise_not(roi, roi);
      cv::imshow("Select to classify", imgShow);
    }
  }

  switch (event) {
  case CV_EVENT_LBUTTONDOWN:
    selX1 = x;
    selY1 = y;
    cv::imshow("Select to classify", imgClassify);
    break;
  case CV_EVENT_LBUTTONUP:
    if (x2 - x1 > 0 && y2 - y1 > 0)
    {
      cv::Rect selection(x1, y1, x2 - x1, y2 - y1);
      cv::Mat roi(imgClassify, selection);

      int classIdx = classifier.classify(roi);
      std::cout << "classification result: " << classes.at(classIdx) << std::endl;
    }
    selX1 = -1;
    selY1 = -1;
    break;
  }
}

int main(int argc, char* argv[])
{
  Helper helper;
  bool success = helper.verifyInputArguments(argc, argv);

  if (!success)
    return EXIT_FAILURE;

  //learn texton dictionary
  std::cout << "[INFO] creating dictionary" << std::endl;
  learndictionary dict(helper.getRefDir());
  classes = helper.getClasses();
  cv::Mat clusterCenters = dict.learn(classes, 5, 4);
  std::cout << "[INFO] dictionary created" << std::endl;

  //train classifier
  std::cout << "[INFO] creating classifier models" << std::endl;
  classifier.setDir(helper.getRefDir());
  classifier.learn(classes, 10, clusterCenters);
  std::cout << "[INFO] classifier models created" << std::endl;

  //select part of image to classify
  std::cout << "[INFO] select image region for classification" << std::endl;
  std::cout << "[INFO] press key to quit" << std::endl;
  imgClassify = cv::imread(helper.getImage2Classify(), CV_LOAD_IMAGE_GRAYSCALE);

  if (imgClassify.empty())
  {
    std::cerr << "[ERROR] Unable to read image2classify" << std::endl;
  }
  cv::namedWindow("Select to classify", 0);
  cv::setMouseCallback("Select to classify", onSelect, 0);
  cv::imshow("Select to classify", imgClassify);

  cv::waitKey();

  return EXIT_SUCCESS;
}

