#!/usr/bin/env bash

make ARCH=arm CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf- olddefconfig
make ARCH=arm CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf- -j $(nproc)
