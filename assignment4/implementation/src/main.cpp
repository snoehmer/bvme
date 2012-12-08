#include <iostream>
#include <cstdlib>
#include <string>

#include "Definitions.h"
#include "meanshifttracker.h"

int main(int argc, char* argv[])
{
  if (argc < 3)
  {
    std::cerr  << "Usage: ./meanshift pathToInputVideo outputFileName.avi" << std::endl;
    return EXIT_FAILURE;
  }

  std::string input_video = argv[1];
  std::string output_video = argv[2];

  cv::VideoCapture capture(input_video);

  // Get video information
  int fourcc = (int) capture.get(CV_CAP_PROP_FOURCC);
  int frames = (int) capture.get(CV_CAP_PROP_FRAME_COUNT);
  double fps = capture.get(CV_CAP_PROP_FPS);
  int frame_width = (int) capture.get(CV_CAP_PROP_FRAME_WIDTH);
  int frame_height = (int) capture.get(CV_CAP_PROP_FRAME_HEIGHT);
  cv::Mat frame, gray;

  // Create writer
  cv::VideoWriter writer;
  writer.open(output_video, fourcc, fps, cv::Size(frame_width, frame_height));
  if (!writer.isOpened())
  {
    std::cout << "[WARNING] Cannot encode video with the same codec as input video!" << std::endl;

    // NOTE: the fallback is to write an uncompressed RGB video - should work on all
    // platforms. However, the file size will become *very* large (so please DO NOT
    // submit this without re-encoding with a different codec) - you may of course
    // try other codecs!
    fourcc = CV_FOURCC('D', 'I', 'B', ' ');
    writer.open(output_video, fourcc, fps, cv::Size(frame_width, frame_height));
    if (!writer.isOpened())
    {
      std::cout << "[ERROR] Cannot encode video with fallback codec!" << std::endl;
      return EXIT_FAILURE;
    }
  }


  // get init bbox for tracker
  capture >> frame;
  CallbackData callback_data;
  callback_data.image = &frame;
  cv::namedWindow(INPUT_WINDOW_NAME, CV_WINDOW_AUTOSIZE);
  cv::setMouseCallback(INPUT_WINDOW_NAME, mouse_callback, &callback_data);
  cv::imshow(INPUT_WINDOW_NAME, frame);
  std::cout << "[INFO] Hit any key after selection" << std::endl;
  cv::waitKey();
  cv::destroyWindow(INPUT_WINDOW_NAME);
  cv::Rect bbox = callback_data.bbox;
  MeanShiftTracker tracker(frame, bbox.x+bbox.width/2, bbox.y+bbox.height/2, bbox.width, bbox.height);

  for (int f = 1; f < frames; ++f)
  {
    capture >> frame;
    std::cout << "[INFO] Process... #" << f << "/" << frames << std::endl;
    if (frame.empty())
    {
        std::cout << "[WARNING] Skipping empty frame (#" << f << ")" << std::endl;
        continue;
    }

    tracker.track(frame, 20);
    writer << frame;
  }

  return EXIT_SUCCESS;
}

void mouse_callback(int event, int x, int y, int flags, void* user_data)
{
  CallbackData *data = static_cast<CallbackData*>(user_data);
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
      cv::Mat imgShow = data->image->clone();
      cv::Mat roi(imgShow, selection);
      cv::bitwise_not(roi, roi);
      cv::imshow(INPUT_WINDOW_NAME, imgShow);
    }
  }

  switch (event) {
  case CV_EVENT_LBUTTONDOWN:

    selX1 = x;
    selY1 = y;
    cv::imshow(INPUT_WINDOW_NAME, *data->image);
    break;
  case CV_EVENT_LBUTTONUP:
    if (x2 - x1 > 0 && y2 - y1 > 0)
    {
      cv::Rect selection(x1, y1, x2 - x1, y2 - y1);
      data->bbox = selection;
    }
    selX1 = -1;
    selY1 = -1;
    break;
  }
}


