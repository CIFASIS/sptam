FROM osrf/ros:kinetic-desktop-full-xenial

# These arguments are used to recreate the host user in the image.
# This allows to create and modify files (including git commands) of mounted directories 
# from the container without messing up with file permissions.
### TODO: this is only useful for development, we should configure default values for production builds.
ARG USER_NAME=""
ARG USER_UID="" 
ARG USER_GID=""

################ Madatory dependencies #################
########################################################

# Install mandatory dependencies first so we can use docker cache
# in case of modifying optional dependencies and avoid rebuilding
# the whole image.

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    mesa-utils \
    libgtest-dev \
    libsuitesparse-dev

# Build and install GTest
RUN cd /usr/src/gtest/ && \
    cmake -DBUILD_SHARED_LIBS=ON && \
    make && \
    cp *.so /usr/lib/

# Install g2o
RUN git clone https://github.com/RainerKuemmerle/g2o && \
    cd g2o && \
    git checkout 4b9c2f5b68d14ad479457b18c5a2a0bce1541a90 && \
    mkdir build && cd build && \
    cmake .. && make && make install

### TODO: It's not clear which version of Eigen to use as stable.
### 3.2.10 is suggested but it crashes randomly.
### Find the right version or just update sptam code to use the latest.
# Install Eigen to 3.2.10
# RUN rm -rf /usr/include/eigen3
# RUN git clone https://gitlab.com/libeigen/eigen.git && \
#     cd eigen && \
#     git checkout 3.2.10  && \
#     mkdir build && cd build && \
#     cmake .. -DCMAKE_INSTALL_PREFIX=/usr && \
#     make install

#################################

################ Optional dependencies #################
########################################################

# This is only useful for development, you can safely remove/comment the following for production builds.
RUN apt-get update && apt-get install -y \
    gdb \
    # This is useful for launching multiple terminals from scripts.
    # We choose gnome-terminal since it's the default terminal in Ubuntu 16.04.
    # You can remove this if don't need to launch terminals from the container (saves up to 275MB on image size)
    gnome-terminal

############### User creation ###############
#############################################

# Create the user
RUN groupadd --gid $USER_GID $USER_NAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USER_NAME
#
# [Optional] Add sudo support. Omit if you don't need to install software after connecting.
# Use with care, you don't really need to have sudo suport inside the docker container.
# This is only useful if you want to temporaly install things on the fly.
RUN apt-get update \
    && apt-get install -y sudo \
    && echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME \
    && chmod 0440 /etc/sudoers.d/$USER_NAME

#################################

################ User setup #################
#############################################

USER $USER_NAME

# User specific setup.
# Anything you want to do with your /home directory inside the container goes here.

# Append ROS setup script to .bashrc.
RUN echo "source /opt/ros/kinetic/setup.bash" >> /home/${USER_NAME}/.bashrc

# Catkin workspace setup.
RUN mkdir /home/${USER_NAME}/catkin_ws && \
    cd /home/${USER_NAME}/catkin_ws && \
    mkdir src && cd src &&\
    # Clone needed modules
    git clone https://github.com/lrse/ros-utils.git
