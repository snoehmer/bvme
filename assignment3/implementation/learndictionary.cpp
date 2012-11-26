#include "learndictionary.h"
#include "filterbank.h"
#include "preprocessimage.h"

#include <vector>
#include <iostream>
#include <dirent.h>

learndictionary::learndictionary(std::string referenceDir)
{
    this->dir = referenceDir;
}

void learndictionary::addResponsesForImage(const cv::Mat& img, cv::Mat& responses)
{
    cv::Mat* filterResponse = FilterBank::getInstance().apply(img);

    int currentRow = responses.rows;
    //responses.resize(img.rows * img.cols); //resize response matrix for new responses - not correct

    //TODO: done
    //calculate the responses for the image
    //for a mxn image you get m*n responses.

    // resize the image for m*n new ADDITIONAL responses, each row is one response
    responses.resize(responses.rows + img.rows * img.cols);

    for(int row = 0; row < img.rows; row++)
    {
    	for(int col = 0; col < img.cols; col++)
    	{
    		for(int i = 0; i < responses.cols; i++)
			{
    			int responseRow = currentRow + row * img.cols + col;
				responses.at<float>(responseRow, i) = filterResponse[i].at<double>(row, col);
			}
    	}
    }
}

void learndictionary::addResponsesForClass(const std::string& classDir, int imagesPerClass, cv::Mat& responses)
{
    int count = 0;

    DIR* dirp = opendir(classDir.c_str());
    struct dirent* dp;

    while ((dp = readdir(dirp)) != NULL && count < imagesPerClass)
    {
        std::string fileName(dp->d_name);
        if(fileName != ".." && fileName != ".")
        {
            std::string imgFile = classDir + fileName;
            cv::Mat img = cv::imread(imgFile, CV_LOAD_IMAGE_GRAYSCALE);
            preprocess(img);

            addResponsesForImage(img, responses);

            count++;
        }
    }
    closedir(dirp);
}

cv::Mat learndictionary::learn(const std::vector<std::string>& classes, int imagesPerClass, int clusterCentersPerClass)
{
    cv::Mat centers;

    for(unsigned int i = 0; i < classes.size(); i++)
    {
        cv::Mat responses(0, FilterBank::getInstance().size(), CV_32F);

        std::string classDir(dir + classes.at(i));
        addResponsesForClass(classDir, imagesPerClass, responses);


        //TODO: done
        //create the cluster centers using the k-means algorithm
        //and write each result into centers.
        //hint: cv::kmeans, cv::vconcat

        cv::Mat labels;
        cv::Mat classCenters = cv::Mat::zeros(clusterCentersPerClass, responses.cols, CV_32F);

        cv::kmeans(responses, clusterCentersPerClass, labels, cv::TermCriteria(), 5, cv::KMEANS_RANDOM_CENTERS, classCenters);

        if(i == 0)
        {
        	centers = classCenters.clone();
        }
        else
        {
        	cv::vconcat(centers, classCenters, centers);
        }
    }

    return centers;
}
