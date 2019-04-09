FROM ros:kinetic-ros-base

RUN apt-get update && apt-get install -y \
    libpcl1 \
    ros-kinetic-ros-tutorials \
    ros-kinetic-common-tutorials \
    ros-kinetic-rtabmap-ros \
    ros-kinetic-imu-filter-madgwick \
    ros-kinetic-robot-localization \
    python-pip \
    python3 python3-pip python3-dev python3-scipy python3-numpy python3-lxml \
    wget \
    xvfb=2:1.18.4-0ubuntu0.7 \
	x11-apps=7.7+5+nmu1ubuntu1 \
	netpbm=2:10.0-15.3\
    && rm -rf /var/lib/apt/lists/

RUN pip3 install --upgrade pip==18.0
RUN pip3 install \
  notebook==5.6.0 \
  ipywidgets==7.3.0 \
  ipykernel==4.8.2 \
  matplotlib==2.2.2 \
  jupyterlab==0.33.4 \
  cython==0.25.2 \
  opencv-python \
  scipy \
  pyrosbag \
  pandas \
  appmode \
  scikit-build

 RUN git clone https://github.com/strawlab/python-pcl.git && cd python-pcl && python3 setup.py install && cd ..

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

RUN git clone https://github.com/daavoo/pyntcloud.git && cd pyntcloud && git checkout -f 07080206caee99e05ec32390ccbca12911f44e98 && python3 setup.py install && cd ..

RUN wget http://realsense-hw-public.s3-eu-west-1.amazonaws.com/rs-tests/office_1.bag -O ${HOME}/office_1.bag

RUN mkdir $HOME/.jupyter && echo "c.NotebookApp.iopub_data_rate_limit=1e22" >> $HOME/.jupyter/jupyter_notebook_config.py

RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension
RUN jupyter nbextension enable --py --sys-prefix appmode
RUN jupyter serverextension enable --py --sys-prefix appmode

USER ${NB_USER}
WORKDIR ${HOME}

CMD ["jupyter", "lab", "--no-browser", "--ip", "0.0.0.0"]
