use std::sync::{Arc, Mutex};

use data::IpcuCommandBuffer;

use crate::error::{Error, Result};

mod data;
mod error;

type ReceiverCallback = unsafe extern "C" fn(u8, *const IpcuCommandBuffer, u32, u32, u32);

#[derive(Debug, Default)]
struct InnerState {
    channels: Vec<(u8, usize)>,
    receiver_cbs: Vec<(u8, ReceiverCallback)>,
}

impl InnerState {
    pub fn log(&self) {
        println!("Current state: {:#x?}", self);
    }
}

#[derive(Debug, Default, Clone)]
struct State {
    state: Arc<Mutex<InnerState>>,
}

impl State {
    pub fn instance() -> &'static Self {
        unsafe {
            if let Some(state) = STATE.as_ref() {
                state
            } else {
                STATE = Some(Default::default());
                STATE.as_ref().unwrap()
            }
        }
    }

    pub fn open_channel(&self, channel: u8, ptr: usize) -> Result {
        let mut locked_state = self.state.lock().unwrap();

        if locked_state
            .channels
            .iter()
            .find(|x| x.0 == channel)
            .is_some()
        {
            return Err(Error::Fail);
        }

        locked_state.channels.push((channel, ptr));

        Ok(())
    }

    pub fn set_receiver_cb(&self, channel: u8, callback: ReceiverCallback) -> Result {
        let mut locked_state = self.state.lock().unwrap();

        if locked_state
            .receiver_cbs
            .iter()
            .find(|x| x.0 == channel)
            .is_some()
        {
            return Err(Error::Fail);
        }

        locked_state.receiver_cbs.push((channel, callback));

        Ok(())
    }

    pub fn call_receiver_cb(
        &self,
        channel: u8,
        cmd_buffer: *const IpcuCommandBuffer,
        length: u32,
        send_type: u32,
        p5: u32,
    ) {
        let locked_state = self.state.lock().unwrap();

        if let Some((_, cb)) = locked_state.receiver_cbs.iter().find(|x| x.0 == channel) {
            unsafe {
                cb(channel, cmd_buffer, length, send_type, p5);
            }
        }
    }
}

static mut STATE: Option<State> = None;

#[no_mangle]
extern "C" fn fj_mm_open() {
    println!("MOCK: fj_mm_open()");
}

#[no_mangle]
extern "C" fn FJ_IPCU_Close(param_1: u32) -> u32 {
    println!("MOCK: FJ_IPCU_Close(0x{:x} [{}])", param_1, param_1);

    0
}

#[no_mangle]
extern "C" fn FJ_IPCU_Open(channel: u8, ptr: usize) -> u32 {
    println!("MOCK: FJ_IPCU_Open(0x{:x}, 0x{:x})", channel, ptr);

    match State::instance().open_channel(channel, ptr) {
        Ok(_) => 0,
        Err(_) => 1,
    }
}

#[no_mangle]
extern "C" fn FJ_IPCU_Send(
    channel: u8,
    cmd_buffer: *const IpcuCommandBuffer,
    length: u32,
    send_type: u32,
) -> u32 {
    println!(
        "MOCK: FJ_IPCU_Send(0x{:x}, 0x{:x}, 0x{:x}, 0x{:x})",
        channel, cmd_buffer as usize, length, send_type
    );

    let mut cmd_buffer = unsafe { (*cmd_buffer).clone() };

    println!("MOCK: Data: {:#x?}", cmd_buffer);

    cmd_buffer.magic = 0x6666bbbb;

    match (cmd_buffer.cmd, cmd_buffer.subcmd) {
        (0xf0000000, 0x3) => match cmd_buffer.param1 {
            0x63 => {
                // START_CODE property
                cmd_buffer.param1 = 0; // Unknown
                cmd_buffer.param2 = 0; // Result
                cmd_buffer.param3 = 0x4; // Length
                cmd_buffer.param4 = 0x00000000; // physical memory address
            }
            0x01 => {
                // Manufacturer property
                cmd_buffer.param1 = 0; // Unknown
                cmd_buffer.param2 = 0; // Result
                cmd_buffer.param3 = 0x10;
                cmd_buffer.param4 = 0x0000001c; // physical memory address
            }
            0x02 => {
                // Model property
                cmd_buffer.param1 = 0; // Unknown
                cmd_buffer.param2 = 0; // Result
                cmd_buffer.param3 = 0x10;
                cmd_buffer.param4 = 0x00000020; // physical memory address
            }
            0x03 => {
                // Serial property
                cmd_buffer.param1 = 0; // Unknown
                cmd_buffer.param2 = 0; // Result
                cmd_buffer.param3 = 0x10;
                cmd_buffer.param4 = 0x00000030; // physical memory address
            }
            0x05 => {
                // Version property
                cmd_buffer.param1 = 0; // Unknown
                cmd_buffer.param2 = 0; // Result
                cmd_buffer.param3 = 0x10;
                cmd_buffer.param4 = 0x00000040; // physical memory address
            }
            0x08 => {
                // Datetime property
                cmd_buffer.param1 = 0; // Unknown
                cmd_buffer.param2 = 0; // Result
                cmd_buffer.param3 = 0x10;
                cmd_buffer.param4 = 0x00000050; // physical memory address
            }
            _ => {
                cmd_buffer.param1 = 0; // Unknown
                cmd_buffer.param2 = 0; // Result
                cmd_buffer.param3 = 0xaabbccdd; // property length
                cmd_buffer.param4 = 0x20; // shmem address?
            }
        },
        (0xf0000003, 0x00) => {
            // Storage ID List
            cmd_buffer.param1 = 0xcdcdcdcd; // Unknown
            cmd_buffer.param2 = 0x0; // Result
            cmd_buffer.param3 = 0xaabbccdd; // Unknown
            cmd_buffer.param4 = 0xf2f3f4f5; // Unknown
        }
        _ => {}
    }

    State::instance().call_receiver_cb(channel, &cmd_buffer, length, send_type, 0xdeadbeef);

    0
}

#[no_mangle]
extern "C" fn FJ_IPCU_SetReceiverCB(channel: u8, callback: ReceiverCallback) -> u32 {
    println!(
        "MOCK: FJ_IPCU_SetReceiverCB(0x{:x}, 0x{:x})",
        channel, callback as usize
    );

    match State::instance().set_receiver_cb(channel, callback) {
        Ok(_) => 0,
        Err(_) => 1,
    }
}

#[no_mangle]
extern "C" fn FJ_MM_phys_to_virt() {
    println!("MOCK: FJ_MM_phys_to_virt()");
}

#[no_mangle]
extern "C" fn FJ_MM_virt_to_phys() {
    println!("MOCK: FJ_MM_virt_to_phys()");
}
