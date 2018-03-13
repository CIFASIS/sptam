cmake_minimum_required(VERSION 3.0.2)
project( sptam )

# Find OpenCV library
# Find OpenCV library
###############################################################
# BUG FIX for OpenCV 3.3.1 in ROS Kinetic (see: https://github.com/ros-perception/vision_opencv/issues/193)
###############################################################

find_package(OpenCV 3 REQUIRED)
if (${OpenCV_VERSION} MATCHES "3.3.1")
  foreach(__cvcomponent ${OpenCV_LIB_COMPONENTS})
    set (__original_cvcomponent ${__cvcomponent})
    if(NOT __cvcomponent MATCHES "^opencv_")
      set(__cvcomponent opencv_${__cvcomponent})
    endif()
    if (TARGET ${__cvcomponent})
      set_target_properties(${__cvcomponent} PROPERTIES
          MAP_IMPORTED_CONFIG_DEBUG ""
          MAP_IMPORTED_CONFIG_RELEASE ""
          MAP_IMPORTED_CONFIG_RELWITHDEBINFO ""
          MAP_IMPORTED_CONFIG_MINSIZEREL ""
      )
    endif()
  endforeach(__cvcomponent)
endif()

###############################################################
include_directories(${OpenCV_INCLUDE_DIRS})

# List of files to compile
FILE(GLOB SLAM_SRCS *.cpp utils/*.cpp)

# Find libraries required by LoopClosing module
if( USE_LOOPCLOSURE )
  # DLoopDetector library (must be properly installed from github repos)
  find_package(DLib REQUIRED)
  find_package(DBoW2 REQUIRED)
  find_package(DLoopDetector REQUIRED)
  include_directories(${DLib_INCLUDE_DIRS} ${DBoW2_INCLUDE_DIRS} ${DLoopDetector_INCLUDE_DIRS})
  set(DLD_LIBRARIES ${DLib_LIBRARIES} ${DBoW2_LIBRARIES}) # DLoopDetector its just a header
  
  # Find OpenGV
  find_package(OpenGV REQUIRED)
  INCLUDE_DIRECTORIES(${OPENGV_INCLUDE_DIR})
  
  # List of files to compile
  FILE(GLOB LC_SRCS loopclosing/*.cpp)
  set(SLAM_SRCS ${SLAM_SRCS} ${LC_SRC})
  
  # if LC isnt defined, DLD_LIBRARIES OPENGV_LIBRARY are "blank"
endif()

# Compile the tracker visualization library
if ( SHOW_TRACKED_FRAMES )
  set(SLAM_SRCS ${SLAM_SRCS} utils/draw/Draw.cpp)
endif()

# Compile the profiling library
if ( SHOW_PROFILING )
  set(SLAM_SRCS ${SLAM_SRCS} utils/log/Logger.cpp)
endif()

# Build the sptam library
add_library( sptam  ${SLAM_SRCS} )
target_link_libraries( sptam ${OpenCV_LIBRARIES} ${DLD_LIBRARIES} ${OPENGV_LIBRARY} ${TBB_LIBRARIES})
