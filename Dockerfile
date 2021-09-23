ARG BASE_IMAGE=gcc:11.1.0
FROM ${BASE_IMAGE} as base

USER root
ENV HOME=/root
WORKDIR /

SHELL [ "/bin/bash", "-c" ]

# Set PATH to pickup virtualenv by default
ENV PATH=/usr/local/venv/bin:"${PATH}"
RUN apt-get update -y && \
    apt-get install -y \
      cmake \
      libhdf5-serial-dev \
      libboost-dev \
      libeigen3-dev \
      tree \
      python3-venv && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m venv /usr/local/venv && \
    . /usr/local/venv/bin/activate && \
    python -m pip --no-cache-dir install --upgrade pip setuptools wheel

ARG TARGET_BRANCH=v0.6.4
RUN git clone --depth 1 https://github.com/autodiff/autodiff.git \
      --branch "${TARGET_BRANCH}" \
      --single-branch && \
    cd autodiff && \
    cmake \
      -S . \
      -B .build && \
    cmake .build -L && \
    cmake --build .build -- -j$(($(nproc) - 1)) && \
    cmake --build .build --target install
