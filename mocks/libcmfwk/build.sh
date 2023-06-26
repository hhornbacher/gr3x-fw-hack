#!/usr/bin/env bash

CC=/usr/bin/arm-linux-gnueabi-gcc

${CC} -c -Wall -Werror -fpic cmfwk.c
${CC} -shared -o libcmfwk.so cmfwk.o
rm cmfwk.o