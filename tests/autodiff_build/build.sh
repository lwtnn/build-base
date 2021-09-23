#!/bin/bash

cmake \
  -S . \
  -B build
cmake build -L
cmake --build build \
  --clean-first \
  --parallel $(($(nproc) - 1))

echo "Run autodiff example app"
./build/app
