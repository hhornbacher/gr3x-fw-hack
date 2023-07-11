# Ricoh GR3(x) system overview

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

- `libshmem_manager.so` (C): Provides functions to manage and utilize shared memory for IPC (Inter-Process Communication) and potentially hardware communication. [[Mock](../mocks/libshmem_manager-rs/src/lib.rs)]
- `libcmfwk.so` (C): Offers functions for managing IPCU, mmaped memory, and shmem. [[Mock](../mocks/libcmfwk-rs/src/lib.rs)]
- `libcamera-controller.so` (C++): Serves as the interface and high level abstraction for the camera functionality.
