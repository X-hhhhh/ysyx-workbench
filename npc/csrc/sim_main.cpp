#include <Vtop.h>
#include <stdio.h>
#include "svdpi.h"
#include "Vtop__Dpi.h"
#include <getopt.h>

#define CONFIG_FST_WAVE_TRACE 1

VerilatedContext* contextp = new VerilatedContext;
Vtop* top = new Vtop{contextp};

#if CONFIG_FST_WAVE_TRACE
#include "verilated_fst_c.h"
VerilatedFstC *tfp = new VerilatedFstC;
#endif

#define PMEM_BASE 	0x80000000
#define DEVICE_BASE	0x10000000 
#define PMEM_SIZE 	0x200000
#define MMIO_SIZE	0x10000

static char* img_file = NULL;
static bool NEMU_TRAP = false;

static uint32_t pmem[PMEM_SIZE] = {0};
static uint32_t pmem_io[MMIO_SIZE] = {0};

static bool in_pmem(uint32_t addr) {
	return addr >= PMEM_BASE && addr < PMEM_BASE + PMEM_SIZE;
}

static bool in_mmio(uint32_t addr) {
	return addr >= DEVICE_BASE && addr < DEVICE_BASE + MMIO_SIZE;
}

int pmem_read(int paddr) {
	if(paddr == 0) return 1;
	if(in_pmem(paddr)) {
		uint32_t paddr_ = paddr - PMEM_BASE;
		return pmem[(uint32_t)paddr_ >> 2];
	}
	if(in_mmio(paddr)) {return 0;}
}

void pmem_write(int paddr, int wdata, char wmask) {
	uint32_t paddr_ = paddr - PMEM_BASE;
	assert(((uint32_t)paddr_ >> 2) < PMEM_SIZE);
	uint32_t mask = 0;
	for(int i = 0; i < 4; i++) {
		if((wmask >> i) & 0x1 == 1) {
			mask |= 0xFF << (i * 8);
		}
	}
	pmem[(uint32_t)paddr_ >> 2] = (pmem[(uint32_t)paddr_ >> 2] & ~mask) | (wdata & mask);
}

void load_memory(const char *filename) {
	FILE *fp = fopen(filename, "rb");
	int ret;
	assert(fp);
	for(int i = 0; feof(fp) != 1; i++) {
		ret = fread(&pmem[i], 4, 1, fp);
		if(ret != 1) break;
	}
	fclose(fp);
	fp = NULL;
}

static void wave_trace() {
	contextp -> timeInc(1);
	#if CONFIG_FST_WAVE_TRACE
	tfp -> dump(contextp -> time());
	#endif	
}

static void reset(int n){
	top -> sys_rst = 1;
	while(n-- > 0){
		top -> sys_clk = 1; top -> eval(); wave_trace();
		top -> sys_clk = 0; top -> eval(); wave_trace();
	}
	top -> sys_rst = 0;
}

void nemu_trap() {
	NEMU_TRAP = true;
}

static int parse_args(int argc, char *argv[]) {
	const struct option table[] = {
		{"img"	, required_argument, NULL, 'i'},	
		{0      ,   		  0, NULL, 0},
	};
	int o;
	while( (o = getopt_long(argc, argv, "-i:", table, NULL)) != -1) {
		printf("o = %c, optarg = %s\n", o, optarg);
		switch(o) {
			case 1: img_file = optarg; return 0;
			default:
				  printf("-i, --img: import an img file\n");
				  exit(0);
		}
	}
	return 0;
}

static void check_ret() {
	int halt_ret = top -> gpr[10];
	if(halt_ret == 0) {
		printf("npc:\33[1;32m HIT GOOD TRAP\33[1;0m at pc = %x\n", top -> pc);
	}else {
		printf("npc:\33[1;31m HIT BAD TRAP\33[1;0m at pc = %x\n", top -> pc);	
	}
}

int main(int argc, char* argv[]){
	contextp->commandArgs(argc, argv);

	#if CONFIG_FST_WAVE_TRACE
	contextp->traceEverOn(true);
	top->trace(tfp, 99);
	tfp->open("wave.fst");
	#endif

	parse_args(argc, argv);
	load_memory(img_file);

	//int cycle = 500000;
	int reset_time = 10;
	int inst_num = 0;

	while(reset_time-- > 0){
		reset(1);
	}

	top -> eval(); wave_trace();
	top -> eval(); wave_trace();

	while(NEMU_TRAP == false) {
	//while(cycle && NEMU_TRAP == false) {
		top -> sys_clk = !top -> sys_clk;	
		top -> eval();
		wave_trace();

		top -> sys_clk = !top -> sys_clk;		
		top -> eval();
		wave_trace();
		
		//cycle --;
		inst_num++;
	}

	check_ret();
	printf("executed instructions:%d\n", inst_num);

	/*for(int i = 83954; i < 83954 + 200; i++) {
		printf("%x: %x  ", i, pmem[i]);
		if(i % 4 == 0) printf("\n");
	} */

	#if CONFIG_FST_WAVE_TRACE
	tfp->close();
	#endif
	
	top -> final();
	delete top;
	top = nullptr;
	delete contextp;
	contextp = nullptr;

	return 0;
}

