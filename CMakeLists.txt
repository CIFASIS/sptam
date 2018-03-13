cmake_minimum_required(VERSION 3.0.2)
project( sptam )

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake-modules)

# include macros for program options
include( options )

## Find catkin macros and libraries
find_package( catkin REQUIRED COMPONENTS
  roscpp
  cmake_modules
  std_msgs
  sensor_msgs
  geometry_msgs
  cv_bridge
  message_filters
  image_geometry
  pcl_ros
  nav_msgs
  tf2
  tf2_geometry_msgs
  tf2_ros
  image_transport
  nodelet
)
include_directories(${catkin_INCLUDE_DIRS})

# Find Boost Library
find_package(Boost COMPONENTS thread system regex REQUIRED)
include_directories(${BOOST_INCLUDE_DIR})

# Find yaml-cpp Library
find_package(PkgConfig)
pkg_check_modules(YamlCpp yaml-cpp)

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

# Find Suitesparse library
find_package(SuiteSparse REQUIRED)
include_directories(${CSPARSE_INCLUDE_DIR})
include_directories(${CHOLMOD_INCLUDE_DIR})

# Find G2O Library
find_package(G2O REQUIRED)
# select required components
SET(G2O_LIBRARIES ${G2O_CORE_LIBRARY} ${G2O_STUFF_LIBRARY} ${G2O_SOLVER_CSPARSE} ${G2O_SOLVER_CSPARSE_EXTENSION} ${G2O_TYPES_SBA} ${G2O_TYPES_SLAM3D})
include_directories(${G2O_INCLUDE_DIR})

###################################
## catkin specific configuration ##
###################################
## The catkin_package macro generates cmake config files for your package
## Declare things to be passed to dependent projects
## INCLUDE_DIRS: uncomment this if you package contains header files
## LIBRARIES: libraries you create in this project that dependent projects also need
## CATKIN_DEPENDS: catkin_packages dependent projects also need
## DEPENDS: system dependencies of this project that dependent projects also need
catkin_package(
#  INCLUDE_DIRS include
#  LIBRARIES sptam
   CATKIN_DEPENDS roscpp std_msgs sensor_msgs geometry_msgs cv_bridge message_filters image_geometry pcl_ros nav_msgs tf2 tf2_geometry_msgs tf2_ros nodelet
#  DEPENDS system_lib
)


###########
## Build ##
###########

# Build the sptam library
add_subdirectory( src/sptam )

set( SPTAM_LIBRARIES
  ${OpenCV_LIBRARIES}
  ${Boost_LIBRARIES}
  ${PCL_LIBRARIES}
  ${catkin_LIBRARIES}
  ${G2O_LIBRARIES}
  ${SUITESPARSE_LIBRARIES}
  ${CHOLMOD_LIBRARIES}
  ${YamlCpp_LIBRARIES}
  cxsparse
  sptam
)

# Build the sptam node
add_subdirectory( src/ros )

#############
## Install ##
#############

#TODO

#############
## Testing ##
#############

#TODO
