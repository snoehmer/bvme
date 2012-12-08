## IPPR (BVME) - Assignment 4
## CMakeLists file

cmake_minimum_required(VERSION 2.6)
project(MeanShiftTracking)

# OpenCV support
set(CMAKE_INCLUDE_DIRS_CONFIGCMAKE "${CMAKE_INSTALL_PREFIX}/include/opencv" "${CMAKE_INSTALL_PREFIX}/include")
find_package(OpenCV)
include_directories(${OPENCV_INCLUDE_DIR})

set(CMAKE_CXX_FLAGS "-g -Wall")

# Project config
add_executable(
  meanshift
  src/main.cpp
  src/Definitions.h
  src/meanshifttracker.cpp
  src/meanshifttracker.h
)

target_link_libraries(
  meanshift
  opencv_core
  opencv_imgproc
  opencv_highgui
  opencv_features2d
  opencv_calib3d
  opencv_video
)
