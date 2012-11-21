#ifndef FILTERBANK_H
#define FILTERBANK_H

#include <vector>
#include "opencv/cv.h"
#include "opencv/cxcore.h"

/// FilterBank implements the Schmid filter bank and is
/// implemented as a singleton.
/// Use getInstance() to apply the filter bank to an
/// image.
class FilterBank
{
private:
    static FilterBank* instance;
    std::vector<cv::Mat> filters;

    FilterBank();

    /// Creates the filters in the filter bank
    void createFilterBank();

    /// Creates one filter of the filter bank
    /// @param int support
    ///     the filter has the size support x support. Has to be
    ///     an odd number.
    /// @param sigma
    ///     first parameter of the Schmid definition
    /// @param tau
    ///     second parameter of the Schmid definition
    /// @return cv::Mat
    ///     the created filter as Mat object
    cv::Mat createFilter(int support, double sigma, double tau);
public:

    static FilterBank& getInstance();
    static void destroy();

    cv::Mat& get(int i);

    /// @return
    ///     returns the number of filters in the filter bank (13)
    int size();

    /// Filters the input (image) with all filters in the filter bank
    /// @param cv::Mat& input
    ///     the matrix input, that should be filtered
    /// @return
    ///     an array of filtered inputs. If the filter bank has x filters
    ///     the output should be x filtered inputs.
    cv::Mat* apply(const cv::Mat& input);
};

#endif // FILTERBANK_H
