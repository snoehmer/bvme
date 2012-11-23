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
    //TODO: done
    //create one filter of the filter bank
    //the filter should be of type CV_64F
    //don't forget to normalize the filter!

	cv::Mat filter(support, support, CV_64F);

	int center = support/2;

	for(int row = 0; row < support; row++)
	{
		for(int col = 0; col < support; col++)
		{
			int x = col - center;
			int y = row - center;

			int r = sqrt(x*x + y*y);

			filter.at<double>(row, col) = cos(M_PI * tau * r / sigma) * exp(-r*r / (2 * sigma * sigma));

		}
	}

	cv::Scalar filterMean = cv::mean(filter);
	cv::add(filter, -filterMean, filter);
	cv::Scalar filterSum = cv::sum(cv::abs(filter));
	cv::divide(filter, filterSum, filter);

	return filter;
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

    //TODO: done
    //filter the input with each filter
    //hint: cv::filter2D

	cv::Mat* responses = new cv::Mat[filters.size()];

	for(unsigned int i = 0; i < filters.size(); i++)
	{
		cv::filter2D(input, responses[i], CV_64F, filters[i]);
	}

	return responses;
}
