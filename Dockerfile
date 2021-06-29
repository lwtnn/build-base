ARG BUILDER_IMAGE=gcc:11.1.0
FROM ${BUILDER_IMAGE} as builder

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
    python3 -m venv /usr/local/venv
    . /usr/local/venv/bin/activate && \
    python -m pip --no-cache-dir install --upgrade pip setuptools wheel
