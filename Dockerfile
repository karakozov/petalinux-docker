FROM ubuntu:16.04

MAINTAINER z4yx <z4yx@users.noreply.github.com>

# build with docker build --build-arg PETA_VERSION=2018.x --build-arg PETA_RUN_FILE=petalinux-v2018.x-final-installer.run -t petalinux:2018.x .

ARG UBUNTU_MIRROR=mirror.yandex.ru

#install dependences:
RUN sed -i.bak s/archive.ubuntu.com/${UBUNTU_MIRROR}/g /etc/apt/sources.list && \
  dpkg --add-architecture i386 && apt-get update &&  DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  build-essential \
  sudo \
  tofrodos \
  iproute2 \
  gawk \
  net-tools \
  expect \
  libncurses5-dev \
  tftpd \
  update-inetd \
  libssl-dev \
  flex \
  bison \
  libselinux1 \
  gnupg \
  wget \
  socat \
  gcc-multilib \
  libsdl1.2-dev \
  libglib2.0-dev \
  lib32z1-dev \
  zlib1g:i386 \
  libgtk2.0-0 \
  screen \
  pax \
  diffstat \
  xvfb \
  xterm \
  texinfo \
  gzip \
  unzip \
  cpio \
  chrpath \
  autoconf \
  lsb-release \
  libtool \
  libtool-bin \
  locales \
  kmod \
  git \
  git-cola \
  mc \
  vi \
  rsync \
  bc \
  u-boot-tools \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ARG PETA_VERSION
ARG PETA_RUN_FILE

RUN locale-gen en_US.UTF-8 && update-locale

RUN mkdir /tfptboot
RUN touch /etc/xinetd.d/tftp
RUN echo "service tftp" >> /etc/xinetd.d/tftp
RUN echo "{" >> /etc/xinetd.d/tftp
RUN echo "protocol = udp" >> /etc/xinetd.d/tftp
RUN echo "port = 69" >> /etc/xinetd.d/tftp
RUN echo "socket_type = dgram" >> /etc/xinetd.d/tftp
RUN echo "wait = yes" >> /etc/xinetd.d/tftp
RUN echo "user = nobody" >> /etc/xinetd.d/tftp
RUN echo "server = /usr/sbin/in.tftpd" >> /etc/xinetd.d/tftp
RUN echo "server_args = /home/embedded/tftpboot" >> /etc/xinetd.d/tftp
RUN echo "disable = no" >> /etc/xinetd.d/tftp
RUN echo "}" >> /etc/xinetd.d/tftp
RUN service xinetd restart

#make a Vivado user
RUN adduser --disabled-password --gecos '' vivado && \
  usermod -aG sudo vivado && \
  echo "vivado ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY accept-eula.sh ${PETA_RUN_FILE} /

# run the install
RUN chmod a+rx /${PETA_RUN_FILE} && \
  chmod a+rx /accept-eula.sh && \
  mkdir -p /opt/xilinx && \
  chmod 777 /tmp /opt/xilinx && \
  cd /tmp && \
  sudo -u vivado -i /accept-eula.sh /${PETA_RUN_FILE} /opt/xilinx/petalinux && \
  rm -f /${PETA_RUN_FILE} /accept-eula.sh 

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

USER vivado
ENV HOME /home/vivado
ENV LANG en_US.UTF-8
RUN mkdir /home/vivado/project
WORKDIR /home/vivado/project

#add vivado tools to path
RUN echo "source /opt/xilinx/petalinux/settings.sh" >> /home/vivado/.bashrc
