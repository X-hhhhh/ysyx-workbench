#include <Vtop.h>
#include <common.h>
#include <wave_trace.h>
#include <svdpi.h>
#include <Vtop__Dpi.h>
#include <device.h>

#define MAX_Mtrace 1000

#ifdef CONFIG_MTRACE
static struct Mtrace_info {
	uint32_t mem_buf[MAX_Mtrace];
	uint8_t data_len[MAX_Mtrace];
	uint8_t rw_flag[MAX_Mtrace];	//1:write, 0:read
	int count;
}Mt;
#endif

static void Mtrace(uint32_t addr, int len, uint8_t rw_flag) {
#ifdef CONFIG_MTRACE
	if(Mt.count >= MAX_Mtrace) {return;}
	Mt.mem_buf[Mt.count] = addr;
	Mt.data_len[Mt.count] = len;
	Mt.rw_flag[Mt.count] = rw_flag;
	Mt.count++;
#endif
}

void Mtrace_report() {
#ifdef CONFIG_MTRACE
	printf("Mtrace Information:\n");
	printf("R/W   pmem_addr   len\n");
	for(int i = 0; i < Mt.count; i++) {
		if(Mt.rw_flag[i] == 0) {
			printf("Rd  %10x    %d\n", Mt.mem_buf[i], Mt.data_len[i]);
		}else {
			printf("Wr  %10x    %d\n", Mt.mem_buf[i], Mt.data_len[i]);
		}
	}
	if(Mt.count == MAX_Mtrace) {
		printf("The Mtrace record is full, there may be data that has not been recorded\n");
	}
#endif
}

uint32_t pmem[PMEM_SIZE] = {0};
static uint32_t pmem_io[MMIO_SIZE] = {0};

bool in_pmem(uint32_t addr) {
	return addr >= PMEM_BASE && addr < PMEM_BASE + PMEM_SIZE;
}

bool in_mmio(uint32_t addr) {
	return addr >= DEVICE_BASE && addr < DEVICE_BASE + MMIO_SIZE;
}

static void out_of_bound(uint32_t addr) {
	Assert(0, "address = 0x%x is out of bound at pc = %x", addr, top->pc);
}

int pmem_rd_t(int paddr) {
	Mtrace(paddr, 4, 0);

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
	Mtrace(paddr, 4, 1);
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
	printf("read\n");
	return pmem_rd_t(paddr);
}

//Called by dpi-c
void pmem_write(int paddr, int wdata, char wmask) {
	printf("wr\n");
	pmem_wr_t(paddr, wdata, wmask);
}

