#include <stdio.h>

#include "cmfwk.h"

int fj_mm_open(void)
{
    printf("fj_mm_open()\n");

    return 0;
}

int FJ_IPCU_Close(unsigned int param_1)
{
    printf("FJ_IPCU_Close(0x%x [%d])\n",
           param_1, param_1);

    return 0;
}

int FJ_IPCU_Open(int param_1, void *param_2)
{
    printf("FJ_IPCU_Open(0x%x [%d], 0x%x [%d])\n",
           param_1, param_1, (uint)param_2, (uint)param_2);

    return 0;
}

int FJ_IPCU_Send(uint param_1, int param_2, int param_3, int param_4)
{
    printf("FJ_IPCU_Send(0x%x [%d], 0x%x [%d], 0x%x [%d], 0x%x [%d])\n",
           param_1, param_1, param_2, param_2, param_3, param_3, param_4, param_4);

    return 0;
}

int FJ_IPCU_SetReceiverCB(uint param_1, uint param_2)
{
    printf("FJ_IPCU_SetReceiverCB(0x%x [%d], 0x%x [%d])\n",
           param_1, param_1, param_2, param_2);

    return 0;
}

void FJ_MM_phys_to_virt(void)
{
    printf("FJ_MM_phys_to_virt()\n");
}

void FJ_MM_virt_to_phys(void)
{
    printf("FJ_MM_virt_to_phys()\n");
}