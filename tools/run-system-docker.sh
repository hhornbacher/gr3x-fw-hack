#!/usr/bin/env bash

set -e

SCRIPT_PATH=$(dirname $(realpath "${BASH_SOURCE[0]}"))
PROJECT_PATH=$(realpath "${SCRIPT_PATH}/..")

FIRMWARE_PATH="$1"

if [ -z "${FIRMWARE_PATH}" ]; then
    echo "Usage: $0 <FIRMWARE_PATH>"
    exit 1
fi

FIRMWARE_NAME="$(basename ${FIRMWARE_PATH%.bin})"
ASSET_PATH="${PROJECT_PATH}/assets/${FIRMWARE_NAME}"

if [[ "$(docker images -q gr3x-system-${FIRMWARE_NAME} 2>/dev/null)" == "" ]]; then
    echo "Building docker system image"
    cd "${PROJECT_PATH}/docker/system"
    rm -rf rootfs
    cp -a "${ASSET_PATH}/rootfs" ./
    docker build -t gr3x-system-${FIRMWARE_NAME} .
fi


docker run \
    -it \
    --rm \
    --privileged \
    --name gr3x-system-${FIRMWARE_NAME} \
    gr3x-system-${FIRMWARE_NAME}