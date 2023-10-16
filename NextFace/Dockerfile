# FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04
FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu20.04

LABEL description="NextFace GPU Nvidia Container"

ARG USER_GID="1000"
ARG USER_UID="1000"
ARG USER_NAME="lab"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute,display

# redner-gpu not support python 3.9
ENV PYTHON_VERSION=python3.8

# Update packages
RUN apt-get update --fix-missing \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade
RUN apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    locales \
    sudo \
    wget \
    git \
    software-properties-common \
    python3-distutils \
    python3-dev

ENV USER_GID=${USER_GID} \
    USER_UID=${USER_UID} \
    USER_NAME=${USER_NAME} \
    HOME=/home/${USER_NAME} \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    SHELL=/bin/bash

ENV PROJECT_PATH=${HOME}/NextFace

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

# Enable prompt color, generally
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create default user
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su \
    && sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers \
    && sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers \
    && useradd -m -s /bin/bash -N -u ${USER_UID} --shell=${SHELL} ${USER_NAME} \
    && chmod g+w /etc/passwd \
    && chown -R ${USER_UID}:${USER_GID} ${HOME}

# add repo to custom Python version
# RUN add-apt-repository ppa:deadsnakes/ppa && \
#     apt-get update && \
#     apt-get install -y --no-install-recommends \
#     ${PYTHON_VERSION} \
#     ${PYTHON_VERSION}-distutils \
#     ${PYTHON_VERSION}-dev

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

# from conda python or cpp? this cpp version
RUN apt-get install -y --no-install-recommends \
    libopencv-dev

USER ${USER_NAME}
WORKDIR ${HOME}

ENV PATH=${HOME}/.local/bin:$PATH

RUN python3 -c "from urllib.request import urlopen; \
    exec(urlopen('https://bootstrap.pypa.io/get-pip.py').read())"

RUN python3 -m pip install --user --upgrade pip
RUN python3 -m pip install --user --upgrade setuptools wheel

# 1.13.1 not support 11.8, need python 3.9
RUN python3 -m pip install --user \
    torch==2.0.1+cu117 \
    torchvision==0.15.2+cu117 \
    --index-url https://download.pytorch.org/whl/cu117

RUN python3 -m pip install --user --no-cache-dir \
    redner-gpu \
    face_alignment \
    h5py \
    opencv-python \
    mediapipe \
    mitsuba \
    numpy

# Custom cache invalidation
ARG CACHEBUST=0

RUN git clone --branch clean_code https://github.com/valador/NextFace.git ${PROJECT_PATH}

COPY NextFace/models ${PROJECT_PATH}/baselMorphableModel

USER root

RUN chown -R ${USER_UID}:${USER_GID} ${PROJECT_PATH}/baselMorphableModel

# Clean packages and caches
RUN apt-get --purge -y remove wget curl git \
    && apt-get --purge -y autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

USER ${USER_NAME}
WORKDIR ${PROJECT_PATH}
