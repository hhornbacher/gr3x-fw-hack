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

for mock in mocks/*; do
    echo "Compiling $(basename $mock)"
    pushd $mock >/dev/null
    cross build --target armv7-unknown-linux-gnueabi
    popd >/dev/null
done

echo "Installing mocks"
for mock in mocks/*/target/armv7-unknown-linux-gnueabi/debug/*.so; do

    mock_basename="$(basename $mock)"
    echo "Installing $mock_basename"
    cp "$mock" "${ASSET_PATH}/rootfs/usr/lib/"

done
