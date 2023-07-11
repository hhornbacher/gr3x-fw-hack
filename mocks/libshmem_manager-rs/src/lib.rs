use std::alloc::{alloc, Layout};

use lazy_static::lazy_static;
use pretty_hex::PrettyHex;

use memory_map::MemoryMap;
lazy_static! {
    static ref MEMORY_MAP2: [(usize, &'static [u8]); 7] = {
        [
            (
                MemoryMap::PropertyStartCode.into(),
                &[0x01, 0x00, 0x00, 0x00],
            ),
            (MemoryMap::PropertyManufacturer.into(), b"Test Manufactur"),
            (MemoryMap::PropertyModel.into(), b"Test Model"),
            (MemoryMap::PropertySerial.into(), b"Test Serial"),
            (MemoryMap::PropertyVersion.into(), b"1.99"),
            (MemoryMap::PropertyDatetime.into(), b"2023"),
            ( // This address is accessed when calling http://localhost:8888/v1/props
                0x20,
                &[
                    0xde, 0xad, 0xbe, 0xef, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff, 0xaf, 0xbe, 0xcd,
                    0xdc, 0xeb, 0xfa,
                ],
            ),
        ]
    };
}

pub fn dump_memory(mem_addr: *const u8, length: usize) {
    let memory_addr = mem_addr as usize;
    println!("Memory address: 0x{memory_addr:x}");

    let mem_slice = unsafe { std::slice::from_raw_parts(mem_addr, length) };

    println!("{:?}", mem_slice.hex_dump());
}

#[no_mangle]
extern "C" fn shmem_init(offset1: u32, length1: u32, offset2: u32, length2: u32) -> u32 {
    println!(
        "Rust: shmem_init(0x{:x}, 0x{:x}, 0x{:x}, 0x{:x} )",
        offset1, length1, offset2, length2,
    );
    println!("shmem_init -> Offset1: 0x{:x}", offset1);
    println!("shmem_init -> Length1: 0x{:x}", length1);
    println!("shmem_init -> Offset2: 0x{:x}", offset2);
    println!("shmem_init -> Length2: 0x{:x}", length2);

    0
}

#[no_mangle]
extern "C" fn shmem_init_config(
    offset: u32,
    length: u32,
    param_3: u32,
    param_4: u32,
    param_5: *const u8,
    param_6: u32,
) -> u32 {
    println!(
        "Rust: shmem_init_config(0x{:x}, 0x{:x}, 0x{:x}, 0x{:x}, 0x{:x}, 0x{:x} )",
        offset, length, param_3, param_4, param_5 as usize, param_6
    );
    println!("shmem_init_config -> Offset: 0x{:x}", offset);
    println!("shmem_init_config -> Length: 0x{:x}", length);
    0
}

#[no_mangle]
extern "C" fn shmem_alloc(param_1: u32, param_2: u32) -> *mut u8 {
    println!("Rust: shmem_alloc(0x{:x}, 0x{:x} )", param_1, param_2);

    unsafe { alloc(Layout::array::<u8>(param_1 as usize).unwrap()) }
}

#[no_mangle]
extern "C" fn shmem_dump_block() {
    println!("Rust: shmem_dump_block()");
}

#[no_mangle]
extern "C" fn shmem_dump_mng_block() {
    println!("Rust: shmem_dump_mng_block()");
}

#[no_mangle]
extern "C" fn shmem_exit() {
    println!("Rust: shmem_exit()");
}

#[no_mangle]
extern "C" fn shmem_free(param_1: u32) {
    println!("Rust: shmem_free(0x{:x})", param_1);
}

#[no_mangle]
extern "C" fn shmem_get_mng_size(param_1: u32, param_2: u32) -> u32 {
    println!("Rust: shmem_get_mng_size(0x{:x}, 0x{:x})", param_1, param_2,);
    0
}

#[no_mangle]
extern "C" fn shmem_phys_to_virt(physical_addr: u32) -> *const u8 {
    println!("Rust: shmem_phys_to_virt(0x{:x})", physical_addr);

    let (_, mem_addr) = MEMORY_MAP2
        .iter()
        .find(|(addr, _)| *addr == physical_addr as usize)
        .unwrap();

    let mem_addr = mem_addr.as_ptr();

    dump_memory(mem_addr, 16);

    ((mem_addr as usize) - 12) as *const u8
}

#[no_mangle]
extern "C" fn shmem_use_count() -> u32 {
    println!("Rust: shmem_use_count()");
    0
}

#[no_mangle]
extern "C" fn shmem_virt_to_phys(param_1: u32) -> *const u8 {
    println!("Rust: shmem_virt_to_phys(0x{:x})", param_1);
    0x80 as *const u8
}
