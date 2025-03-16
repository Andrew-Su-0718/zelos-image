FROM silvesterhsu/k8s:next_gen_v1.0.0

ARG TARGETARCH=amd64

# configure id=1000 user & install fundamental packages
#

# common environemnt variables
#ENV NB_USER jovyan
#ENV NB_UID 1000
ENV NB_PREFIX /
ENV HOME /root
ENV SHELL /bin/bash

# args - software versions
ARG KUBECTL_VERSION=v1.20.10
ARG S6_VERSION=v3.2.0.2

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
    ffmpeg \
    git \
    gnupg \
    gnupg2 \
    htop \
    iftop \
    iperf3 \
    libgl1 \
    libgl1-mesa-dev  \
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
    ninja-build \
    openssh-server \
    python3.10-venv \
    rsync \
    sudo \
    unzip \
    vim \
    wget \
    xz-utils \
    zip \
    zsh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# RUN echo 'root:ShARC' | chpasswd && \
#  echo "jovyan ALL=NOPASSWD: /usr/sbin/service ssh start" >> /etc/sudoers && \
#  echo "jovyan ALL=NOPASSWD: /usr/sbin/service ssh restart" >> /etc/sudoers && \
#  echo "jovyan ALL=NOPASSWD: /usr/sbin/service ssh stop" >> /etc/sudoers && \
#  echo "jovyan ALL=NOPASSWD: /usr/sbin/service ssh status" >> /etc/sudoers && \
#  echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
#  echo "jovyan:x:1337:" >> /etc/group && \
#  sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config && \
#  sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config

# install - s6 overlay
RUN case "${TARGETARCH}" in \
      amd64) S6_ARCH="x86_64" ;; \
      arm64) S6_ARCH="aarch64" ;; \
      ppc64le) S6_ARCH="ppc64le" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac \
 && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-noarch.tar.xz" -o /tmp/s6-overlay-noarch.tar.xz \
 && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-noarch.tar.xz.sha256" -o /tmp/s6-overlay-noarch.tar.xz.sha256 \
 && echo "$(cat /tmp/s6-overlay-noarch.tar.xz.sha256 | awk '{ print $1; }')  /tmp/s6-overlay-noarch.tar.xz" | sha256sum -c - \
 && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" -o /tmp/s6-overlay-${S6_ARCH}.tar.xz \
 && curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/s6-overlay-${S6_ARCH}.tar.xz.sha256" -o /tmp/s6-overlay-${S6_ARCH}.tar.xz.sha256 \
 && echo "$(cat /tmp/s6-overlay-${S6_ARCH}.tar.xz.sha256 | awk '{ print $1; }')  /tmp/s6-overlay-${S6_ARCH}.tar.xz" | sha256sum -c - \
 && tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz \
 && tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz \
 && rm /tmp/s6-overlay-noarch.tar.xz  \
       /tmp/s6-overlay-noarch.tar.xz.sha256 \
       /tmp/s6-overlay-${S6_ARCH}.tar.xz \
       /tmp/s6-overlay-${S6_ARCH}.tar.xz.sha256

# install - kubectl
RUN curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" -o /usr/local/bin/kubectl \
 && curl -fsSL "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl.sha256" -o /tmp/kubectl.sha256 \
 && echo "$(cat /tmp/kubectl.sha256 | awk '{ print $1; }')  /usr/local/bin/kubectl" | sha256sum -c - \
 && rm /tmp/kubectl.sha256 \
 && chmod +x /usr/local/bin/kubectl

# # create user and set required ownership
# RUN useradd -M -s /bin/bash -N -u ${NB_UID} ${NB_USER} \
#  && mkdir -p ${HOME} \
#  && chown -R ${NB_USER}:users ${HOME} \
#  && chown -R ${NB_USER}:users /usr/local/bin

# set locale configs
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# USER $NB_UID

ENTRYPOINT ["/init"]

# USER root

# args - software versions
ARG JUPYTERLAB_VERSION=4.3.5
ARG JUPYTER_VERSION=7.3.2
ARG NODE_MAJOR_VERSION=20
ARG PIP_VERSION=24.3.1
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
RUN python -m venv /opt/jupyter
RUN source /opt/jupyter/bin/activate \
    && pip install --no-cache-dir jupyterlab==${JUPYTERLAB_VERSION} notebook==${JUPYTER_VERSION}

# # install - requirements.txt
# COPY --chown=${NB_USER}:users next_gen/requirements.txt /tmp
# RUN python3 -m pip install -r /tmp/requirements.txt --quiet --no-cache-dir \
#  && rm -f /tmp/requirements.txt

# s6 - copy scripts
COPY --chown=${NB_USER}:users --chmod=755 next_gen/s6/ /etc

# s6 - 01-copy-tmp-home
RUN mkdir -p /tmp_home \
 && cp -r ${HOME} /tmp_home

# generate jupyter config
RUN source /opt/jupyter/bin/activate \
 && jupyter notebook --generate-config \
 && jupyter lab --generate-config \
 && jupyter labextension disable "@jupyterlab/apputils-extension:announcements"
# USER $NB_UID

EXPOSE 8888
