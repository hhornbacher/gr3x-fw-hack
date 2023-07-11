#[repr(u32)]
pub enum MemoryMap {
    PropertyStartCode = 0xb20b0001,
    PropertyManufacturer = 0xb20b0002,
    PropertyModel = 0xb20b0003,
    PropertySerial = 0xb20b0004,
    PropertyVersion = 0xb20b0005,
    PropertyDatetime = 0xb20b0006,
}

impl Into<u32> for MemoryMap {
    fn into(self) -> u32 {
        self as u32
    }
}

impl Into<usize> for MemoryMap {
    fn into(self) -> usize {
        self as usize
    }
}
