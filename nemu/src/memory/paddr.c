/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
#endif

#define MAX_Mtrace 1000

static struct Mtrace_info {
	paddr_t mem_buf[MAX_Mtrace];
	uint8_t data_len[MAX_Mtrace];
	uint8_t rw_flag[MAX_Mtrace];	//1:write, 0: read
	int count;
} Mt = {
	.mem_buf = {0},
	.data_len = {0},
	.rw_flag = {0},
	.count = 0,
};

static void Mtrace(paddr_t addr, int len, uint8_t rw_flag) {
	if(Mt.count >= MAX_Mtrace) {return;}
	Mt.mem_buf[Mt.count] = addr;
	Mt.data_len[Mt.count] = len;
	Mt.rw_flag[Mt.count] = rw_flag;
	Mt.count++;
}

void Mtrace_report() {
	printf("R/W\tpmem_addr\t\tlen\n");
	for(int i = 0; i < Mt.count; i++) {
		if(Mt.rw_flag[i] == 0) {
			printf("Rd\t%10x  %d\n", Mt.mem_buf[i], Mt.data_len[i]);
		}else {
			printf("Wr\t%10x  %d\n", Mt.mem_buf[i], Mt.data_len[i]);
		}
	}
	if(Mt.count == MAX_Mtrace) {
		printf("The Mtrace record is full, there may be data that has not been recorded\n");
	}
}

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

static word_t pmem_read(paddr_t addr, int len) {
  word_t ret = host_read(guest_to_host(addr), len);
  return ret;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  host_write(guest_to_host(addr), len, data);
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}

void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem = malloc(CONFIG_MSIZE);
  assert(pmem);
#endif
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem, rand(), CONFIG_MSIZE));
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
}

word_t paddr_read(paddr_t addr, int len) {
  Mtrace(addr, len, 0);

  if (likely(in_pmem(addr))) return pmem_read(addr, len);
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {
  Mtrace(addr, len, 1);
	
  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  out_of_bound(addr);
}
