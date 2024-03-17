###########################################################################
#
# Copyright (c) 2023 ZelosTech.com, Inc. All Rights Reserved
#
###########################################################################
##
# @file lidar_detect.Dockerfile
##

ARG BASE_IMG=silvesterhsu/k8s:cuda11.4-cudnn8.2.4-ubuntu20.04_v1.1.1
ARG NB_USER=jovyan
ARG SYS_USER=root

FROM $BASE_IMG

USER $SYS_USER

ADD mmdet/mmdet3.1.0.yml /opt
ADD pkgs /opt/conda/envs/mmdet3.1.0/lib/python3.8/site-packages

RUN wget http://101.34.36.92/download/arena_bin.tar -O /tmp/arena_bin.tar && \
  tar -xvf /tmp/arena_bin.tar -C /usr/local/bin/ && \
  rm /tmp/arena_bin.tar
RUN /opt/conda/bin/conda env create -f /opt/mmdet3.1.0.yml

ADD mmdet/image /

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone

USER $NB_USER
ENV NB_PREFIX /

ENTRYPOINT ["/startup.sh"]

