#!/bin/bash
set -e

# Detect the distro/platform tag from /etc/os-release (works on both Debian and Ubuntu).
# Falls back to /etc/lsb-release for older Ubuntu images that only ship that file.
if [ -r /etc/os-release ]; then
    . /etc/os-release
    distro_id="${ID:-}"
    distro_ver="${VERSION_ID:-}"
elif [ -r /etc/lsb-release ]; then
    . /etc/lsb-release
    distro_id="${DISTRIB_ID:-}"
    distro_ver="${DISTRIB_RELEASE:-}"
else
    echo "Cannot detect distro: neither /etc/os-release nor /etc/lsb-release found"
    exit 1
fi

# Normalize the distro id ($ID is lowercase on Debian, $DISTRIB_ID capitalized on old Ubuntu).
distro_id="$(echo "$distro_id" | tr '[:upper:]' '[:lower:]')"
# VERSION_ID may be quoted (e.g. "22.04"); strip quotes.
distro_ver="${distro_ver%\"}"
distro_ver="${distro_ver#\"}"

platform_tag=""
case "$distro_id-$distro_ver" in
    ubuntu-22.04)
        platform_tag="manylinux_2_35_x86_64"
        ;;
    ubuntu-24.04)
        platform_tag="manylinux_2_39_x86_64"
        ;;
    debian-12)
        platform_tag="manylinux_2_36_x86_64"
        ;;
    *)
        echo "Unknown distro \"$distro_id $distro_ver\""
        exit 1
        ;;
esac

# Directory name mirrors the distro, e.g. dist/debian12 / dist/ubuntu22.04
dist_dir="${distro_id}${distro_ver}"
python_bin="${PYTHON:-python3.12}"

[ -d "dist/$dist_dir" ] && rm -f dist/$dist_dir/*

CMAKE_ARGS="-DSDL_SUPPORT=OFF -DSDL_DYNLOAD=OFF -DBUILD_PYTHON_LIB=ON -DBUILD_VECTOR_LIB=ON" \
    "$python_bin" -m build --wheel --no-isolation --outdir="dist/$dist_dir"
"$python_bin" -m wheel tags --platform-tag "$platform_tag" dist/$dist_dir/*.whl

export TWINE_USERNAME="bot"
export TWINE_PASSWORD="bot"

twine upload --repository-url http://nexus:8081/repository/neurolab-pypi/ "dist/$dist_dir/"*manylinux*.whl
