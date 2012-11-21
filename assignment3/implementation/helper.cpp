#include "helper.h"

#include <dirent.h>
#include <fstream>


Helper::Helper()
{
  for (int i = 0; i < 3; i++)
    classes_.push_back("");

  refdir_ = "";
  image2classify_ = "";
}

bool Helper::verifyInputArguments(int argc, char* argv[])
{
  bool success = true;
  if (argc < 6)
  {
    std::cerr
        << "Usage: ./learning pathToReferenceDirectory class1 class2 class3 pathToImage2Classify"
        << std::endl;
    return false;
  }

  DIR *dir;
  std::string dirname = argv[1];
  if ((dir = opendir(dirname.c_str())) == NULL)
  {
    std::cerr << "[ERROR] Path to reference directory (" << dirname <<") does not exist" << std::endl;
    success = false;
  }
  else
  {
    refdir_ = dirname;
  }

  for (int i = 1; i <= 3; i++)
  {
    dirname.clear();
    dirname = std::string(argv[1]) + std::string(argv[1 + i]) + "/";
    if ((dir = opendir(dirname.c_str())) == NULL)
    {
      std::cerr << "[ERROR] Class " << std::string(argv[1 + i]) << " does not exist" << std::endl;
      success = false;
    }
    else
    {
      classes_[i - 1] = std::string(argv[1 + i]) + "/";
    }
  }

  std::ifstream filetest(argv[5]);
  if (filetest.fail())
  {
    std::cerr << "[ERROR] Path to image2classify (" << argv[5] <<") does not exist" << std::endl;
    success = false;
  }
  else
  {
    image2classify_ = argv[5];
  }
  return success;
}

std::vector<std::string> Helper::getClasses()
{
  return classes_;
}

std::string Helper::getRefDir()
{
  return refdir_;
}

std::string Helper::getImage2Classify()
{
  return image2classify_;
}
