FROM ros:kinetic-ros-base

# install ros tutorials packages
RUN apt-get update && apt-get install -y \
    ros-kinetic-ros-tutorials \
    ros-kinetic-common-tutorials \
    ros-kinetic-rtabmap-ros \
    ros-kinetic-imu-filter-madgwick \
    ros-kinetic-robot-localization \
    python-pip \
    libeigen3-dev \
    libflann-dev \
    libusb-1.0-0-dev \
    libvtk6-qt-dev \
    libpcap-dev \
    libboost-all-dev \
    libproj-dev \
    wget \
    xvfb=2:1.18.4-0ubuntu0.7 \
	x11-apps=7.7+5+nmu1ubuntu1 \
	netpbm=2:10.0-15.3\
    && rm -rf /var/lib/apt/lists/
    
RUN \
    git config --global http.sslVerify false && \
    git clone --branch pcl-1.8.1 --depth 1 https://github.com/PointCloudLibrary/pcl.git pcl-trunk && \
    cd pcl-trunk && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j 1 && make install && \
    make clean

RUN ldconfig

RUN pip install --upgrade pip==18.0
RUN pip install \
  notebook==5.6.0 \
  ipywidgets==7.3.0 \
  ipykernel==4.8.2 \
  matplotlib==2.2.2 \
  jupyterlab==0.33.4 \
  opencv-python \
  scipy \
  pyrosbag \
  pandas \
  python-pcl

ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}

RUN wget http://realsense-hw-public.s3-eu-west-1.amazonaws.com/rs-tests/office_1.bag -O ${HOME}/office_1.bag

USER ${NB_USER}
WORKDIR ${HOME}

CMD ["jupyter", "lab", "--no-browser", "--ip", "0.0.0.0"]
