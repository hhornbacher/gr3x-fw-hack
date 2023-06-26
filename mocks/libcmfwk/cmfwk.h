#pragma once

#include <stdlib.h>
#include <stdint.h>

int fj_mm_open(void);
int FJ_IPCU_Close(uint param_1);
int FJ_IPCU_Open(int param_1,void *param_2);
int FJ_IPCU_Send(uint param_1,int param_2,int param_3,int param_4);
int FJ_IPCU_SetReceiverCB(uint param_1,uint param_2);
void FJ_MM_phys_to_virt(void);
void FJ_MM_virt_to_phys(void);