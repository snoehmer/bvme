#ifndef DEFINITIONS_H_
#define DEFINITIONS_H_

// opencv includes
#include <opencv/cv.h>
#include <opencv/cvaux.h>
#include <opencv/cxcore.h>
#include <opencv/highgui.h>

// typedefs
typedef struct CallbackData{
  cv::Rect bbox;
  cv::Mat *image;
} CallbackData;

// functions
void mouse_callback(int event, int x, int y, int flags, void* user_data);

// members
int selX1 = -1;
int selX2 = -1;
int selY1 = -1;
int selY2 = -1;

// macros
#define INPUT_WINDOW_NAME "Select bounding box - press any key when done"

#endif // DEFINITIONS_H_
