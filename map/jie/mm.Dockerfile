FROM nvcr.io/nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

# 维护者
MAINTAINER jie jie.deng@zelostech.com

ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV TERM screen

# Update timezone and Install Miniconda and Install SSH server
RUN echo "Asia/Shanghai" > /etc/timezone
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get clean \
    && apt-get update \
    && apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get install -y wget ca-certificates sudo git bzip2 libx11-6 openssh-server \
    && rm -rf /var/lib/apt/lists/*
RUN sed -i "s/#   PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/ssh_config && \
        sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN  echo root:123456 | chpasswd

ENV PATH=/opt/conda/bin:$PATH
RUN wget -O ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p /opt/conda \
 && rm ~/miniconda.sh \
 && conda update conda -y
ENV CONDA_AUTO_UPDATE_CONDA=false

# RUN conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/free/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/main/ && \
#     conda config --set show_channel_urls yes && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/conda-forge/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/msys2/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/bioconda/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/caffe2/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/pytorch/

RUN conda create -y --name lanesegnet python=3.8 \
 && conda clean -ya
ENV CONDA_DEFAULT_ENV=lanesegnet
ENV CONDA_PREFIX=/opt/conda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH
SHELL ["conda", "run", "-n", "lanesegnet", "/bin/bash", "-c"]

RUN pip install torch==2.0.0+cu118 torchvision==0.15.0+cu118 -f https://download.pytorch.org/whl/torch_stable.html && pip cache purge && rm -rf /root/.cache/pip
RUN pip install -U openmim && pip cache purge && rm -rf /root/.cache/pip
RUN mim install mmcv-full==1.6.0 mmcls==0.25.0 mmdet==2.26.0 mmdet3d==1.0.0rc6 mmsegmentation==0.29.1 && pip cache purge && rm -rf /root/.cache/pip

