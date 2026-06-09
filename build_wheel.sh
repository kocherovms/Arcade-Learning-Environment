#!/bin/bash
. /etc/lsb-release
CMAKE_ARGS="-DSDL_SUPPORT=OFF -DSDL_DYNLOAD=OFF -DBUILD_PYTHON_LIB=ON -DBUILD_VECTOR_LIB=ON" python3.12 -m build --wheel --no-isolation --outdir=dist/$DISTRIB_RELEASE
