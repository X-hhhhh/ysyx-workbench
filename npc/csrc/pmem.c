#include <Vtop.h>
#include <common.h>
#include <wave_trace.h>
#include <svdpi.h>
#include <Vtop__Dpi.h>

#include <device.h>

uint32_t pmem[PMEM_SIZE] = {0};
static uint32_t pmem_io[MMIO_SIZE] = {0};

bool in_pmem(uint32_t addr) {
	return addr >= PMEM_BASE && addr < PMEM_BASE + PMEM_SIZE;
}

bool in_mmio(uint32_t addr) {
	return addr >= DEVICE_BASE && addr < DEVICE_BASE + MMIO_SIZE;
}

static void out_of_bound(uint32_t addr) {
	printf(ANSI_FG_RED "address = %x is out of bound at pc = %x\n" ANSI_NONE, addr, top->pc);
	assert(0);
}

int pmem_rd_t(int paddr) {
	if(paddr == 0) return 1;
	if(in_pmem(paddr)) {
		uint32_t paddr_ = paddr - PMEM_BASE;
		return pmem[(uint32_t)paddr_ >> 2];
	}
	if(in_mmio(paddr)) {
		//while reading the high register, update data
		if(paddr == TIMER_ADDR + 4) {
			uint64_t us = get_time();
			pmem_io[(TIMER_ADDR - DEVICE_BASE) >> 2] = (uint32_t)us;
			pmem_io[((TIMER_ADDR - DEVICE_BASE) >> 2) + 1] = us >> 32;
	   	}
		uint32_t paddr_ = paddr - DEVICE_BASE;
		return pmem_io[(uint32_t)paddr_ >> 2];
	}
	out_of_bound(paddr);
	return 0;
}

void pmem_wr_t(int paddr, int wdata, char wmask) {
	if(in_pmem(paddr)) {
		uint32_t paddr_ = paddr - PMEM_BASE;
		uint32_t mask = 0;
		for(int i = 0; i < 4; i++) {
			if(((wmask >> i) & 0x1) == 1) {
				mask |= 0xFF << (i * 8);
			}
		}
		pmem[(uint32_t)paddr_ >> 2] = (pmem[(uint32_t)paddr_ >> 2] & ~mask) | (wdata & mask);
		return;
	}
	if(in_mmio(paddr)) {
		if(paddr == SERIAL_ADDR) {
			putchar(wdata);
		}
		return;
	}
	out_of_bound(paddr);
}

int pmem_rd(int paddr) {
	return pmem_rd_t(paddr);
}

int pmem_wr(int paddr, int wdata, char wmask) {
	return pmem_rd_t(paddr);
}

//Called by dpi-c
int pmem_read(int paddr) {
	return pmem_rd_t(paddr);
}

//Called by dpi-c
void pmem_write(int paddr, int wdata, char wmask) {
	pmem_wr_t(paddr, wdata, wmask);
}

