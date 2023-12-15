FROM ros:noetic-ros-base

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_DISTRO=noetic
ARG PROJ_ROOT=/svo_ws
ARG SVO_ROOT=${PROJ_ROOT}/src/rpg_svo_pro_open
ARG INSTALL="apt-get install -y"

RUN apt-get update
RUN $INSTALL \
      python3-catkin-tools \
      python3-vcstool \
      python3-osrf-pycommon \
      libglew-dev \
      libopencv-dev \
      libyaml-cpp-dev \
      libblas-dev \
      liblapack-dev \
      libsuitesparse-dev \
      git \ 
      wget

RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/                                                                                                                                            

RUN mkdir ${PROJ_ROOT}
WORKDIR ${PROJ_ROOT}
RUN catkin config --init --mkdirs --extend /opt/ros/$ROS_DISTRO --cmake-args -DCMAKE_BUILD_TYPE=Release -DEIGEN3_INCLUDE_DIR=/usr/include/eigen3

COPY ./ ${SVO_ROOT}
WORKDIR ${PROJ_ROOT}/src
RUN vcs-import < ./rpg_svo_pro_open/dependencies.yaml &&\
    touch minkindr/minkindr_python/CATKIN_IGNORE

WORKDIR ${SVO_ROOT}/svo_online_loopclosing/vocabularies 
RUN bash download_voc.sh

WORKDIR ${PROJ_ROOT}
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin build
