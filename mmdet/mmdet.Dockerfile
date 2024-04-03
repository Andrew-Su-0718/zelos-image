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

# ADD rsync
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get clean \
    && apt-get update \
    && apt-get install -y rsync \
    && rm -rf /var/lib/apt/lists/*

# ADD mmdet/mmdet3.1.0.yml /opt
ADD pkgs /opt/conda/envs/mmdet3.1.0/lib/python3.8/site-packages
ENV PATH /opt/conda/bin:$PATH

# RUN conda init bash
RUN conda create --name mmdet3.1.0 python=3.8 -y && conda clean --all
SHELL ["conda", "run", "-n", "mmdet3.1.0", "/bin/bash", "-c"]
RUN conda install pytorch==1.12.1 torchvision==0.13.1 cudatoolkit=11.3 -c pytorch && conda clean --all
RUN pip install -U openmim==0.3.9 spconv-cu114==2.3.6 && rm -rf /root/.cache/pip
RUN mim install mmengine mmdet==3.1.0 mmdet3d==1.3.0 mmsegmentation==1.1.1 imagecorruptions==1.1.2 pytorch-quantization==2.1.3 psutil==5.9.5 && rm -rf /root/.cache/pip
RUN pip install jupyter==1.0.0 nvitop && rm -rf /root/.cache/pip
# RUN pip install spconv-cu114==2.3.6 && rm -rf /root/.cache/pip
SHELL ["/bin/bash", "-c"]

RUN wget http://101.34.36.92/download/arena_bin.tar.gz -O /tmp/arena_bin.tar.gz && \
  tar -zxvf /tmp/arena_bin.tar.gz -C /usr/local/bin/ && \
  rm /tmp/arena_bin.tar.gz
# RUN /opt/conda/bin/conda env create -f /opt/mmdet3.1.0.yml

ADD mmdet/image /

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone

USER $NB_USER
ENV NB_PREFIX /

# ENTRYPOINT ["/bin/bash", "-c", "rsync --daemon --no-detach && /startup.sh"]
ENTRYPOINT ["/startup.sh"]
