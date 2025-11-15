#ifndef PMEM_H__
#define PMEM_H__

extern uint32_t pmem[];

bool in_pmem(uint32_t addr);
bool in_mmio(uint32_t addr);

int pmem_rd(int paddr);
int pmem_wr(int paddr, int wdata, char wmask);

#endif
