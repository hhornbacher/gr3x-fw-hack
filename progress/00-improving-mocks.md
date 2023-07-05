# 02.07.2023: Improving mocks

I decided to continue with mocking libcmfwk and libshmem_manager using Rust (since this is the language I'm most comfortable with) to get the boot process (`/etc/rc.local` / `docker/start.sh`) further running. At the moment of starting this effort `camctld` was hanging at the point where it enters the `CameraCommandSync` section (refer to current log) and tries to send a IPCU message, waiting for a response.

Current log:
```
user.info camctld[75]: [camctl] logger has been initialized.
user.info camctld[75]: [camctl] loglevel has been changed to (trace).
user.info camctld[75]: ########## camera-controller-daemon ##########
user.info camctld[75]: signal handler has been initialized.
Rust: shmem_init_config(0x4fed0000, 0x30000, 0x50000000, 0x800000, 0xfffef944, 0xa )
shmem_init_config -> Offset: 0x4fed0000
shmem_init_config -> Length: 0x30000
Rust: shmem_init(0x4fed0000, 0x30000, 0x50000000, 0x800000 )
shmem_init -> Offset1: 0x4fed0000
shmem_init -> Length1: 0x30000
shmem_init -> Offset2: 0x50000000
shmem_init -> Length2: 0x800000
user.info camctld[75]: shmem init has done.
Rust: FJ_IPCU_Open(0x1, 0xfffef7bb)
Current state: InnerState {
    channels: [
        (
            0x1,
            0xfffef7bb,
        ),
    ],
    receiver_cbs: [],
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
Rust: FJ_IPCU_Open(0x0, 0xfffef7bb)
Current state: InnerState {
    channels: [
        (
            0x1,
            0xfffef7bb,
        ),
        (
            0x0,
            0xfffef7bb,
        ),
    ],
    receiver_cbs: [],
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
Rust: FJ_IPCU_Open(0x4, 0xfffef7bb)
Current state: InnerState {
    channels: [
        (
            0x1,
            0xfffef7bb,
        ),
        (
            0x0,
            0xfffef7bb,
        ),
        (
            0x4,
            0xfffef7bb,
        ),
    ],
    receiver_cbs: [],
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
Rust: FJ_IPCU_Open(0xd, 0xfffef7bb)
Current state: InnerState {
    channels: [
        (
            0x1,
            0xfffef7bb,
        ),
        (
            0x0,
            0xfffef7bb,
        ),
        (
            0x4,
            0xfffef7bb,
        ),
        (
            0xd,
            0xfffef7bb,
        ),
    ],
    receiver_cbs: [],
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
Rust: FJ_IPCU_Open(0xc, 0xfffef7bb)
Current state: InnerState {
    channels: [
        (
            0x1,
            0xfffef7bb,
        ),
        (
            0x0,
            0xfffef7bb,
        ),
        (
            0x4,
            0xfffef7bb,
        ),
        (
            0xd,
            0xfffef7bb,
        ),
        (
            0xc,
            0xfffef7bb,
        ),
    ],
    receiver_cbs: [],
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
Rust: FJ_IPCU_Open(0x5, 0xfffef7bb)
Current state: InnerState {
    channels: [
        (
            0x1,
            0xfffef7bb,
        ),
        (
            0x0,
            0xfffef7bb,
        ),
        (
            0x4,
            0xfffef7bb,
        ),
        (
            0xd,
            0xfffef7bb,
        ),
        (
            0xc,
            0xfffef7bb,
        ),
        (
            0x5,
            0xfffef7bb,
        ),
    ],
    receiver_cbs: [],
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
Rust: FJ_IPCU_SetReceiverCB(0xff, 0x927e8)
Current state: InnerState {
    channels: [
        (
            0x1,
            0xfffef7bb,
        ),
        (
            0x0,
            0xfffef7bb,
        ),
        (
            0x4,
            0xfffef7bb,
        ),
        (
            0xd,
            0xfffef7bb,
        ),
        (
            0xc,
            0xfffef7bb,
        ),
        (
            0x5,
            0xfffef7bb,
        ),
    ],
    receiver_cbs: [
        (
            0xff,
            0x000927e8,
        ),
    ],
}
Rust: FJ_IPCU_SetReceiverCB(0xff, 0x927e8)
Rust: FJ_IPCU_SetReceiverCB(0xff, 0x927e8)
user.info camctld[75]: FinishBoot
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0x00000100), subcmd(0x00000100)
user.debug camctld[75]: send: magic(0x5555aaaa), cmd(0x100), subcmd(0x100), reqid(1) param1(0x0), param2(0x0), param3(0x0), param4(0x0)
Rust: FJ_IPCU_Send(0xff, 0xff73bae0, 0x24, 0x1)
Data: IpcuCommandBuffer {
    magic: 0x6666bbbb,
    unknown: 0x1,
    cmd: 0x100,
    subcmd: 0x100,
    reqid: 0x1,
    param1: 0x0,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
```

## libshmem_manager
Has following functions
- `int shmem_init_config(addr1, len1, addr2, len2, cfg_ptr, cfg_len)`
- `int shmem_init(addr1, len1, addr2, len2)`

Both functions get called by `camctld` while initialization with following parameters:
- addr1: 0x4fed0000
- len1: 0x30000
- addr2: 0x50000000
- len2: 0x800000
- cfg_ptr: 0xfffef944
- cfg_len: 0x0a

## libcmfwk

