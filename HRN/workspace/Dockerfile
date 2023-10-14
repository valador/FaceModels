FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04
LABEL description="HRN GPU Nvidia Container"

ARG USER_GID="1000"
ARG USER_UID="1000"
ARG USER_NAME="lab"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute,display

ENV PYTHON_VERSION=python3.9

# Update packages
RUN apt-get update --fix-missing \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade

# Install dependencies
RUN apt-get install -y --no-install-recommends \
    # python3-opencv \    
    # python3-dev \
    # python3-distutils \
    bzip2 \
    ca-certificates \
    curl \
    locales \
    sudo \
    wget \
    git \
    # ninja-build \
    software-properties-common
    # libglu1-mesa-dev \
    # python3-pyqt5
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ${PYTHON_VERSION} \
    ${PYTHON_VERSION}-distutils \
    ${PYTHON_VERSION}-dev

# Setup deadsnakes ppa for multiple python versions
# RUN deadsnakes_list="/etc/apt/sources.list.d/deadsnakes.list"; \
#     printf 'deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu jammy main\n' >> $deadsnakes_list \
#     && printf 'deb-src http://ppa.launchpad.net/deadsnakes/ppa/ubuntu jammy main\n' >> $deadsnakes_list \
#     && gpg --keyserver keyserver.ubuntu.com --recv-keys 6A755776 \
#     && gpg --export 6A755776 | apt-key add - \
#     && apt-get update
# RUN apt-get install -y --no-install-recommends \
#     ${PYTHON_VERSION} \
#     ${PYTHON_VERSION}-distutils

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

ENV USER_GID=${USER_GID} \
    USER_UID=${USER_UID} \
    USER_NAME=${USER_NAME} \
    HOME=/home/${USER_NAME} \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SHELL=/bin/bash

# Enable prompt color, generally
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create default user wtih name "lab"
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su \
    && sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers \
    && sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers \
    && useradd -m -s /bin/bash -N -u ${USER_UID} ${USER_NAME} \
    && chmod g+w /etc/passwd \
    && chown -R ${USER_UID}:${USER_GID} ${HOME}

# libnvidia-gl-535 suggested to installed drivers
RUN apt-get install -y --no-install-recommends \
    freeglut3-dev \
    binutils-gold \
    g++ \
    libglew-dev \
    mesa-common-dev \
    build-essential \
    # libglew1.5-dev \
    libglew-dev \
    libglm-dev \
    mesa-utils \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    libnvidia-gl-535 \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6

USER ${USER_NAME}
WORKDIR ${HOME}

ENV PATH=${HOME}/.local/bin:$PATH

RUN ${PYTHON_VERSION} -c "from urllib.request import urlopen; \
    exec(urlopen('https://bootstrap.pypa.io/get-pip.py').read())"

RUN ${PYTHON_VERSION} -m pip install --user --upgrade pip
RUN ${PYTHON_VERSION} -m pip install --user --upgrade setuptools wheel

RUN ${PYTHON_VERSION} -m pip install --user \
    torch==2.0.1+cu117 \
    torchvision==0.15.2+cu117 \
    --index-url https://download.pytorch.org/whl/cu117

RUN ${PYTHON_VERSION} -m pip install --user --no-cache-dir \
    numpy \
    tensorflow==2.11.0 \
    opencv-python \
    opencv-python-headless \
    protobuf \
    tqdm \
    kornia \
    pillow \
    scipy \
    tensorboard \
    scikit-image \
    albumentations \
    torchsummary \
    numba \
    einops \
    trimesh \
    face-alignment \
    ninja \
    imageio \
    cmake \
    lit

RUN ${PYTHON_VERSION} -m pip install --user --no-cache-dir tensorrt && \
    ln -s ${HOME}/.local/lib/python3.9/site-packages/tensorrt_libs/libnvinfer_plugin.so.8 ${HOME}/.local/lib/python3.9/site-packages/tensorrt_libs/libnvinfer_plugin.so.7 && \
    ln -s ${HOME}/.local/lib/python3.9/site-packages/tensorrt_libs/libnvinfer.so.8 ${HOME}/.local/lib/python3.9/site-packages/tensorrt_libs/libnvinfer.so.7

# Custom cache invalidation
# ARG CACHEBUST=1

# Install from github repo
RUN ${PYTHON_VERSION} -m pip install --user --no-cache-dir "git+https://github.com/facebookresearch/fvcore"
RUN ${PYTHON_VERSION} -m pip install --user --no-cache-dir "git+https://github.com/facebookresearch/iopath"

# Fix for build pytorch3d -------------------------------------------------------------------------
RUN curl -LO https://github.com/NVIDIA/cub/archive/2.1.0.tar.gz \
	&& tar xzf 2.1.0.tar.gz \
	&& rm 2.1.0.tar.gz
ENV CUB_HOME=${HOME}/cub-2.1.0

USER root
# RUN apt-get install -y --no-install-recommends software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get update

ENV MAX_GCC_VERSION=11
RUN apt-get install -y --no-install-recommends \
    gcc-$MAX_GCC_VERSION \
    g++-$MAX_GCC_VERSION
RUN ln -s /usr/bin/gcc-$MAX_GCC_VERSION /usr/local/cuda/bin/gcc && \
    ln -s /usr/bin/g++-$MAX_GCC_VERSION /usr/local/cuda/bin/g++
# RUN gcc --version > tmp.txt
# RUN cat tmp.txt
USER ${USER_NAME}
#------------------------------------------------------------------------------------------
# RUN ${PYTHON_VERSION} -m pip install --user "git+https://github.com/facebookresearch/pytorch3d.git"
RUN git clone https://github.com/facebookresearch/pytorch3d.git ${HOME}/pytorch3d
COPY patches ${HOME}/pytorch3d
USER root
RUN chown -R ${USER_UID}:${USER_GID} ${HOME}/pytorch3d
USER ${USER_NAME}
WORKDIR ${HOME}/pytorch3d
RUN git apply cp17.patch
ENV FORCE_CUDA=1
# for my 1080 ti
ENV TORCH_CUDA_ARCH_LIST="Pascal"
ENV CUDA_HOME=/usr/local/cuda
RUN ${PYTHON_VERSION} -m pip install --user --no-cache-dir .

WORKDIR ${HOME}

RUN rm -rf ${HOME}/pytorch3d

RUN ${PYTHON_VERSION} -m pip install --user --no-cache-dir "git+https://github.com/NVlabs/nvdiffrast.git"

RUN git clone --branch adopt https://github.com/valador/HRN_3D_face_reconstruction.git ${HOME}/HRN

# Prepare dirs
# RUN mkdir -p ${HOME}/HRN/assets/3dmm_assets/BFM && \
#     mkdir -p ${HOME}/HRN/assets/3dmm_assets/bfm_albedo_map_basis && \
#     mkdir -p ${HOME}/HRN/assets/3dmm_assets/template_mesh && \
#     mkdir -p ${HOME}/HRN/assets/pretrained_models && \
#     mkdir -p ${HOME}/HRN/assets/pretrained_models/hrn_v1.1

COPY assets/3dmm_assets ${HOME}/HRN/assets/3dmm_assets
COPY assets/pretrained_models ${HOME}/HRN/assets/pretrained_models

USER root

RUN chown -R ${USER_UID}:${USER_GID} ${HOME}/HRN

# Clean packages and caches
RUN apt-get --purge -y remove wget curl git \
    && apt-get --purge -y autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Re-activate user
USER $USER_UID
WORKDIR ${HOME}/HRN
