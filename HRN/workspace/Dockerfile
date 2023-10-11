FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04
LABEL description="HRN GPU Nvidia Container"

ARG USER_GID="100"
ARG USER_UID="1000"
ARG USER_NAME="lab"
# ARG FFMPEG_VERSION="5.1.2"
ARG TINI_VERSION="v0.19.0"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute,display
ENV TINI_VERSION=${TINI_VERSION}
# ENV HRN_PATH=/usr/local/HRN
ENV CUDA_HOME /usr/local/cuda-11.8

# Update packages
RUN apt-get update --fix-missing \
    && apt-get -y upgrade \
    && apt-get -y dist-upgrade

# Install dependencies
RUN apt-get install -y --no-install-recommends \
    python3-opencv \    
    python3-dev \
    python3-distutils \
    bzip2 \
    ca-certificates \
    curl \
    locales \
    sudo \
    wget \
    git \
    ninja-build
    # libglu1-mesa-dev \
    # python3-pyqt5

    # Setup deadsnakes ppa for multiple python versions
# RUN deadsnakes_list="/etc/apt/sources.list.d/deadsnakes.list"; \
#     printf 'deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu jammy main\n' >> $deadsnakes_list \
#     && printf 'deb-src http://ppa.launchpad.net/deadsnakes/ppa/ubuntu jammy main\n' >> $deadsnakes_list \
#     && gpg --keyserver keyserver.ubuntu.com --recv-keys 6A755776 \
#     && gpg --export 6A755776 | apt-key add - \
#     && apt-get update
# RUN apt-get install -y --no-install-recommends \
#     python3.8 \
#     python3.8-distutils

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

# Install Tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

USER ${USER_NAME}
WORKDIR ${HOME}

ENV PATH=${HOME}/.local/bin:$PATH

RUN python3 -c "from urllib.request import urlopen; \
    exec(urlopen('https://bootstrap.pypa.io/get-pip.py').read())"

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade setuptools wheel
RUN python3 -m pip install --user tensorboard cmake   # cmake from apt-get is too old
RUN python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

RUN python3 -m pip install \
    numpy==1.24.3 \
    tensorflow==2.13.0
# rotobuf tensorboard
RUN python3 -m pip install \
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
    imageio

# Custom cache invalidation
# ARG CACHEBUST=1

# Install from github repo
RUN git clone https://github.com/youngLBW/HRN.git

RUN python3 -m pip install "git+https://github.com/NVlabs/nvdiffrast.git"

USER root
RUN addgroup ${USER_NAME} video
ENV FORCE_CUDA=1

USER ${USER_NAME}
WORKDIR ${HOME}

RUN curl -LO https://github.com/NVIDIA/cub/archive/2.1.0.tar.gz \
	&& tar xzf 2.1.0.tar.gz \
	&& rm 2.1.0.tar.gz
ENV CUB_HOME=${HOME}/cub-2.1.0

RUN python3 -m pip install --user "git+https://github.com/facebookresearch/fvcore"
RUN python3 -m pip install --user "git+https://github.com/facebookresearch/iopath"

RUN python3 -m pip install "git+https://github.com/facebookresearch/pytorch3d.git"

USER root

# Install dependencies dvdiffast
RUN apt-get install -y --no-install-recommends \
    freeglut3-dev \
    binutils-gold \
    g++ \
    cmake \
    libglew-dev \
    mesa-common-dev \
    build-essential \
    libglew1.5-dev \
    libglm-dev \
    mesa-utils \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    libnvidia-gl-535

# Clean packages and caches
RUN apt-get --purge -y remove wget curl git \
    && apt-get --purge -y autoremove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
    # && chown ${USER_UID}:${USER_GID} ${HOME}

# Configure container startup
# ENTRYPOINT [ "/tini", "-g", "--" ]
CMD [ "/bin/bash" ]

# Re-activate user "lab"
USER $USER_UID
WORKDIR ${HOME}
