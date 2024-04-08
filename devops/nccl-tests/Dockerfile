###########################################################################
#
# Copyright (c) 2024 ZelosTech.com, Inc. All Rights Reserved
#
###########################################################################
##
# @file nccl-test/Dockerfile
##

ARG BASE_IMG=nvcr.io/nvidia/cuda:11.4.3-cudnn8-devel-ubuntu20.04

FROM $BASE_IMG

# ADD git
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get clean \
    && apt-get update \
    && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --progress https://github.com/NVIDIA/nccl-tests.git /opt/nccl-tests
WORKDIR /opt/nccl-tests

RUN cd /opt/nccl-tests && make