# Project progress

I have made significant progress in my exploration of the Ricoh GR3(x) firmware. Here are some notable achievements and ongoing tasks:

- Extracted the firmware image using [gr_unpack](https://github.com/yeahnope/gr_unpack) (Big thanks goes out to: @yeahnope!)
- Analyzed the firmware image contents using `binwalk` and identified files of interest.
- Extracted the kernel configuration.
- Built the kernel from the source code provided by [RICOH IMAGING](https://www.ricoh-imaging.co.jp/english/products/oss/).
- Extracted the rootfs from the firmware image.
- Created a Docker container to:
  - Run the entire system.
  - Run and debug single applications.
- Initiated reverse engineering efforts on various components with Ghidra, including:
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
- Analyze firmware with: [cwe_checker](../../analysis/cwe_checker), [EMBA](../../analysis/emba/default-scan-unpacked-fw/html-report) and [firmwalker](../../analysis/firmwalker.txt)
- [Improving mocks](improving-mocks.md)

## Next Tasks

Moving forward, my focus will be on the following tasks:

- Running the system with fully mocked shmem/IPCU related functionality.
- Analyzing the firmware update process.
- Identifying potential attack surfaces and vulnerabilities for achieving remote shell access to the camera. These daemons could be the most interesting:
  - FW update process
  - webapid
  - bled
  - usbd / mtpd
- Investigating the display output mechanism.
