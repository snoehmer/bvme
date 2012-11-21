#include "filterbank.h"

#include <iostream>
#include <cmath>


FilterBank::FilterBank() {
    createFilterBank();
}

FilterBank* FilterBank::instance = 0;

FilterBank& FilterBank::getInstance()
{
  if ( !instance )
     instance = new FilterBank();
  return *instance;
}

void FilterBank::destroy()
{
  delete instance;
  instance = 0;
}


void FilterBank::createFilterBank()
{
    int support = 49;

    filters.push_back(createFilter(support, 2, 1));
    filters.push_back(createFilter(support, 4, 1));
    filters.push_back(createFilter(support, 4, 2));
    filters.push_back(createFilter(support, 6, 1));
    filters.push_back(createFilter(support, 6, 2));
    filters.push_back(createFilter(support, 6, 3));
    filters.push_back(createFilter(support, 8, 1));
    filters.push_back(createFilter(support, 8, 2));
    filters.push_back(createFilter(support, 8, 3));
    filters.push_back(createFilter(support, 10, 1));
    filters.push_back(createFilter(support, 10, 2));
    filters.push_back(createFilter(support, 10, 3));
    filters.push_back(createFilter(support, 10, 4));
}

cv::Mat FilterBank::createFilter(int support, double sigma, double tau)
{
    //TODO:
    //create one filter of the filter bank
    //the filter should be of type CV_64F
    //don't forget to normalize the filter!
}

int FilterBank::size()
{
    return filters.size();
}

cv::Mat& FilterBank::get(int i)
{
    return filters.at(i);
}

cv::Mat* FilterBank::apply(const cv::Mat& input) {

    //TODO:
    //filter the input with each filter
    //hint: cv::filter2D
}
