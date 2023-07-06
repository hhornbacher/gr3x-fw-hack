#[repr(C)]
#[derive(Debug, Clone)]
pub struct IpcuCommandBuffer {
    pub magic: u32,
    pub fmt_version: u32,
    pub cmd: u32,
    pub subcmd: u32,
    pub reqid: u32,
    pub param1: u32,
    pub param2: u32,
    pub param3: u32,
    pub param4: u32,
}
