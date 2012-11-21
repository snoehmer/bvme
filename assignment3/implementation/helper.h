#ifndef HELPER_H_
#define HELPER_H_

#include <iostream>
#include <string>
#include <vector>

class Helper {
public:
  Helper();

  // This methods verifies the command line arguments.
  // If the arguments are not correct, errors will be displayed.
  // @param argv
  //        argv[0] ./learning
  //        argv[1] pathToReferenceDirectory
  //        argv[2] class 1
  //        argv[3] class 2
  //        argv[4] class 3
  //        argv[5] pathToImage2Classify
  bool verifyInputArguments(int argc, char* argv[]);

  // This method returns the classes defined via command line arguments
  // @return std::vector<std::string>
  //         holds all defined classes
  std::vector<std::string> getClasses();

  // This method returns the path to reference directory defined via command line arguments
  // @return std::string
  //         holds the path to reference directory
  std::string getRefDir();

  // This method returns the path to the image which should be classified defined via command line arguments
  // @return std::string
  //         holds the path to the image which should be classified
  std::string getImage2Classify();

private:
  std::vector<std::string> classes_;
  std::string refdir_;
  std::string image2classify_;
};

#endif
