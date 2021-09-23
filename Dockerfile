ARG BASE_IMAGE=gcc:11.1.0
FROM ${BASE_IMAGE} as base

USER root
ENV HOME=/root
WORKDIR /

SHELL [ "/bin/bash", "-c" ]

# Set PATH to pickup virtualenv by default
ENV PATH=/usr/local/venv/bin:"${PATH}"
ARG TARGET_BRANCH=v0.6.4
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
    python -m pip --no-cache-dir install pybind11 && \
    git clone --depth 1 https://github.com/autodiff/autodiff.git \
      --branch "${TARGET_BRANCH}" \
      --single-branch && \
    cd autodiff && \
    cmake \
      -Dpybind11_DIR=$(dirname $(find /usr/local -name "pybind11Config.cmake")) \
      -DCMAKE_INSTALL_PREFIX=/usr/local/venv \
      -S . \
      -B _build && \
    cmake _build -L && \
    cmake --build _build \
      --clean-first \
      --parallel $(($(nproc) - 1)) && \
    cmake --build _build --target install

ARG TARGET_BRANCH=v0.6.4
# export TARGET_BRANCH=v0.6.4
RUN git clone --depth 1 https://github.com/autodiff/autodiff.git \
      --branch "${TARGET_BRANCH}" \
      --single-branch && \
    cd autodiff && \
    apt-get update -y && \
    apt-get install -y \
      catch2 \
      python3-dev && \
    python -m pip --no-cache-dir install pybind11 && \
    cmake \
      -Dpybind11_DIR=$(dirname $(find /usr/local -name "pybind11Config.cmake")) \
      -DCMAKE_INSTALL_PREFIX=/usr/local/venv \
      -S . \
      -B _build && \
    cmake _build -L && \
    cmake --build _build -- -j$(($(nproc) - 1)) && \
    cmake --build _build --target install

# CMake Error at CMakeLists.txt:29 (find_package):
#   By not providing "FindEigen3.cmake" in CMAKE_MODULE_PATH this project has
#   asked CMake to find a package configuration file provided by "Eigen3", but
#   CMake did not find one.

#   Could not find a package configuration file provided by "Eigen3" with any
#   of the following names:

#     Eigen3Config.cmake
#     eigen3-config.cmake

#   Add the installation prefix of "Eigen3" to CMAKE_PREFIX_PATH or set
#   "Eigen3_DIR" to a directory containing one of the above files.  If "Eigen3"
#   provides a separate development package or SDK, be sure it has been
#   installed.


# -- Configuring incomplete, errors occurred!
