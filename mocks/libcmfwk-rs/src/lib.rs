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

        locked_state.log();

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

        locked_state.log();

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
        let mut locked_state = self.state.lock().unwrap();

        if let Some((_, cb)) = locked_state.receiver_cbs.iter().find(|x| x.0 == channel) {
            unsafe {
                cb(
                    channel,
                    cmd_buffer,
                    std::mem::size_of::<IpcuCommandBuffer>() as u32,
                    send_type,
                    p5,
                );
            }
        }
    }
}

static mut STATE: Option<State> = None;

#[no_mangle]
extern "C" fn fj_mm_open() {
    println!("Rust: fj_mm_open()");
}

#[no_mangle]
extern "C" fn FJ_IPCU_Close(param_1: u32) -> u32 {
    println!("Rust: FJ_IPCU_Close(0x{:x} [{}])", param_1, param_1);

    0
}

#[no_mangle]
extern "C" fn FJ_IPCU_Open(channel: u8, ptr: usize) -> u32 {
    println!("Rust: FJ_IPCU_Open(0x{:x}, 0x{:x})", channel, ptr);

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
        "Rust: FJ_IPCU_Send(0x{:x}, 0x{:x}, 0x{:x}, 0x{:x})",
        channel, cmd_buffer as usize, length, send_type
    );

    let mut cmd_buffer = unsafe { (*cmd_buffer).clone() };

    cmd_buffer.magic = 0x6666bbbb;

    println!("Data: {:#x?}", cmd_buffer);

    State::instance().call_receiver_cb(channel, &cmd_buffer, length, send_type, 0xdeadbeef);

    0
}

#[no_mangle]
extern "C" fn FJ_IPCU_SetReceiverCB(channel: u8, callback: ReceiverCallback) -> u32 {
    println!(
        "Rust: FJ_IPCU_SetReceiverCB(0x{:x}, 0x{:x})",
        channel, callback as usize
    );

    match State::instance().set_receiver_cb(channel, callback) {
        Ok(_) => 0,
        Err(_) => 1,
    }
}

#[no_mangle]
extern "C" fn FJ_MM_phys_to_virt() {
    println!("Rust: FJ_MM_phys_to_virt()");
}

#[no_mangle]
extern "C" fn FJ_MM_virt_to_phys() {
    println!("Rust: FJ_MM_virt_to_phys()");
}
