#!/bin/bash
set -e
mkdir -p build
pushd build
cmake ../ -DCMAKE_BUILD_TYPE=Release -DPython_EXECUTABLE=/usr/bin/python3.12 -DBUILD_CPP_LIB=ON -DBUILD_PYTHON_LIB=ON -DBUILD_VECTOR_LIB=ON
cmake --build . --target install
popd
