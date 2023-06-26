#!/usr/bin/env bash

set -e

SCRIPT_PATH=$(dirname $(realpath "${BASH_SOURCE[0]}"))
PROJECT_PATH=$(realpath "${SCRIPT_PATH}/..")

FIRMWARE_PATH="$1"

if [ -z "${FIRMWARE_PATH}" ]; then
    echo "Usage: $0 <FIRMWARE_PATH>"
    exit 1
fi

ASSET_PATH="${PROJECT_PATH}/assets/$(basename ${FIRMWARE_PATH%.bin})"


echo "Installing mocks"
for mock in mocks/*/*.so; do

echo "Installing $(basename $mock)"
cp "$mock" "${ASSET_PATH}/rootfs/usr/lib/"

done