FROM silvesterhsu/k8s:next_gen_v1.0.0
# FROM harbor.zelostech.com.cn:5443/perception/pantheon:next_gen_v1.0.0

ARG PYTORCH="2.5.1"
ARG CUDA="12.2"
ARG CUDNN="8"
ARG MMCV="2.0.1"

ENV TORCH_CUDA_ARCH_LIST="7.0 7.5 8.0 8.6 8.9+PTX" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    FORCE_CUDA="1"
# ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"

# To fix GPG key error when running apt-get update
# RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub
# RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

RUN apt-get update \
    && apt-get install -y ffmpeg git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 libgl1-mesa-dev  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# RUN conda clean --all

# Install MMCV
ARG PYTORCH="2.5.1"
ARG CUDA="12.2"
ARG MMCV="2.0.1"
RUN ["/bin/bash", "-c", "pip install openmim"]
RUN ["/bin/bash", "-c", "mim install mmengine"]

# Install mmcv
RUN pip install opencv-python-headless
RUN git clone --depth 1 --branch v2.0.1 https://github.com/open-mmlab/mmcv.git /mmcv \
    && cd /mmcv \
    && pip install -r requirements/optional.txt \
    && pip install -e . -v
# RUN ["/bin/bash", "-c", "mim install mmcv==${MMCV}"]

# Install MMDetection
RUN git clone --depth 1 --branch v3.1.0 https://github.com/open-mmlab/mmdetection.git /mmdetection \
    && cd /mmdetection \
    && pip install --no-cache-dir -e .

# Install MMDetection3D
RUN git clone --depth 1 --branch v1.3.0 https://github.com/open-mmlab/mmdetection3d.git /mmdetection3d \
    && cd /mmdetection3d \
    && pip install --no-cache-dir -e .

# Install MMSegmentation
RUN git clone --depth 1 --branch v1.1.1 https://github.com/open-mmlab/mmsegmentation.git /mmsegmentation
WORKDIR /mmsegmentation
RUN pip install -r requirements.txt
RUN pip install --no-cache-dir -e .

# Install MMPretrain
RUN git clone --depth 1 --branch v1.1.0 https://github.com/open-mmlab/mmpretrain.git /mmpretrain
WORKDIR /mmpretrain
RUN mim install --no-cache-dir -e .
