FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake \
    ninja-build \
    tar \
    curl \
    zip \
    unzip \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install build utility for wheels using native pip
RUN pip3 install --break-system-packages build nanobind scikit_build_core jax

# Install vcpkg toolchain inside the container image to keep it out of your host path
RUN git clone https://github.com/microsoft/vcpkg.git /opt/vcpkg
WORKDIR /opt/vcpkg
RUN ./bootstrap-vcpkg.sh

ENV VCPKG_ROOT=/opt/vcpkg
ENV PATH="${VCPKG_ROOT}:${PATH}"

# The working directory where your host directory gets attached
WORKDIR /src/ale

# Execute compilation when running the container
#CMD cmake -B build -S . \
#    -DCMAKE_TOOLCHAIN_FILE=/opt/vcpkg/scripts/buildsystems/vcpkg.cmake \
#    -G Ninja \
#    -DCMAKE_BUILD_TYPE=Release \
#    -DCMAKE_CXX_STANDARD=17 \
#    -DBUILD_CPP_LIB=ON \
#    -DBUILD_PYTHON_LIB=ON \
#    && cmake --build build \
#    && python3 -m build --wheel
CMD ["/bin/bash"]
