#!/usr/bin/env bash

set -e

SCRIPT_PATH=$(dirname $(realpath "${BASH_SOURCE[0]}"))
PROJECT_PATH=$(realpath "${SCRIPT_PATH}/..")

GR_UNPACK="${SCRIPT_PATH}/ext/gr_unpack/gr_unpack.py"

FIRMWARE_PATH="$1"

if [ -z "${FIRMWARE_PATH}" ]; then
    echo "Usage: $0 <FIRMWARE_PATH>"
    exit 1
fi

ASSET_PATH="${PROJECT_PATH}/assets/$(basename ${FIRMWARE_PATH%.bin})"

mkdir -p "${ASSET_PATH}"

if [ ! -f "${ASSET_PATH}/unpackedFW" ] ; then
echo "Decoding firmware image: ${FIRMWARE_PATH}..."
${GR_UNPACK} -o "${ASSET_PATH}/unpackedFW" "${FIRMWARE_PATH}" > /dev/null
fi

pushd "${ASSET_PATH}" >/dev/null

if [ ! -d "_unpackedFW.extracted" ] ; then
echo "Extracting data..."
binwalk -e unpackedFW > /dev/null
fi

ROOTFS_CPIO="$(file _unpackedFW.extracted/* | grep cpio | cut -d':' -f1)"
ROMFS="$(file _unpackedFW.extracted/* | grep "romfs filesystem" | cut -d':' -f1)"

if [ ! -d "rootfs" ] ; then
echo "Extracting rootfs..."
mkdir -p rootfs
pushd rootfs >/dev/null
cpio --extract <"../${ROOTFS_CPIO}" 2>/dev/null
popd >/dev/null
fi

if [ ! -d "romfs" ] ; then
echo "Extracting romfs..."
mkdir -p romfs
mkdir -p mnt
echo "In order to mount the romfs for extraction the next command needs to be run with sudo"
echo "${ROMFS}"
sudo mount -t romfs "${ROMFS}" mnt
set +e
cp -a mnt/* romfs/
set -e
sudo umount mnt
rmdir mnt

echo "Extracting kernel config..."
binwalk --dd='.*' romfs/boot/Image-nolpae > /dev/null
binwalk --dd='.*' romfs/boot/_Image-nolpae.extracted/31CF > /dev/null

KERNEL_CONFIG_PATH="$(file romfs/boot/_Image-nolpae.extracted/_31CF.extracted/* | grep "Linux make config build file" | cut -d':' -f1)"

cp "${KERNEL_CONFIG_PATH}" kernel.config

fi



popd >/dev/null
