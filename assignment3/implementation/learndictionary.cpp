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
    responses.resize(img.rows * img.cols); //resize response matrix for new responses

    //TODO:
    //calculate the responses for the image
    //for a mxn image you get m*n responses.
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

    for(int i = 0; i < classes.size(); i++)
    {
        cv::Mat responses(0, FilterBank::getInstance().size(), CV_32F);

        std::string classDir(dir + classes.at(i));
        addResponsesForClass(classDir, imagesPerClass, responses);


        //TODO
        //create the cluster centers using the k-means algorithm
        //and write each result into centers.
        //hint: cv::kmeans, cv::vconcat
    }

    return centers;
}
