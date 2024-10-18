FROM saz0568/zelos-image:jupyter-1.8.0-cu11.8-ubuntu22.04

# 维护者
MAINTAINER anzhe.su anzhe.su@zelostech.com

ARG NB_USER=jovyan
ARG SYS_USER=root
USER $SYS_USER

RUN conda create -y --name yolo_world python=3.8 \
 && conda clean -ya
ENV CONDA_DEFAULT_ENV=yolo_world
ENV CONDA_PREFIX=/opt/conda/envs/$CONDA_DEFAULT_ENV
ENV PATH=$CONDA_PREFIX/bin:$PATH
SHELL ["conda", "run", "-n", "yolo_world", "/bin/bash", "-c"]

RUN pip install torch==1.13.1+cu117 \
    torchvision==0.14.1+cu117 \
    torchaudio==0.13.1 \
    --extra-index-url https://download.pytorch.org/whl/cu117 \
 && pip cache purge \
 && rm -rf /root/.cache/pip

RUN pip install mmyolo@git+https://github.com/onuralpszr/mmyolo.git \
    loguru \
    git+https://github.com/lvis-dataset/lvis-api.git \
 && pip cache purge \
 && rm -rf /root/.cache/pip

RUN apt-get -yq update \
 && apt-get install git-lfs \
 && git lfs install \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER $NB_USER