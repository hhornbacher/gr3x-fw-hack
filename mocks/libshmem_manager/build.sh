#!/usr/bin/env bash

CC=/usr/bin/arm-linux-gnueabi-gcc

${CC} -c -Wall -Werror -fpic shmem_manager.c
${CC} -shared -o libshmem_manager.so shmem_manager.o
rm shmem_manager.o