# Improving mocks

I have decided to use Rust for mocking `libcmfwk` and `libshmem_manager`, as it is the language I am most comfortable with.
By creating accurate mocks for these libraries, I aim to resolve the issue where `camctld` hangs while trying to send an IPCU message in the `CameraCommandSync` section and waiting for a response.
The goal is to ensure the smooth execution of the boot process (`/etc/rc.local` / `docker/start.sh`).
My current progress shows that `camctld` makes several calls to `FJ_IPCU_Open` and `FJ_IPCU_SetReceiverCB` with different parameters. It then tries to send an IPCU message using `FJ_IPCU_Send`.

### System log

```
user.info camctld[75]: [camctl] logger has been initialized.
user.info camctld[75]: [camctl] loglevel has been changed to (trace).
user.info camctld[75]: ########## camera-controller-daemon ##########
user.info camctld[75]: signal handler has been initialized.
shmem_init_config(0x4fed0000, 0x30000, 0x50000000, 0x800000, 0xfffef944, 0xa )
shmem_init_config -> Offset: 0x4fed0000
shmem_init_config -> Length: 0x30000
shmem_init(0x4fed0000, 0x30000, 0x50000000, 0x800000 )
shmem_init -> Offset1: 0x4fed0000
shmem_init -> Length1: 0x30000
shmem_init -> Offset2: 0x50000000
shmem_init -> Length2: 0x800000
user.info camctld[75]: shmem init has done.
FJ_IPCU_Open(0x1, 0xfffef7bb)
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
FJ_IPCU_Open(0x0, 0xfffef7bb)
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
FJ_IPCU_Open(0x4, 0xfffef7bb)
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
FJ_IPCU_Open(0xd, 0xfffef7bb)
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
FJ_IPCU_Open(0xc, 0xfffef7bb)
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
FJ_IPCU_Open(0x5, 0xfffef7bb)
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
FJ_IPCU_SetReceiverCB(0xff, 0x927e8)
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
FJ_IPCU_SetReceiverCB(0xff, 0x927e8)
FJ_IPCU_SetReceiverCB(0xff, 0x927e8)
user.info camctld[75]: FinishBoot
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0x00000100), subcmd(0x00000100)
user.debug camctld[75]: send: magic(0x5555aaaa), cmd(0x100), subcmd(0x100), reqid(1) param1(0x0), param2(0x0), param3(0x0), param4(0x0)
FJ_IPCU_Send(0xff, 0xff73bae0, 0x24, 0x1)
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

## `libshmem_manager` Functions

The `libshmem_manager` library contains among others the following functions:

1. `int shmem_init_config(addr1, len1, addr2, len2, cfg_ptr, cfg_len)`

   - Parameters:
     - addr1: 0x4fed0000
     - len1: 0x30000
     - addr2: 0x50000000
     - len2: 0x800000
     - cfg_ptr: 0xfffef944
     - cfg_len: 0x0a

2. `int shmem_init(addr1, len1, addr2, len2)`

   - Parameters:
     - addr1: 0x4fed0000
     - len1: 0x30000
     - addr2: 0x50000000
     - len2: 0x800000

3. `void *shmem_phys_to_virt(physical_ptr)`
   Map physical address to virtual address

   - Parameters:
     - physical_address: ???

4. `void *shmem_virt_to_phys(physical_ptr)`
   Map virtual address to physical address

   - Parameters:
     - physical_address: ???

These functions are called by `camctld` during its initialization process.

## `libcmfwk` Functions

1. `FJ_IPCU_SetReceiverCB(channel, callback)`

   - Parameters:
     - channel: 0xff
     - callback: 0x927e8

2. `FJ_IPCU_Open(channel, unknown_address)`

   - Parameters:
     - channel: 0x00 / 0x01 / 0x04 / 0x05 / 0x0c / 0x0d
     - unknown_address: 0xfffef7bb

3. `FJ_IPCU_Send(channel, packet_ptr, packet_length, ipcu_type)`

   - Parameters:
     - channel: 0xff
     - packet_ptr: 0xff73bae0
     - packet_length: 0x24 = 36 bytes
     - ipcu_type: 0x01

   The packet_ptr points to a structure I named `IpcuCommandBuffer`:

   ```rust
   IpcuCommandBuffer {
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

## IPCU commands

I discovered that while experimenting with various actions, I can keep the boot process going by sending back the same packet that was originally sent via `FJ_IPCU_Send`, utilizing the callback registered with `FJ_IPCU_SetReceiverCB`. However, I had to modify the magic value from `0x5555aaaa` to `0x6666bbbb`. It's evident that the data I'm sending back doesn't match the program's expected format, but it serves the purpose of allowing the initialization of `camctld` to proceed and eventually progress to initializing `sysmgrd`.

It's worth noting that as of now, due to the nonsensical IPCU replies, `camctld` will only boot the device in restricted mode.

The commands get generated in `sysmgr::GetSinglePropertyCurrentValue`, which seems to call `camera_controller::CameraController::GetPropertyCommand` to instantiate a object of `camera_controller::PropertyCommandImpl`.

Based on the current system log (see below) I think I was able to identify several commands:

- Get datetime property (0x08):

```rust
IpcuCommandBuffer {
    magic: 0x5555aaaa,
    fmt_version: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x4,
    param1: 0x8,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
```

- Get manufacturer property (0x01):

```rust
IpcuCommandBuffer {
    magic: 0x5555aaaa,
    fmt_version: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x5,
    param1: 0x1,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
```

- Get model property (0x02):

```rust
IpcuCommandBuffer {
    magic: 0x5555aaaa,
    fmt_version: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x6,
    param1: 0x2,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
```

- Get serial property (0x03):

```rust
IpcuCommandBuffer {
    magic: 0x5555aaaa,
    fmt_version: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x7,
    param1: 0x3,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
```

- Get version property (0x05):

```rust
IpcuCommandBuffer {
    magic: 0x5555aaaa,
    fmt_version: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x8,
    param1: 0x5,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
```

- Get STARTUP_CODE property (0x63):

```rust
IpcuCommandBuffer {
    magic: 0x5555aaaa,
    fmt_version: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x2,
    param1: 0x63,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
```

- Get storage ID list:

```rust
IpcuCommandBuffer {
    magic: 0x5555aaaa,
    fmt_version: 0x1,
    cmd: 0xf0000003,
    subcmd: 0x0,
    reqid: 0x5,
    param1: 0x0,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
```

- Still unknown:

```rust
IpcuCommandBuffer {
    magic: 0x5555aaaa,
    fmt_version: 0x1,
    cmd: 0x100,
    subcmd: 0x100,
    reqid: 0x1,
    param1: 0x0,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
```

### System log

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
FJ_IPCU_Open(0x1, 0xfffef7bb)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
FJ_IPCU_Open(0x0, 0xfffef7bb)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
FJ_IPCU_Open(0x4, 0xfffef7bb)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
FJ_IPCU_Open(0xd, 0xfffef7bb)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
FJ_IPCU_Open(0xc, 0xfffef7bb)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
FJ_IPCU_Open(0x5, 0xfffef7bb)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/ipcu_wrapper/ipcu_channel.cpp line #19] [camctl] [IpcuChannel] leave constructor for ipcu(255).
FJ_IPCU_SetReceiverCB(0xff, 0x927e8)
FJ_IPCU_SetReceiverCB(0xff, 0x927e8)
FJ_IPCU_SetReceiverCB(0xff, 0x927e8)
user.info camctld[75]: FinishBoot
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0x00000100), subcmd(0x00000100)
user.debug camctld[75]: send: magic(0x5555aaaa), cmd(0x100), subcmd(0x100), reqid(1) param1(0x0), param2(0x0), param3(0x0), param4(0x0)
FJ_IPCU_Send(0xff, 0xff73cae0, 0x24, 0x1)
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
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #129] [ENTER] RxHandler
user.debug camctld[75]: recv: magic(0x6666bbbb), cmd(0x100), subcmd(0x100), reqid(1) param1(0x0), param2(0x0), param3(0x0), param4(0x0)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #173] [LEAVE] RxHandler
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #69] [LEAVE] Run
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #81] [CamCmd] recv: cmd(0x00000100), subcmd(0x00000100)
user.info camctld[75]: finish boot (shmem initialized)
user.info camctld[75]: Server listening on unix:/tmp/server.sock
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0xf0000000), subcmd(0x00000003)
FJ_IPCU_Send(0xff, 0xff73cae0, 0x24, 0x1)
Data: IpcuCommandBuffer {
user.debug camctld[75]: send: magic(0x5555aaaa), cmd(0xf0000000), subcmd(0x3), reqid(2) param1(0x63), param2(0x0), param3(0x0), param4(0x0)
    magic: 0x6666bbbb,
    unknown: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x2,
    param1: 0x63,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #129] [ENTER] RxHandler
user.debug camctld[75]: recv: magic(0x6666bbbb), cmd(0xf0000000), subcmd(0x3), reqid(2) param1(0x63), param2(0x0), param3(0x0), param4(0x0)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #81] [CamCmd] recv: cmd(0xf0000000), subcmd(0x00000003)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #173] [LEAVE] RxHandler
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #69] [LEAVE] Run
user.warn camctld[75]: Get STARTUP_CODE fail
user.info camctld[75]: startupmode=restrict(code=1412784)
rc.local(restrict) complete
user.info sysmgrd[98]: loglevel has been changed to (info).
user.info sysmgrd[98]: logger has been initialized.
user.info sysmgrd[98]: [camctl] ########## camera-controller-library ##########
Rust: shmem_init(0x4fed0000, 0x30000, 0x50000000, 0x800000 )
shmem_init -> Offset1: 0x4fed0000
shmem_init -> Length1: 0x30000
shmem_init -> Offset2: 0x50000000
shmem_init -> Length2: 0x800000
user.info sysmgrd[98]: [camctl] shmem_init has done.
user.info sysmgrd[98]: [camctl] SetupCameraEventService
user.err usbd[96]: failed inotify_add_watch: errno=2
user.info sysmgrd[98]: [camctl] Server listening on unix:/tmp/sysmgrd_98.sock
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_event_dispatcher_service.cpp line #18] [ConnectToServer] enter
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_event_client.cpp line #22] [Create] enter
user.info sysmgrd[98]: [camctl] CacheController has started
user.info sysmgrd[98]: [camctl] Server listening on unix:/tmp/sysmgrd_ifcmd.sock
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #31] [CameraCommandSync] enter.
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0xf0000003), subcmd(0x00000000)
FJ_IPCU_Send(0xff, 0xff73cae0, 0x24, 0x1)
Data: IpcuCommandBuffer {
user.debug camctld[75]: send: magic(0x5555aaaa), cmd(0xf0000003), subcmd(0x0), reqid(3) param1(0x0), param2(0x0), param3(0x0), param4(0x0)
    magic: 0x6666bbbb,
    unknown: 0x1,
    cmd: 0xf0000003,
    subcmd: 0x0,
    reqid: 0x3,
    param1: 0x0,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #129] [ENTER] RxHandler
user.debug camctld[75]: recv: magic(0x6666bbbb), cmd(0xf0000003), subcmd(0x0), reqid(3) param1(0x0), param2(0x0), param3(0x0), param4(0x0)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #173] [LEAVE] RxHandler
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #81] [CamCmd] recv: cmd(0xf0000003), subcmd(0x00000000)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #69] [LEAVE] Run
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #54] [CameraCommandSync] leave.
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/interface_command_dispatcher_service.cpp line #18] [ConnectToServer] enter
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/interface_command_client.cpp line #24] [Create] enter
user.warn sysmgrd[98]: [camctl] No longer supported : StartCameraEventService
user.err sysmgrd[98]: [camctl] StorageIdList::Create: paddr is null.
user.warn sysmgrd[98]: [camctl] CacheController::operator() failed to initialize storage cache
user.info sysmgrd[98]: [camctl] AddLocalStatusEventListener
user.info sysmgrd[98]: SystemManager started
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_event_dispatcher_service.cpp line #32] [AddStatusEventListener] enter
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_event_rx_task.cpp line #35] [AddStatusEventListener]
user.debug camctld[75]: [AddStatusEventListener] subcmdId(2), listeners(1).
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/interface_command_dispatcher_service.cpp line #75] [SetDeviceCommandReceiver] enter
user.info sysmgrd[98]: [camctl] AddPropertyEventListener
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_event_dispatcher_service.cpp line #73] [AddPropertyEventListener] enter
user.debug camctld[75]: [AddPropertyEventListener] number of props(1).
user.debug camctld[75]: [AddPropertyEventListener] number of listeners(1).
user.info sysmgrd[98]: startmode=restrict
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #31] [CameraCommandSync] enter.
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0xf0000000), subcmd(0x00000003)
FJ_IPCU_Send(0xff, 0xff73cae0, 0x24, 0x1)
user.debug camctld[75]: send: magic(0x5555aaaa), cmd(0xf0000000), subcmd(0x3), reqid(4) param1(0x8), param2(0x0), param3(0x0), param4(0x0)
Data: IpcuCommandBuffer {
    magic: 0x6666bbbb,
    unknown: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x4,
    param1: 0x8,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #129] [ENTER] RxHandler
user.debug camctld[75]: recv: magic(0x6666bbbb), cmd(0xf0000000), subcmd(0x3), reqid(4) param1(0x8), param2(0x0), param3(0x0), param4(0x0)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #173] [LEAVE] RxHandler
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #69] [LEAVE] Run
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #81] [CamCmd] recv: cmd(0xf0000000), subcmd(0x00000003)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #54] [CameraCommandSync] leave.
user.err sysmgrd[98]: [camctl] command failed res(7).
user.err sysmgrd[98]: cannot get datetime property
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #31] [CameraCommandSync] enter.
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0xf0000000), subcmd(0x00000003)
FJ_IPCU_Send(0xff, 0xff73cae0, 0x24, 0x1)
Data: IpcuCommandBuffer {
    magic: 0x6666bbbb,
    unknown: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x5,
    param1: 0x1,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #129] [ENTER] RxHandler
user.debug camctld[75]: recv: magic(0x6666bbbb), cmd(0xf0000000), subcmd(0x3), reqid(5) param1(0x1), param2(0x0), param3(0x0), param4(0x0)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #173] [LEAVE] RxHandler
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #69] [LEAVE] Run
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #81] [CamCmd] recv: cmd(0xf0000000), subcmd(0x00000003)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #54] [CameraCommandSync] leave.
user.err sysmgrd[98]: [camctl] command failed res(7).
user.err sysmgrd[98]: cannot get manufacturer property
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #31] [CameraCommandSync] enter.
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0xf0000000), subcmd(0x00000003)
FJ_IPCU_Send(0xff, 0xff73cae0, 0x24, 0x1)
user.debug camctld[75]: send: magic(0x5555aaaa), cmd(0xf0000000), subcmd(0x3), reqid(6) param1(0x2), param2(0x0), param3(0x0), param4(0x0)
Data: IpcuCommandBuffer {
    magic: 0x6666bbbb,
    unknown: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x6,
    param1: 0x2,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #129] [ENTER] RxHandler
user.debug camctld[75]: recv: magic(0x6666bbbb), cmd(0xf0000000), subcmd(0x3), reqid(6) param1(0x2), param2(0x0), param3(0x0), param4(0x0)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #173] [LEAVE] RxHandler
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #69] [LEAVE] Run
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #81] [CamCmd] recv: cmd(0xf0000000), subcmd(0x00000003)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #54] [CameraCommandSync] leave.
user.err sysmgrd[98]: [camctl] command failed res(7).
user.err sysmgrd[98]: cannot get model property
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #31] [CameraCommandSync] enter.
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0xf0000000), subcmd(0x00000003)
FJ_IPCU_Send(0xff, 0xff73cae0, 0x24, 0x1)
Data: IpcuCommandBuffer {
user.debug camctld[75]: send: magic(0x5555aaaa), cmd(0xf0000000), subcmd(0x3), reqid(7) param1(0x3), param2(0x0), param3(0x0), param4(0x0)
    magic: 0x6666bbbb,
    unknown: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x7,
    param1: 0x3,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #129] [ENTER] RxHandler
user.debug camctld[75]: recv: magic(0x6666bbbb), cmd(0xf0000000), subcmd(0x3), reqid(7) param1(0x3), param2(0x0), param3(0x0), param4(0x0)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #173] [LEAVE] RxHandler
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #69] [LEAVE] Run
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #81] [CamCmd] recv: cmd(0xf0000000), subcmd(0x00000003)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #54] [CameraCommandSync] leave.
user.err sysmgrd[98]: [camctl] command failed res(7).
user.err sysmgrd[98]: cannot get serial no property
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #31] [CameraCommandSync] enter.
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0xf0000000), subcmd(0x00000003)
FJ_IPCU_Send(0xff, 0xff73cae0, 0x24, 0x1)
Data: IpcuCommandBuffer {
    magic: 0x6666bbbb,
    unknown: 0x1,
    cmd: 0xf0000000,
    subcmd: 0x3,
    reqid: 0x8,
    param1: 0x5,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #129] [ENTER] RxHandler
user.debug camctld[75]: recv: magic(0x6666bbbb), cmd(0xf0000000), subcmd(0x3), reqid(8) param1(0x5), param2(0x0), param3(0x0), param4(0x0)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #173] [LEAVE] RxHandler
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #81] [CamCmd] recv: cmd(0xf0000000), subcmd(0x00000003)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #69] [LEAVE] Run
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_remote/server/camera_command_service.cpp line #54] [CameraCommandSync] leave.
user.err sysmgrd[98]: [camctl] command failed res(7).
user.err sysmgrd[98]: cannot get version property
user.info sysmgrd[98]: exec: usb30dev_mtp_func.sh "RICOH IMAGING COMPANY, LTD." "Camera" "000000" 0x0000
user.info camctld[75]: FinishBoot
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #89] [ENTER] CameraCommandSync
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #44] [CamCmd] send: cmd(0x00000100), subcmd(0x00000100)
FJ_IPCU_Send(0xff, 0xff73cae0, 0x24, 0x1)
user.debug camctld[75]: send: magic(0x5555aaaa), cmd(0x100), subcmd(0x100), reqid(9) param1(0x1), param2(0x0), param3(0x0), param4(0x0)
Data: IpcuCommandBuffer {
    magic: 0x6666bbbb,
    unknown: 0x1,
    cmd: 0x100,
    subcmd: 0x100,
    reqid: 0x9,
    param1: 0x1,
    param2: 0x0,
    param3: 0x0,
    param4: 0x0,
}
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #129] [ENTER] RxHandler
user.debug camctld[75]: recv: magic(0x6666bbbb), cmd(0x100), subcmd(0x100), reqid(9) param1(0x1), param2(0x0), param3(0x0), param4(0x0)
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/cameraif_impl.cpp line #173] [LEAVE] RxHandler
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #69] [LEAVE] Run
user.debug camctld[75]: [/usr/src/debug/camera-controller/1.0-r0/git/src/camera_core/camera_command_task.cpp line #81] [CamCmd] recv: cmd(0x00000100), subcmd(0x00000100)
user.info camctld[75]: finish boot (ready to receive command)
Init USB: RICOH IMAGING COMPANY, LTD. Camera 000000 0x0000
```
