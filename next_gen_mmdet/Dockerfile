FROM saz0568/zelos-image:pantheon-next_gen_base

ARG PYTORCH="2.5.1"
ARG CUDA="12.1"
ARG CUDNN="8"
ARG MMCV="2.1.0"

USER root

ENV TORCH_CUDA_ARCH_LIST="7.0 7.5 8.0 8.6 8.9+PTX" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    FORCE_CUDA="1"
# ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

# To fix GPG key error when running apt-get update
# RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
# RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

# Install MMCV
ARG PYTORCH="2.5.1"
ARG CUDA="12.2"
ARG MMCV="2.1.0"
RUN ["/bin/bash", "-c", "pip install openmim"]
# RUN ["/bin/bash", "-c", "mim install mmengine"]

# Install mmcv
RUN pip install opencv-python-headless
RUN git clone --depth 1 --branch v2.1.0 https://github.com/open-mmlab/mmcv.git /mmcv \
    && cd /mmcv \
    && pip install -r requirements/optional.txt \
    && pip install -e . -v
# RUN ["/bin/bash", "-c", "mim install mmcv==${MMCV}"]

# Install MMDetection
RUN git clone --depth 1 --branch v3.3.0 https://github.com/open-mmlab/mmdetection.git /mmdetection \
    && cd /mmdetection \
    && pip install --no-cache-dir -e .

# Install MMDetection3D
RUN git clone --depth 1 --branch v1.4.0 https://github.com/open-mmlab/mmdetection3d.git /mmdetection3d \
    && cd /mmdetection3d \
    && pip install --no-cache-dir -e .

# Install MMSegmentation
RUN git clone --depth 1 --branch v1.2.2 https://github.com/open-mmlab/mmsegmentation.git /mmsegmentation
WORKDIR /mmsegmentation
RUN pip install -r requirements.txt
RUN pip install --no-cache-dir -e .

# Install MMPretrain
RUN git clone --depth 1 --branch v1.2.0 https://github.com/open-mmlab/mmpretrain.git /mmpretrain
WORKDIR /mmpretrain
RUN mim install --no-cache-dir -e .

# Install extra dependencies
WORKDIR /next_gen
COPY next_gen_mmdet/requirements-extra.txt /next_gen/
RUN pip install datasets==2.19.1 --no-cache-dir \
 && pip install -r requirements-extra.txt --no-cache-dir

# (Warning) Jupyter official Dockerfile requires software-properties-common packages. But this would install python dist-package, which may have conflicts with mm installation
# RUN apt-get -yq update \
#  && apt -yq install --no-install-recommends software-properties-common \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*

WORKDIR ${HOME}
# USER $NB_UID
