# https://www.reddit.com/r/FPGA/comments/bk8b3n/dockerizing_xilinx_tools/

FROM  ubuntu:focal
ENV DEBIAN_FRONTEND=noninteractive

# Configure local ubuntu mirror as package source
RUN \
  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list

ENV XLNX_INSTALL_LOCATION=/opt/Xilinx

ENV DEBIAN_FRONTEND=noninteractive

# Set BASH as the default shell
RUN echo "dash dash/sh boolean false" | debconf-set-selections 
RUN DEBIAN_FRONTEND=$DEBIAN_FRONTEND dpkg-reconfigure dash

RUN apt-get update
RUN dpkg --add-architecture i386 
RUN apt-get update 
# petalinux base dependencies
RUN apt-get install -y \
  tofrodos \
  iproute2 \
  gawk \
  xvfb \
  git \
  make \
  net-tools \
  libncurses5-dev \
  update-inetd \
  tftpd \
  zlib1g-dev:i386 \
  libssl-dev \
  flex \
  bison \
  libselinux1 \
  gnupg \
  wget \
  diffstat \
  chrpath \
  socat \
  xterm \
  autoconf \
  libtool \
  libtool-bin \
  tar \
  unzip \
  texinfo \
  zlib1g-dev \
  gcc-multilib \
  build-essential \
  libsdl1.2-dev \
  libglib2.0-dev \
  screen \
  pax \
  gzip \
  python3-gi \
  less \
  lsb-release \
  fakeroot \
  libgtk2.0-0 \
  libgtk2.0-dev \
  cpio \
  rsync \
  xorg \
  expect \
  dos2unix

RUN apt-get install -y \
  google-perftools \
  default-jre


COPY vivado-installer/ /vivado-installer/

# ENV XLNX_VIVADO_OFFLINE_INSTALLER=<YOUR_VIVADO_INSTALLER>.tar.gz
# ENV XLNX_VIVADO_BATCH_CONFIG_FILE=<YOUR_VIVADO_CONFIG>.config
# COPY $XLNX_VIVADO_OFFLINE_INSTALLER $XLNX_INSTALL_LOCATION/tmp/$XLNX_VIVADO_OFFLINE_INSTALLER
# COPY $XLNX_VIVADO_BATCH_CONFIG_FILE $XLNX_INSTALL_LOCATION/tmp/$XLNX_VIVADO_BATCH_CONFIG_FILE

RUN cd /vivado-installer \
  && cat install_config.txt \
  && echo "cd $XLNX_INSTALL_LOCATION" >> $HOME_DIR/.bashrc \
  && echo "export LANG=en_US.UTF-8" >> $HOME_DIR/.bashrc \
  && export "LANG=en_US.UTF-8" 

WORKDIR /vivado-installer 
RUN mv install_config.txt Xilinx_Unified/ 
WORKDIR /vivado-installer/Xilinx_Unified 
# Setup installer permissions \
RUN chmod a+x xsetup 
# Run Setup in batch mode to install Vivado \
RUN cd /vivado-installer/Xilinx_Unified 
RUN ./xsetup \
  --agree XilinxEULA,3rdPartyEULA \
  --config install_config.txt \
  --batch INSTALL 
# Cleanup Temporary Files \
RUN cd $HOME_DIR 
RUN rm -rf /vivado-installer

RUN  echo ". /tools/Xilinx/Vivado/2021.2/settings64.sh" >> $HOME_DIR/.bashrc \
  && echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/tools/Xilinx/Vivado/2021.2/lib/lnx64.o/" >> $HOME_DIR/.bashrc

# Cleanup temporary install files 

# Cleanup apt cache and temporary files to reduce image size
RUN apt-get clean

RUN apt-get install locales libtinfo5

RUN locale-gen en_US.UTF-8 
RUN update-locale LANG=en_US.UTF-8

RUN source /tools/Xilinx/Vivado/2021.2/settings64.sh
RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/tools/Xilinx/Vivado/2021.2/lib/lnx64.o/