# Ricoh GRIII(x) Firmware Exploration

## Ricoh GR3(x)

The Ricoh GR3(x) is a camera with firmware that I am exploring to find ways to run custom applications without altering the firmware itself, similar to projects like MagicLantern.

## Motivation

My motivation is to discover methods for running custom applications on the Ricoh GR3(x) camera while keeping the firmware intact. This would allow to extend the camera's functionality and explore new possibilities.

## Contents

The repository includes:

- Tools specifically tailored for analyzing and working with Ricoh GR3(x) firmware.
- Docker environments configured with the necessary dependencies for firmware analysis.

## Camera system

You can find an overview of the camera system [here](docs/system.md)

## Dependencies for using the tools

- cpio
- binwalk
- python3
- curl
- docker

## Getting started

- You need to clone the repository with submodules (`git clone --recursive ...`)
- First you need to obtain a firmware file from: https://www.ricoh-imaging.co.jp/english/support/digital/gr3x_s.html
- I prefer to put it in a directory called firmware and append the firmware version to the filename, e.g.: `firmware/fwdc243b-v121.bin`
- The next step is to extract the firmware: `tools/extract-firmware.sh firmware/fwdc243b-v121.bin`
- Now you can try to run the system in a docker container: `tools/run-system-docker.sh firmware/fwdc243b-v121.bin`
  - At the moment the system will not fully boot, since the shared memory (hardware access) and IPC are not working, so the camctld daemon will fail to fully initialize.
  - If you're interested into the startup script, please have a look at [start.sh](docker/system/start.sh), this is a slightly modified version of the original `/etc/rc.local`
- Now you can try to compile and install the mocks for shmem and IPCU related functions:
  - `tools/build-mocks.sh firmware/fwdc243b-v121.bin`
  - `tools/install-mocks.sh firmware/fwdc243b-v121.bin`
  - In order to rebuild the docker system image you need to remove the old docker image before:
    `docker image rm gr3x-system-fwdc243b-v121`
  - Now you can run `tools/run-system-docker.sh firmware/fwdc243b-v121.bin` again and the system will start with the mocked libraries.
- Building the kernel is possible with: `tools/build-kernel.sh firmware/fwdc243b-v121.bin`
  - I was, until now, not able to run the kernel in QEMU, so any support with that is highly welcome

## Project Progress

You can find all information about the current progress [here](docs/progress/progress.md)

## Contributing

I encourage contributions from the community to enhance the repository's content and improve the tools and utilities provided. If you have valuable insights, additional tools, or improvements to share, please submit a pull request or open an issue.

Happy reverse engineering!
