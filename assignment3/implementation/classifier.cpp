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
    //TODO: done
    //return the index of the nearest cluster
    //in clusterCenters using the L2 norm.

	float minDist2 = -1;
	int minDistIndex = -1;

	for(int i = 0; i < clusterCenters.rows; i++)
	{
		float dist2;

		cv::Mat currentCluster = clusterCenters.row(i);
		cv::Mat distMat = cv::Mat::zeros(1, clusterCenters.cols, CV_32F);

		distMat = sample - currentCluster;

		cv::Mat distMat2;
		cv::multiply(distMat, distMat, distMat2);

		dist2 = cv::sum(distMat2)[0];


		if(minDist2 < 0 || dist2 < minDist2)
		{
			minDist2 = dist2;
			minDistIndex = i;
		}
	}

	return minDistIndex;
}

cv::Mat Classifier::computeModel(const cv::Mat& img)
{
    cv::Mat* filterResponse = FilterBank::getInstance().apply(img);
    cv::Mat model = cv::Mat::zeros(1, clusterCenters.rows, CV_32F);

    //TODO: done
    //compute the histogram of textons.

    //cv::Mat textons = cv::Mat::zeros(img.rows, img.cols, CV_32F);

    for(int row = 0; row < img.rows; row++)
    {
    	for(int col = 0; col < img.cols; col++)
    	{
    		// calculate feature vector for current pixel
    		cv::Mat response = cv::Mat::zeros(1, clusterCenters.cols, CV_32F);

    		for(int i = 0; i < clusterCenters.cols; i++)
    		{
    			response.at<float>(0, i) = filterResponse[i].at<double>(row, col);
    		}

    		// get nearest texton for current pixel's feature vector
    		//textons.at<float>(row, col) = nearestCluster(response);

    		// use simple histogram, not OpenCV's calcHist - same performance
    		model.at<float>(0, nearestCluster(response)) += 1.0;
    	}
    }

    // calculate histogram
    //cv::Mat histogram;
    /*int histSize[] = {clusterCenters.rows};
    int channels[] = {0};
    float range[] = {0, clusterCenters.rows};
    const float* ranges[] = {range};

    cv::calcHist(&textons, 1, channels, cv::Mat(), model, 1, histSize, ranges, true, false);
	*/

    return model;
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

  //TODO: done
  //return the index of the classified class.
  //use the chi^2 distance to get the best model.

  cv::Mat imgModel = computeModel(imgClassify);

  double minDist = 0;
  int minDistIndex = 0;
  bool minDistInit = false;

  for(unsigned int i = 0; i < models.size(); i++)
  {
	  double dist = cv::compareHist(imgModel, models[i], CV_COMP_CHISQR);

	  if(!minDistInit || dist < minDist)
	  {
		  minDist = dist;
		  minDistIndex = i;
		  minDistInit = true;
	  }
  }

  return labels[minDistIndex];
}
