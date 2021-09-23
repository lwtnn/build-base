ARG BASE_IMAGE=gcc:11.1.0
FROM ${BASE_IMAGE} as base

USER root
ENV HOME=/root
WORKDIR /

SHELL [ "/bin/bash", "-c" ]

# Set PATH to pickup virtualenv by default
ENV PATH=/usr/local/venv/bin:"${PATH}"
ARG AUTODIFF_TARGET_BRANCH=v0.6.4
RUN apt-get update -y && \
    apt-get install -y \
      cmake \
      libhdf5-serial-dev \
      libboost-dev \
      libeigen3-dev \
      catch2 \
      tree \
      python3-dev \
      python3-venv && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m venv /usr/local/venv && \
    . /usr/local/venv/bin/activate && \
    python -m pip --no-cache-dir install --upgrade pip setuptools wheel && \
    python -m pip --no-cache-dir install "pybind11~=2.7.1" && \
    echo "Build and install autodiff" && \
    git clone --depth 1 https://github.com/autodiff/autodiff.git \
      --branch "${AUTODIFF_TARGET_BRANCH}" \
      --single-branch && \
    pushd autodiff && \
    cmake \
      -Dpybind11_DIR=$(dirname $(find /usr/local -name "pybind11Config.cmake")) \
      -DCMAKE_INSTALL_PREFIX=/usr/local/venv \
      -S . \
      -B _build && \
    cmake _build -L && \
    cmake --build _build \
      --clean-first \
      --parallel $(($(nproc) - 1)) && \
    cmake --build _build --target install && \
    popd && \
    rm -rf autodiff
