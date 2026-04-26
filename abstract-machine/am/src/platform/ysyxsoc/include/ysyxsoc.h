#ifndef YSYXSOC_H__
#define YSYXSOC_H__

#include <klib-macros.h>
#include "riscv/riscv.h"

#define SERIAL_ADDR 0x10000000
#define SRAM_ADDR  0x0F000000

#define ysyxsoc_trap(code) asm volatile ("mv a0, %0; ebreak" : :"r"(code))

extern char _sram_start;
//available sdram size is 8KB
#define SRAM_SIZE 8192
#define SRAM_END ((uintptr_t)&_sram_start + SRAM_SIZE)

#endif
