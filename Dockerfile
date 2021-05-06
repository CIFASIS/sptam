FROM osrf/ros:kinetic-desktop-full-xenial

ENV HOME="/root"
ENV ROS_DISTRO="kinetic"
ENV CATKIN_WS="${HOME}/catkin_ws"
ENV SPTAM_ROOT="${HOME}/catkin_ws/src/sptam"

# Install dependencies

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    mesa-utils \
    libgtest-dev \
    libsuitesparse-dev \
    libboost-dev \
    python-catkin-tools && \
    rm -rf /var/lib/apt/lists/*

# Build and install GTest
RUN cd /usr/src/gtest/ && \
    cmake -DBUILD_SHARED_LIBS=ON && \
    make -j4 && \
    cp *.so /usr/lib/

### TODO: It's not clear which version of Eigen to use as stable.
# Install Eigen 3.2.10 (S-PTAM finishes KITTI 00)
WORKDIR /tmp 
RUN rm -rf /usr/include/eigen3
RUN git clone https://gitlab.com/libeigen/eigen.git && \
    cd eigen && \
    git checkout 3.2.10  && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr && \
    make install

# Install g2o
WORKDIR /tmp 
RUN git clone https://github.com/RainerKuemmerle/g2o && \
    cd g2o && \
    git checkout 4b9c2f5b68d14ad479457b18c5a2a0bce1541a90 && \
    mkdir build && cd build && \
    cmake .. && make -j4 && make install

# Add OpenCV to PATH environment variable, otherwise it would not be found
ENV PATH="/opt/ros/kinetic/share/OpenCV-3.3.1-dev:$PATH"

# Install DLib
WORKDIR /tmp 
RUN git clone https://github.com/dorian3d/DLib.git && \
    cd DLib && \
    git checkout 70089a38056e8aebd5a2ebacbcb67d3751433f32 &&\
    mkdir build && cd build && \
    cmake .. && make -j4 && make install

# Install DBoW2
WORKDIR /tmp 
RUN git clone https://github.com/dorian3d/DBoW2.git && \
    cd DBoW2 && \
    git checkout 82401cad2cfe7aa28ee6f6afb01ce3ffa0f59b44 &&\
    mkdir build && cd build && \
    cmake .. && make -j4 && make install

# Install DLoopDetector
WORKDIR /tmp 
RUN git clone https://github.com/dorian3d/DLoopDetector.git && \
    cd DLoopDetector && \
    git checkout 8e62f8ae84d583d9ab67796f779272b0850571ce &&\
    mkdir build && cd build && \
    cmake .. && make -j4 && make install

# Install OpenGV
WORKDIR /tmp 
RUN git clone https://github.com/laurentkneip/opengv.git && \
    cd opengv && \
    git checkout 2e2d21917fd2fb75f2134e6d5be7a2536cbc7eb1 &&\
    mkdir build && cd build && \
    cmake .. && make -j4 && make install

# Append ROS setup script to .bashrc.
RUN echo "export ROS_PACKAGE_PATH=${HOME}/catkin_ws:\${ROS_PACKAGE_PATH}" >> ${HOME}/.bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ${HOME}/.bashrc
RUN echo "source ${HOME}/catkin_ws/devel/setup.bash" >> ${HOME}/.bashrc

# Catkin workspace setup
RUN mkdir -p ${HOME}/catkin_ws/src
WORKDIR ${HOME}/catkin_ws
RUN catkin init

# Clone ros-utils  to catkin_ws
WORKDIR ${HOME}/catkin_ws/src
RUN git clone https://github.com/CIFASIS/ros-utils.git

# Add S-PTAM directory to catkin_ws
WORKDIR ${HOME}/catkin_ws/src
COPY ./ ${SPTAM_ROOT}
WORKDIR ${SPTAM_ROOT}
RUN git submodule update --init

# Build S-PTAM 
WORKDIR ${HOME}/catkin_ws

# in order to leave running the terminal we should leave running bash
RUN ["/bin/bash", "-c", "chmod +x ${SPTAM_ROOT}/scripts/build.sh && chmod +x ${SPTAM_ROOT}/scripts/modify_entrypoint.sh && sync && ${SPTAM_ROOT}/scripts/build.sh && ${SPTAM_ROOT}/scripts/modify_entrypoint.sh"]
