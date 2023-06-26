#!/usr/bin/env bash

set -e

SCRIPT_PATH=$(dirname $(realpath "${BASH_SOURCE[0]}"))
PROJECT_PATH=$(realpath "${SCRIPT_PATH}/..")

RICOH_OSS_PKG_URL="https://www.ricoh-imaging.co.jp/japan/products/oss/gr-3x/GRIIIx_121.tar.gz"

FIRMWARE_PATH="$1"

if [ -z "${FIRMWARE_PATH}" ]; then
    echo "Usage: $0 <FIRMWARE_PATH>"
    exit 1
fi

ASSET_PATH="${PROJECT_PATH}/assets/$(basename ${FIRMWARE_PATH%.bin})"

if [ ! -d "${PROJECT_PATH}/assets/ricoh-oss/GRIIIx_121" ]; then
    echo "Downloading Ricoh OSS package: ${RICOH_OSS_PKG_URL}"
    mkdir -p "${PROJECT_PATH}/assets/ricoh-oss"
    cd "${PROJECT_PATH}/assets/ricoh-oss"
    curl "${RICOH_OSS_PKG_URL}" | tar -xz
fi

if [ ! -d "${PROJECT_PATH}/kernel" ]; then
    echo "Extracting kernel"
    cd "${PROJECT_PATH}"
    tar -xaf "${PROJECT_PATH}/assets/ricoh-oss/GRIIIx_121/linux-kernel-1.21.2.tar.gz"
    mv linux-* kernel
fi

if [[ "$(docker images -q gr3x-kernel-buildenv 2>/dev/null)" == "" ]]; then
    echo "Building docker buildenv image"
    cd ${PROJECT_PATH}/docker/kernel-buildenv
    DOCKER_BUILDKIT=1 docker build -t gr3x-kernel-buildenv .
fi

echo "Compiling kernel"
cd ${PROJECT_PATH}/kernel
cp ${ASSET_PATH}/kernel.config .config
docker run -it --rm -v $(pwd):/project gr3x-kernel-buildenv /usr/bin/build-kernel.sh
cp arch/arm/boot/zImage ${ASSET_PATH}/
