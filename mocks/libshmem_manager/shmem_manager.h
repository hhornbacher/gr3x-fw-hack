#pragma once

#include <stdlib.h>
#include <stdint.h>

uint32_t shmem_init(__off_t param_1, size_t param_2, __off_t param_3, size_t param_4);
uint32_t shmem_init_config(__off_t param_1, uint param_2, uint param_3, int param_4, void *param_5,
                           int param_6);
int shmem_alloc(uint param_1, int param_2);
void shmem_dump_block(void);
void shmem_dump_mng_block(void);
void shmem_exit(void);
void shmem_free(int param_1);
int shmem_get_mng_size(int param_1, int param_2);
int *shmem_phys_to_virt(int param_1);
int shmem_use_count(void);
int *shmem_virt_to_phys(int param_1);

