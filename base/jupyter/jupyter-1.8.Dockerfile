#
# NOTE: Use the Makefiles to build this image correctly.
#

ARG BASE_IMG=saz0568/zelos-image:jupyter-base-cu12.1.1-ubuntu22.04
FROM $BASE_IMG

ARG TARGETARCH=amd64

USER root

# args - software versions
# ARG JUPYTERLAB_VERSION=3.6.6
ARG JUPYTERLAB_VERSION=4.2.1
# ARG JUPYTER_VERSION=6.5.6
ARG JUPYTER_VERSION=7.2.0
# ARG MINIFORGE_VERSION=23.3.1-1
# ARG MINIFORGE_VERSION=24.3.0-0
ARG MINIFORGE_VERSION=25.3.0-3
ARG NODE_MAJOR_VERSION=18
# ARG PIP_VERSION=23.2.1
ARG PIP_VERSION=25.0.1
# ARG PYTHON_VERSION=3.11.6
# ARG PYTHON_VERSION=3.8.19
ARG PYTHON_VERSION=3.12.11

# install -- node.js
RUN export DEBIAN_FRONTEND=noninteractive \
 && curl -sL "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" | apt-key add - \
 && echo "deb https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
 && apt-get -yq update \
 && apt-get -yq install --no-install-recommends \
    nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# setup environment for conda
ENV CONDA_DIR /opt/conda
ENV PATH "${CONDA_DIR}/bin:${PATH}"
RUN mkdir -p ${CONDA_DIR} \
 && echo ". /opt/conda/etc/profile.d/conda.sh" >> ${HOME}/.bashrc \
 && echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/profile \
 && echo "conda activate base" >> ${HOME}/.bashrc \
 && echo "conda activate base" >> /etc/profile \
 && chown -R ${NB_USER}:users ${CONDA_DIR} \
 && chown -R ${NB_USER}:users ${HOME}

# switch to NB_UID for installs
# USER $NB_UID

# install - conda, pip, python, jupyter
RUN case "${TARGETARCH}" in \
      amd64) MINIFORGE_ARCH="x86_64" ;; \
      arm64) MINIFORGE_ARCH="aarch64" ;; \
      ppc64le) MINIFORGE_ARCH="ppc64le" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac \
 && curl -fsSL "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-${MINIFORGE_ARCH}.sh" -o /tmp/Miniforge3.sh \
 && curl -fsSL "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge3-${MINIFORGE_VERSION}-Linux-${MINIFORGE_ARCH}.sh.sha256" -o /tmp/Miniforge3.sh.sha256 \
 && echo "$(cat /tmp/Miniforge3.sh.sha256 | awk '{ print $1; }')  /tmp/Miniforge3.sh" | sha256sum -c - \
 && rm /tmp/Miniforge3.sh.sha256 \
 && /bin/bash /tmp/Miniforge3.sh -b -f -p ${CONDA_DIR} \
 && rm /tmp/Miniforge3.sh \
 && conda config --system --set auto_update_conda false \
 && conda config --system --set show_channel_urls true \
 && echo "python ==${PYTHON_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && conda install -y -q \
    python=${PYTHON_VERSION} \
    pip=${PIP_VERSION} \
 && conda update -y -q --all \
 && conda clean -a -f -y

# install - jupyter
RUN echo "jupyterlab ==${JUPYTERLAB_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && echo "notebook ==${JUPYTER_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned \
 && conda install -y -q \
    jupyterlab==${JUPYTERLAB_VERSION} \
    notebook==${JUPYTER_VERSION} \
 && conda clean -a -f -y

# install - requirements.txt
COPY --chown=${NB_USER}:users base/jupyter/requirements.txt /tmp
RUN python3 -m pip install -r /tmp/requirements.txt --quiet --no-cache-dir \
 && rm -f /tmp/requirements.txt

# s6 - copy scripts
COPY --chown=${NB_USER}:users --chmod=755 base/jupyter/s6/ /etc

# s6 - 01-copy-tmp-home
USER root
RUN mkdir -p /tmp_home \
 && cp -r ${HOME} /tmp_home \
 && chown -R ${NB_USER}:users /tmp_home

# generate jupyter config
RUN jupyter notebook --generate-config \
 && jupyter lab --generate-config \
 && jupyter labextension disable "@jupyterlab/apputils-extension:announcements"
USER $NB_UID

EXPOSE 8888
