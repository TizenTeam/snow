#!/bin/echo docker build . -f
# -*- coding: utf-8 -*-

FROM ubuntu:artful
MAINTAINER Philippe Coval (rzr@users.sf.net)

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV LANG ${LC_ALL}

RUN echo "#log: Configuring locales" \
  && set -x \
  && apt-get update -y \
  && apt-get install -y locales \
  && echo "${LC_ALL} UTF-8" | tee /etc/locale.gen \
  && locale-gen ${LC_ALL} \
  && dpkg-reconfigure locales \
  && sync

ENV project snow
ARG SCONSFLAGS
ENV SCONSFLAGS ${SCONSFLAGS:-"VERBOSE=1"}

ARG prefix
ENV prefix ${prefix:-/usr/}
ARG destdir
ENV destdir ${destdir:-/usr/local/opt/${project}}

RUN echo "#log: ${project}: Setup system" \
  && set -x \
  && apt-get update -y \
  && apt-get install -y \
  fakeroot \
  make \
  git \
  sudo \
  dpkg-dev \
  debhelper \
\
  time \
  && apt-get clean \
  && sync

ADD . /usr/local/src/${project}/${project}/
WORKDIR /usr/local/src/${project}/${project}/
RUN echo "#log: ${project}: Preparing sources" \
  && set -x \
  && time ./debian/rules rule/dist \
  && sync

RUN echo "#log: ${project}: Building sources" \
  && set -x \
  && ./debian/rules \
  && sudo debi \
  && ls -la /usr/local/src/${project}/*.* \
  && dpkg -L ${project} \
  && sync

ADD . /usr/local/src/${project}/${project}/
WORKDIR /usr/local/src/${project}/${project}/
RUN echo "#log: ${project}: Post install" \
  && set -x \
  && make install/root \
  && sync

ADD . /usr/local/src/${project}/${project}/
WORKDIR /usr/local/src/${project}/${project}/
RUN echo "#log: ${project}: Run" \
  && set -x \
  && snowd || echo "TODO" \
  && sync

WORKDIR /usr/local/src/${project}/${project}/
RUN echo "#log: ${project}: Check" \
  && set -x \
  && grep "Your key is" /var/log/syslog  || echo "TODO" \
  && sync
