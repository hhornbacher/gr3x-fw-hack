#include <stdio.h>

#include "shmem_manager.h"

uint32_t shmem_init(__off_t offset1, size_t length1, __off_t offset2, size_t length2)
{
    printf("shmem_init(0x%lx [%ld], 0x%x [%d], 0x%lx [%ld], 0x%x [%d])\n",
           offset1, offset1, length1, length1, offset2, offset2, length2, length2);
    printf("shmem_init -> Offset1: 0x%lx\n", offset1);
    printf("shmem_init -> Length1: 0x%x\n", length1);
    printf("shmem_init -> Offset2: 0x%lx\n", offset2);
    printf("shmem_init -> Length2: 0x%x\n", length2);
    return 0;
}

uint32_t shmem_init_config(__off_t offset, uint length, uint param_3, int param_4, void *param_5,
                           int param_6)
{
    printf("shmem_init_config(0x%lx [%ld], 0x%x [%d], 0x%x [%d], 0x%x [%d], 0x%x [%d], 0x%x [%d])\n",
           offset, offset, length, length, param_3, param_3, param_4, param_4, (uint32_t)param_5,
           (uint32_t)param_5, param_6, param_6);
    printf("shmem_init_config -> Offset: 0x%lx\n", offset);
    printf("shmem_init_config -> Length: 0x%x\n", length);

    return 0;
}

int shmem_alloc(uint param_1, int param_2)
{
    printf("shmem_init(0x%x [%d], 0x%x [%d])\n",
           param_1, param_1, param_2, param_2);
    return 0;
}

void shmem_dump_block(void)
{
    printf("shmem_dump_block()\n");
}

void shmem_dump_mng_block(void)
{
    printf("shmem_dump_mng_block()\n");
}

void shmem_exit(void)
{
    printf("shmem_exit()\n");
}

void shmem_free(int param_1)
{
    printf("shmem_free()\n");
}

int shmem_get_mng_size(int param_1, int param_2)
{
    printf("shmem_get_mng_size(0x%x [%d], 0x%x [%d])\n",
           param_1, param_1, param_2, param_2);
    return 0;
}

int *shmem_phys_to_virt(int param_1)
{
    printf("shmem_phys_to_virt(0x%x [%d])\n",
           param_1, param_1);
    return 0;
}

int shmem_use_count(void)
{
    printf("shmem_use_count()\n");
    return 0;
}

int *shmem_virt_to_phys(int param_1)
{
    printf("shmem_virt_to_phys(0x%x [%d])\n",
           param_1, param_1);
    return 0;
}
