# Ricoh GRIII(x) Firmware Exploration and Custom Application Development

## Ricoh GR3(x)

The Ricoh GR3(x) is a camera with firmware that I am exploring to find ways to run custom applications without altering the firmware itself, similar to projects like MagicLantern.

## Motivation

My motivation is to discover methods for running custom applications on the Ricoh GR3(x) camera while keeping the firmware intact. This would allow to extend the camera's functionality and explore new possibilities.

## Contents

The repository includes:

- Tools specifically tailored for analyzing and working with Ricoh GR3(x) firmware.
- Docker environments configured with the necessary dependencies for firmware analysis.

## Dependencies

- cpio
- binwalk
- python3
- curl

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

## Hardware

The Ricoh GR3(x) camera is equipped with the following hardware:

- CPU: Milbeaut SC2000 (Quad Core ARM CORTEX-A7)
  (_Please note that this is my best guess based on kernel config and is yet to be confirmed_)

## Software

The camera runs a custom Poky (Yocto Project Reference Distro) 2.2 operating system on a Linux kernel v4.4. It utilizes several system daemons, custom libraries, and the `/etc/rc.local` script for the startup process.

### Daemons

- `camctld` (C++): The camera controller daemon.
- `sysmgrd` (C++): Functionality not analyzed yet.
- `netmgrd` (C++): Functionality not analyzed yet.
- `bled` (C++): Serves the BLE (Bluetooth Low Energy) interface.
- `webapid` (C++): Serves the camera's remote control and image download web API. Utilizes the [CrowCpp](https://crowcpp.org/master/) web server library.
- `usbd` (C++): Sets up the USB device configuration.
- `mtpd` (C++): Serves the MTP (Media Transfer Protocol) interface.

### Libraries

- `libshmem_manager.so` (C): Provides functions to manage and utilize shared memory for IPC (Inter-Process Communication) and potentially hardware communication.
- `libcmfwk.so` (C): Offers functions for managing IPCU, mmaped memory, and shmem.
- `libcamera-controller.so` (C++): Serves as the interface to the camera functionality.

## Project Progress

I have made significant progress in my exploration of the Ricoh GR3(x) firmware. Here are some notable achievements and ongoing tasks:

- Extracted the firmware image using [gr_unpack](https://github.com/yeahnope/gr_unpack) (Big thanks goes out to: @yeahnope!)
- Analyzed the firmware image contents using `binwalk` and identified files of interest.
- Extracted the kernel configuration.
- Built the kernel from the source code provided by [RICOH IMAGING](https://www.ricoh-imaging.co.jp/english/products/oss/).
- Extracted the rootfs from the firmware image.
- Created a Docker container to:
  - Run the entire system.
  - Run and debug single applications.
- Initiated reverse engineering efforts on various components, including:
  - `webapid`
  - `sysmgrd`
  - `camctrld`
  - `libcamera-controller.so`
  - `libcmfwk.so`
  - `libshmem_manager.so`
- Started writing mocks for:
  - `libcmfwk.so`
  - `libshmem_manager.so`
- Explored running the system in QEMU.

## Next Tasks

Moving forward, my focus will be on the following tasks:

- Document all findings
- Running the system with fully mocked shmem/IPCU related functionality.
- Analyzing the firmware update process.
- Investigating the display output mechanism.
- Identifying potential attack surfaces and vulnerabilities for achieving remote shell access to the camera. These daemons could be the most interesting:
  - FW update process
  - webapid
  - bled
  - usbd / mtpd

## Contributing

I encourage contributions from the community to enhance the repository's content and improve the tools and utilities provided. If you have valuable insights, additional tools, or improvements to share, please submit a pull request or open an issue.

Happy reverse engineering!
