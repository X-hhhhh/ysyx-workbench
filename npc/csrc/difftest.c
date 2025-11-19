#include <common.h>
#include <dlfcn.h>
#include <pmem.h>
#include <dpi.h>
#include <wave_trace.h>
#include <cpu.h>
#include <reg.h>

#define DIFFTEST_TO_REF false
#define DIFFTEST_TO_DUT true

typedef void (*difftest_memcpy_dl)(paddr_t addr, void *buf, size_t n, bool direction);
typedef void (*difftest_regcpy_dl)(void *dut, bool direction);
typedef void (*difftest_exec_dl)(uint64_t n);
typedef void (*difftest_init_dl)(int port);

difftest_memcpy_dl ref_difftest_memcpy = NULL;
difftest_regcpy_dl ref_difftest_regcpy = NULL;
difftest_exec_dl ref_difftest_exec = NULL;

typedef struct {
	uint32_t gpr[32];
	uint32_t pc;
}cpu_state;

#ifdef CONFIG_DIFFTEST

void init_difftest(char *ref_so_file, long img_size, int port) {
	assert(ref_so_file);

	void *handle;
	handle = dlopen(ref_so_file, RTLD_LAZY);
	assert(handle);

	ref_difftest_memcpy = (difftest_memcpy_dl)dlsym(handle, "difftest_memcpy");
	assert(ref_difftest_memcpy);

	ref_difftest_regcpy = (difftest_regcpy_dl)dlsym(handle, "difftest_regcpy");
	assert(ref_difftest_regcpy);

	ref_difftest_exec = (difftest_exec_dl)dlsym(handle, "difftest_exec");
	assert(ref_difftest_exec);

	difftest_init_dl ref_difftest_init = (difftest_init_dl)dlsym(handle, "difftest_init");
	assert(ref_difftest_init);
	
	printf("Differential testing: " ANSI_FG_GREEN "ON" ANSI_NONE "\n");
	
	//initialize difftest function of ref(nemu)
	ref_difftest_init(port);
	//copy the memory of npc to ref(nemu)
	ref_difftest_memcpy(PMEM_BASE, pmem, img_size, DIFFTEST_TO_REF);
	//copy cpu state to ref(nemu)
	cpu_state dut;
	for(int i = 0 ; i < 16; i++) {
		dut.gpr[i] = gpr_read(i);
	}
	//now the number of gpr is 16, which may change in the future
	for(int i = 16 ; i < 32; i++) {
		dut.gpr[i] = 0;
	}
	dut.pc = top->pc;
	ref_difftest_regcpy(&dut, DIFFTEST_TO_REF);
}

static void checkregs(cpu_state *ref, uint32_t pc) {
	//now the number of gpr is 16, which may change in the future
	for(int i = 0; i < 16; i++) {
		if(ref->gpr[i] != gpr_read(i)) {
			npc_state.state = NPC_ABORT;
			npc_state.halt_pc = pc;
			riscve_reg_display();
			printf("Register status is inconsistent with the reference model at pc=%x\n", pc);
		return;
		}	
	}
}

void difftest_step(uint32_t pc) {
	cpu_state ref;
	ref_difftest_exec(1);
	ref_difftest_regcpy(&ref, DIFFTEST_TO_DUT);
	checkregs(&ref, pc);
}

#else

void init_difftest(char *ref_so_file, long img_size, int port) {}
void difftest_step(uint32_t pc) {}

#endif

