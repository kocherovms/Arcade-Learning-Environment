#!/bin/bash
set -e
. /etc/lsb-release

case "$DISTRIB_RELEASE" in
    "22.04")
        platform_tag="manylinux_2_35_x86_64"
        ;;
    "24.04")
        platform_tag="manylinux_2_39_x86_64"
        ;;
    *)
        echo "Unknown DISTRIB_RELEASE=\"$DISTRIB_RELEASE\""
	exit 1
        ;;
esac

[ -d "dist/$DISTRIB_RELEASE" ] && rm -f dist/$DISTRIB_RELEASE/*

CMAKE_ARGS="-DSDL_SUPPORT=OFF -DSDL_DYNLOAD=OFF -DBUILD_PYTHON_LIB=ON -DBUILD_VECTOR_LIB=ON" python3.12 -m build --wheel --no-isolation --outdir=dist/$DISTRIB_RELEASE 
python3.12 -m wheel tags --platform-tag $platform_tag dist/$DISTRIB_RELEASE/*.whl

export TWINE_USERNAME="bot"
export TWINE_PASSWORD="bot"

case "$DISTRIB_RELEASE" in
    "22.04")
	twine upload --repository-url http://nexus:8081/repository/neurolab-pypi/ dist/22.04/*manylinux*.whl
        ;;
    "24.04")
	twine upload --repository-url http://nexus:8081/repository/neurolab-pypi/ dist/24.04/*manylinux*.whl
        ;;
    *)
        echo "Unknown DISTRIB_RELEASE=\"$DISTRIB_RELEASE\""
	exit 1
        ;;
esac
