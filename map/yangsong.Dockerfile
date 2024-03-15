FROM nvcr.io/nvidia/tensorrt:22.12-py3

# 维护者
MAINTAINER yangsong song.yang@zelostech.com

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
# ENV PATH=/opt/conda/bin:$PATH
# RUN wget -O ~/miniconda.sh https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
#  && chmod +x ~/miniconda.sh \
#  && ~/miniconda.sh -b -p /opt/conda \
#  && rm ~/miniconda.sh \
#  && conda update conda
# ENV CONDA_AUTO_UPDATE_CONDA=false
# 
# RUN conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/free/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/pkgs/main/ && \
#     conda config --set show_channel_urls yes && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/conda-forge/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/msys2/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/bioconda/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/caffe2/ && \
#     conda config --add channels https://mirrors.bfsu.edu.cn/anaconda/cloud/pytorch/
# 
# RUN conda create -y --name python38 python=3.8 \
#  && conda clean -ya
# ENV CONDA_DEFAULT_ENV=python38
# ENV CONDA_PREFIX=/opt/conda/envs/$CONDA_DEFAULT_ENV
# ENV PATH=$CONDA_PREFIX/bin:$PATH

RUN pip install torch==1.12.1+cu116 torchvision==0.13.1+cu116 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu116
