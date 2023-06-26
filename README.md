# Ricoh GRIII(x)

## Goal

Finding a way to run custom applications without altering the firmware itself (like MagicLantern)

## Hardware

- CPU: Milbeaut SC2000 (Quad Core ARM CORTEX-A7)
  (best guess based on kernel config, still to be confirmed!)

## Project requirements

- cpio
- binwalk
- python3
- curl

## Software

The camera is running a custom Poky (Yocto Project Reference Distro) 2.2 on a linux kernel v4.4. It has several system daemons to control the camera and a few custom libraries.
The whole startup process of all these daemons take place in the `/etc/rc.local` script.

### Daemons

#### camctld (C++)

The camera controller daemon.

#### sysmgrd (C++)

Still Unknown

#### netmgrd (C++)

Still Unknown

#### bled (C++)

This daemon serves the BLE interface.

#### webapid (C++)

This daemon serves the camera remote control and image download web API.
It's using [CrowCpp](https://crowcpp.org/master/) as webserver library.

#### usbd (C++)

This daemon sets up the USB device configuration.

#### mtpd (C++)

This daemon serves the MTP interface.

### Libraries

#### libshmem_manager.so (C)

Functions to manage and use the shared memory for IPC (and hardware communication?).

#### libcmfwk.so (C)

Functions to manage IPCU, mmaped memory, and shmem.

#### libcamera-controller.so (C++)

Interface to the camera functionality.

## Log

- Extracted firmware image (Big thanks to @yeahnope for [gr_unpack](https://github.com/yeahnope/gr_unpack)!)
- Analyzed firmware image contents with binwalk and identified files of interest
- Extracted kernel config
- Built kernel from source code supplied by [RICOH IMAGING](https://www.ricoh-imaging.co.jp/english/products/oss/)
- Extracted rootfs from firmware image
- Created docker container to:
  - Run whole system
  - Run/Debug single application
- Started reverse engineering of:
  - webapid
  - sysmgrd
  - camctrld
  - libcamera-controller.so
  - libcmfwk.so
  - libshmem_manager.so
- Started to write mocks for:
  - libcmfwk.so
  - libshmem_manager.so
- Started to figure out how to run the system in qemu

## Next tasks / Help welcome!

- Get system fully running with mocked shmem/IPCU related stuff
- Analyze how the firmware update process works
- Analyze how the display output works
- Find vulnerabilities to get remote shell access to the camera. This is a list of potential attack surfaces.
  - FW update process
  - webapid
  - bled
  - usbd / mtpd
- Create docker containers for:
  - Building kernel and mocks
  - QEMU



## Interesting repositories:

These repos are all implementing clients for the web API to control the camera over WiFi.

- [GRsync](https://github.com/clyang/GRsync)
- [photo-sync](https://github.com/JohnMaguire/photo_sync)
- [ricoh-gr-iii-tools](https://github.com/mneumann/ricoh-gr-iii-tools)
- [ricoh-download](https://github.com/dkogan/ricoh-download)
- [ricoh-wireless-protocol](https://github.com/CursedHardware/ricoh-wireless-protocol)
