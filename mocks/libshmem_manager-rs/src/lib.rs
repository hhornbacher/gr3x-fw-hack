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
extern "C" fn shmem_alloc(param_1: u32, param_2: u32) -> u32 {
    println!("Rust: shmem_init(0x{:x}, 0x{:x} )", param_1, param_2,);
    0
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
    println!("Rust: shmem_free()");
}
#[no_mangle]
extern "C" fn shmem_get_mng_size(param_1: u32, param_2: u32) -> u32 {
    println!(
        "Rust: shmem_get_mng_size(0x{:x}, 0x{:x} )",
        param_1, param_2,
    );
    0
}
#[no_mangle]
extern "C" fn shmem_phys_to_virt(param_1: u32) -> *const u8 {
    println!("Rust: shmem_phys_to_virt(0x{:x} )", param_1);
    0 as *const u8
}
#[no_mangle]
extern "C" fn shmem_use_count() -> u32 {
    println!("Rust: shmem_use_count()");
    0
}

#[no_mangle]
extern "C" fn shmem_virt_to_phys(param_1: u32) -> *const u8 {
    println!("Rust: shmem_virt_to_phys(0x{:x} )", param_1);
    0 as *const u8
}
