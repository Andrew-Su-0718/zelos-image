FROM saz0568/zelos-image:pantheon-mmdet3.1.0_next_gen_20250311

ENV TORCH_CUDA_ARCH_LIST="7.0 7.5 8.0 8.6 8.9+PTX" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    FORCE_CUDA="1"

WORKDIR /next_gen
COPY next_gen/requirements-extra.txt /next_gen/
RUN pip install -r requirements-extra.txt -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

ARG TARGETARCH=amd64

# common environemnt variables
ENV NB_USER jovyan
ENV NB_UID 1000
ENV NB_PREFIX /
ENV HOME /home/$NB_USER
ENV SHELL /bin/bash

# args - software versions
ARG KUBECTL_VERSION=v1.20.10
ARG S6_VERSION=v3.1.6.2

# set shell to bash
SHELL ["/bin/bash", "-c"]

# install - usefull linux packages
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -yq update \
 && apt-get install -y tzdata \
 && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && dpkg-reconfigure --frontend noninteractive tzdata \
 && apt-get -yq install --no-install-recommends \
    apt-transport-https \
    bash \
    bind9-dnsutils \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    git \
    gnupg \
    gnupg2 \
    htop \
    iftop \
    iperf3 \
    libgl1 \
    libglib2.0-0 \
    libboost-filesystem-dev \
    libboost-dev \
    libsm6 \
    libxext6 \
    libxrender-dev \
    locales \
    lsb-release \
    nano \
    nethogs \
    net-tools \
    openssh-server \
    python3.10-venv \
    rsync \
    software-properties-common \
    sudo \
    unzip \
    vim \
    wget \
    xz-utils \
    zip \
    zsh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN echo 'root:ShARC' | chpasswd && \
 echo "jovyan ALL=NOPASSWD: /usr/sbin/service ssh start" >> /etc/sudoers && \
 echo "jovyan ALL=NOPASSWD: /usr/sbin/service ssh restart" >> /etc/sudoers && \
 echo "jovyan ALL=NOPASSWD: /usr/sbin/service ssh stop" >> /etc/sudoers && \
 echo "jovyan ALL=NOPASSWD: /usr/sbin/service ssh status" >> /etc/sudoers && \
 echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
 echo "jovyan:x:1337:" >> /etc/group && \
 sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config && \
 sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

## install - s6 overlay
#RUN case "${TARGETARCH}" in \
#      amd64) S6_ARCH="x86_64" ;; \
#      arm64) S6_ARCH="aarch64" ;; \
#      ppc64le) S6_ARCH="ppc64le" ;; \
#      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
#    esac \
# && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-noarch.tar.xz" -o /tmp/s6-overlay-noarch.tar.xz \
# && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-noarch.tar.xz.sha256" -o /tmp/s6-overlay-noarch.tar.xz.sha256 \
# && echo "$(cat /tmp/s6-overlay-noarch.tar.xz.sha256 | awk '{ print $1; }')  /tmp/s6-overlay-noarch.tar.xz" | sha256sum -c - \
# && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" -o /tmp/s6-overlay-${S6_ARCH}.tar.xz \
# && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.xz.sha256" -o /tmp/s6-overlay-${S6_ARCH}.tar.xz.sha256 \
# && echo "$(cat /tmp/s6-overlay-${S6_ARCH}.tar.xz.sha256 | awk '{ print $1; }')  /tmp/s6-overlay-${S6_ARCH}.tar.xz" | sha256sum -c - \
# && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
# && tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz \
# && rm /tmp/s6-overlay-noarch.tar.xz  \
#       /tmp/s6-overlay-noarch.tar.xz.sha256 \
#       /tmp/s6-overlay-${S6_ARCH}.tar.xz \
#       /tmp/s6-overlay-${S6_ARCH}.tar.xz.sha256

## install - kubectl
#RUN curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" -o /usr/local/bin/kubectl \
# && curl -fsSL "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl.sha256" -o /tmp/kubectl.sha256 \
# && echo "$(cat /tmp/kubectl.sha256 | awk '{ print $1; }')  /usr/local/bin/kubectl" | sha256sum -c - \
# && rm /tmp/kubectl.sha256 \
# && chmod +x /usr/local/bin/kubectl

# create user and set required ownership
RUN useradd -M -s /bin/bash -N -u ${NB_UID} ${NB_USER} \
 && mkdir -p ${HOME} \
 && chown -R ${NB_USER}:users ${HOME} \
 && chown -R ${NB_USER}:users /usr/local/bin

# set locale configs
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

USER $NB_UID

#ENTRYPOINT ["/init"]

USER root

# args - software versions
ARG JUPYTERLAB_VERSION=4.2.1
ARG JUPYTER_VERSION=7.2.0
ARG MINIFORGE_VERSION=24.3.0-0
ARG NODE_MAJOR_VERSION=18
ARG PIP_VERSION=23.2.1
ARG PYTHON_VERSION=3.10

# install -- node.js
RUN export DEBIAN_FRONTEND=noninteractive \
 && curl -sL "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" | apt-key add - \
 && echo "deb https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
 && apt-get -yq update \
 && apt-get -yq install --no-install-recommends \
    nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# install - jupyter
RUN pip install --no-cache-dir \
    jupyterlab==${JUPYTERLAB_VERSION} \
    notebook==${JUPYTER_VERSION} -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

# # install - requirements.txt
# COPY --chown=${NB_USER}:users next_gen/requirements.txt /tmp
# RUN python3 -m pip install -r /tmp/requirements.txt --quiet --no-cache-dir \
#  && rm -f /tmp/requirements.txt

## s6 - copy scripts
#COPY --chown=${NB_USER}:users --chmod=755 next_gen/s6/ /etc
#
## s6 - 01-copy-tmp-home
#RUN mkdir -p /tmp_home \
# && cp -r ${HOME} /tmp_home \
# && chown -R ${NB_USER}:users /tmp_home
#
# generate jupyter config
RUN jupyter notebook --generate-config \
 && jupyter lab --generate-config \
 && jupyter labextension disable "@jupyterlab/apputils-extension:announcements"
USER $NB_UID

EXPOSE 8888
