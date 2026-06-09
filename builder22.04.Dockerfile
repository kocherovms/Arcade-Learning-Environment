FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install modern compiler frameworks and the deadsnakes PPA for Python 3.12
RUN apt-get update && apt-get install -y software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake \
    ninja-build \
    tar \
    curl \
    zip \
    unzip \
    pkg-config \
    python3.12 \
    python3.12-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.12 manually since it's an external PPA package
RUN curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3.12 get-pip.py
RUN rm get-pip.py

# Install the build package specifically under Python 3.12
RUN python3.12 -m pip install build nanobind scikit_build_core jax requests
RUN python3.12 -m pip install wheel
RUN python3.12 -m pip install twine

# Install vcpkg toolchain inside the container image
RUN git clone https://github.com/microsoft/vcpkg.git /opt/vcpkg
WORKDIR /opt/vcpkg
RUN ./bootstrap-vcpkg.sh

ENV VCPKG_ROOT=/opt/vcpkg
ENV PATH="${VCPKG_ROOT}:${PATH}"

RUN git clone https://github.com/kocherovms/neurolab.git /opt/neurolab
ENV NEUROLAB_ROOT=/opt/neurolab

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

