%module VisionProxy
%{
#include "vision.h"
#include <iostream>
#include "opencv.hpp"
%}

%include "std_vector.i"
%include "std_string.i"
%include "typemaps.i"
%include "various.i"


%template(FindResults) std::vector<FindResult>;

%typemap(jni) unsigned char*        "jbyteArray"
%typemap(jtype) unsigned char*      "byte[]"
%typemap(jstype) unsigned char*     "byte[]"

// Map input argument: java byte[] -> C++ unsigned char *
%typemap(in) unsigned char* {
   long len = JCALL1(GetArrayLength, jenv, $input);
   $1 = (unsigned char *)malloc(len + 1);
   if ($1 == 0) {
      std::cerr << "out of memory\n";
      return 0;
   }
   JCALL4(GetByteArrayRegion, jenv, $input, 0, len, (jbyte *)$1);
}

%typemap(freearg) unsigned char* %{
   free($1);
%}

// change Java wrapper output mapping for unsigned char*
%typemap(javaout) unsigned char* {
    return $jnicall;
 }

%typemap(javain) unsigned char* "$javainput" 


struct FindResult {
   int x, y;
   int w, h;
   double score;
   FindResult(){
      x=0;y=0;w=0;h=0;score=-1;
   }
   FindResult(int _x, int _y, int _w, int _h, double _score){
      x = _x; y = _y;
      w = _w; h = _h;
      score = _score;
   }
};

namespace sikuli {


class FindInput{
      
public:
   
   FindInput();
   FindInput(cv::Mat source, cv::Mat target);
   FindInput(cv::Mat source, const char* target, bool text = false);
   FindInput(const char* source_filename, const char* target, bool text = false);

   void setSource(const char* source_filename);
   void setTarget(const char* target_string, bool text = false);
   void setSource(cv::Mat source);
   void setTarget(cv::Mat target);
   cv::Mat getSourceMat();
   cv::Mat getTargetMat();

   void setFindAll(bool all);
   bool isFindingAll();

   void setFindText(bool text);
   bool isFindingText();

   void setLimit(int limit);
   int getLimit();
   
   void setSimilarity(double similarity);
   double getSimilarity();

   std::string getTargetText();
   
private:
   
   void init(cv::Mat source_, const char* target_string, bool text);
   void init();

      
   cv::Mat source;
   cv::Mat target;
   std::string targetText;
   
   int limit;
   double similarity;
   
   int ordering;
   int position;
   
   bool bFindingAll;
   bool bFindingText;
};


class Vision{
public:
      
   static std::vector<FindResult> find(FindInput q);
   
   static double compare(cv::Mat m1, cv::Mat m2);
   
   static void initOCR(const char* ocrDataPath);
      
   static std::string recognize(cv::Mat image);
   
};

}


namespace cv{
   class Mat {
     int _w, _h;
     unsigned char* _data;

   public:
     Mat(int _rows, int _cols, int _type, unsigned char* _data);
   };

}

#define CV_DEPTH_MAX  (1 << CV_CN_SHIFT)
#define CV_CN_SHIFT   3
#define CV_8U   0
#define CV_8S   1
#define CV_16U  2
#define CV_16S  3
#define CV_32S  4
#define CV_32F  5
#define CV_64F  6
#define CV_USRTYPE1 7

#define CV_MAT_DEPTH_MASK       (CV_DEPTH_MAX - 1)
#define CV_MAT_DEPTH(flags)     ((flags) & CV_MAT_DEPTH_MASK)

#define CV_MAKETYPE(depth,cn) (CV_MAT_DEPTH(depth) + (((cn)-1) << CV_CN_SHIFT))
#define CV_MAKE_TYPE CV_MAKETYPE

#define CV_8UC1 CV_MAKETYPE(CV_8U,1)
#define CV_8UC2 CV_MAKETYPE(CV_8U,2)
#define CV_8UC3 CV_MAKETYPE(CV_8U,3)

