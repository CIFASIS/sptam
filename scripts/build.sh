#!/bin/bash
source /opt/ros/kinetic/setup.bash
catkin build ros_utils
catkin build sptam --cmake-args -DCMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_LOOPCLOSURE=ON -DSINGLE_THREAD=OFF -DSHOW_TRACKED_FRAMES=ON -DSHOW_PROFILING=ON -DPARALLELIZE=ON
