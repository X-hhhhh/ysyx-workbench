#ifndef NPC_H__
#define NPC_H__

#include <klib-macros.h>
#include "riscv/riscv.h"

#define DEVICE_BASE	0x10000000

#define SERIAL_ADDR	(DEVICE_BASE + 0x0)
#define TIMER_ADDR	(DEVICE_BASE + 0x40)

#define npc_trap(code) asm volatile ("mv a0, %0; ebreak" : :"r"(code))

#endif
