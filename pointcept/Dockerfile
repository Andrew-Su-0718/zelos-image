# ARG BASE_IMG=harbor-volc.zelostech.com.cn:5443/devops/jupyter/jupyter:1.8.0-py3.12-cu12.1.1-ubuntu22.04
ARG BASE_IMG=saz0568/zelos-image:jupyter-1.8.0-cu11.8-ubuntu22.04
# ARG BASE_IMG=harbor.zelostech.com.cn:5443/devops/jupyter/jupyter:1.8.0
ARG NB_USER=jovyan
ARG SYS_USER=root

FROM $BASE_IMG

LABEL maintainer "ZELOS CORPORATION <anzhe.su@zelostech.com>"
USER $SYS_USER

ENV TORCH_CUDA_ARCH_LIST="7.0 7.5 8.0 8.6 8.9+PTX" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    FORCE_CUDA="1"

ENV PATH /opt/conda/bin:$PATH
RUN conda create -y -n pointcept python=3.10 -y
SHELL ["conda", "run", "-n", "pointcept", "/bin/bash", "-c"]

RUN pip3 install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu118
RUN pip3 install numpy==1.24.0 ninja h5py pyyaml sharedarray tensorboard tensorboardx yapf 
RUN pip3 install addict einops scipy plyfile termcolor timm open3d wandb
RUN pip3 install opencv-python numba easydict prettytable
RUN pip3 install spconv-cu118 flash-attn==2.6.3 torch-geometric
RUN pip3 install torch_scatter --no-build-isolation
RUN pip install torch-cluster torch_sparse -f https://data.pyg.org/whl/torch-2.1.0+cu118.html

# cd lidarseg_offline/PointTransformerV3/Pointcept/libs/pointops
# python setup.py install

# ################ to adapt pcseg: ################
# git clone git@github.com:NVIDIA/apex.git
# pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone

USER $NB_USER
ENV NB_PREFIX /
