#!/usr/bin/env bash

set -e

SCRIPT_PATH=$(dirname $(realpath "${BASH_SOURCE[0]}"))
PROJECT_PATH=$(realpath "${SCRIPT_PATH}/..")

if [[ "$(docker images -q gr3x-mock-buildenv 2>/dev/null)" == "" ]]; then
    echo "Building docker buildenv image"
    cd ${PROJECT_PATH}/docker/mock-buildenv
    DOCKER_BUILDKIT=1 docker build -t gr3x-mock-buildenv .
fi

for mock in mocks/*; do
    echo "Compiling $(basename $mock)"
    pushd $mock >/dev/null
    docker run -it --rm -v $(pwd):/project gr3x-mock-buildenv ./build.sh
    popd >/dev/null
done
