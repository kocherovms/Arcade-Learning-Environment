# Builder image for the neurolab ALE fork, targeting Debian 12 (bookworm, glibc 2.36) + Python 3.12.
#
# Analogue of builder22.04.Dockerfile / builder24.04.Dockerfile, but:
#   * base is Debian 12 with Python 3.12 already present — Debian 12 ships no python3.12,
#     and the deadsnakes PPA (Ubuntu-only) / get-pip bootstrap from builder22.04 is not needed;
#   * wheels built here are manylinux_2_36_x86_64 (glibc 2.36), which is exactly what the
#     Debian 12 target needs (the upstream wheels are 2_35 / 2_39, both unusable there);
#   * vcpkg manifest deps (opencv4 for the `vector` feature) are pre-built into the image,
#     so the actual wheel build is fast.
#
# Build the image:
#   docker build -f builder12.Dockerfile -t ale-builder12 .
#
# Build a wheel (mount your ale checkout at /src/ale):
#   docker run --rm -v "$PWD":/src/ale ale-builder12 bash -lc '
#       CMAKE_ARGS="-DSDL_SUPPORT=OFF -DSDL_DYNLOAD=OFF -DBUILD_PYTHON_LIB=ON -DBUILD_VECTOR_LIB=ON" \
#       python3.12 -m build --wheel --no-isolation --outdir=dist/debian12 . &&
#       python3.12 -m wheel tags --platform-tag manylinux_2_36_x86_64 dist/debian12/*.whl'

FROM python:3.12-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Python 3.12 + dev headers are already in /usr/local (official python image).
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        cmake \
        ninja-build \
        tar \
        curl \
        zip \
        unzip \
        pkg-config \
        ca-certificates \
        file \
    && rm -rf /var/lib/apt/lists/*

# Wheel build backends (base image is not PEP-668 managed -> plain pip install).
RUN python3.12 -m pip install --no-cache-dir \
        build \
        nanobind \
        scikit_build_core \
        wheel \
        twine \
        requests \
        jax

# --- vcpkg, pinned to the fork's manifest builtin-baseline for reproducible deps ---
RUN git clone https://github.com/microsoft/vcpkg.git /opt/vcpkg \
    && git -C /opt/vcpkg checkout 3426a5e955f029ab0088ef6656fda06552bd2699 \
    && /opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics

ENV VCPKG_ROOT=/opt/vcpkg
ENV VCPKG_INSTALLATION_ROOT=/opt/vcpkg
ENV PATH="${VCPKG_ROOT}:${PATH}"
ENV VCPKG_DEFAULT_TRIPLET=x64-linux-mixed
ENV VCPKG_FEATURE_FLAGS=-compilertracking

# neurolab sources (NEUROLAB_ROOT is expected by this fork's build tooling).
# RUN git clone https://github.com/kocherovms/neurolab.git /opt/neurolab
# ENV NEUROLAB_ROOT=/opt/neurolab

# --- Pre-warm vcpkg: build the `vector` manifest deps (opencv4 + zlib) once. ---
# The wheel build uses SDL_SUPPORT=OFF + BUILD_VECTOR_LIB=ON, so only `vector` is needed.
# Warming the vcpkg binary cache here makes the per-wheel build fast.
RUN git clone https://github.com/kocherovms/Arcade-Learning-Environment.git /opt/ale-warm
ENV VCPKG_OVERLAY_TRIPLETS=/opt/ale-warm/cmake/custom-triplets
ENV VCPKG_MANIFEST_FEATURES=vector
RUN cd /opt/ale-warm && vcpkg install

# Working directory where your ale checkout gets mounted.
WORKDIR /src/ale

CMD ["/bin/bash"]
