#include <Vtop.h>
#include <common.h>
#include <wave_trace.h>
#include "svdpi.h"
#include "Vtop__Dpi.h"
#include <sdb.h>
#include <dpi.h>
#include <disasm.h>

static bool NPC_TRAP = false;
static bool NPC_END = false;

static int inst_num = 0;

//This function is called by dpi interface
void npc_trap() {
	NPC_TRAP = true;
}

static void check_ret() {
	int halt_ret = gpr_read(10);
	if(halt_ret == 0) {
		printf("npc: " ANSI_FG_GREEN "HIT GOOD TRAP " ANSI_NONE "at pc = %x\n", top->pc);
	}else {
		printf("npc: " ANSI_FG_RED "HIT BAD TRAP " ANSI_NONE "at pc = %x\n", top->pc);
	}
}

void cpu_exec(uint64_t n) {
	while(n-- && NPC_TRAP == false) {
		//execute an instruction
		top->sys_clk = !top->sys_clk;
		top->eval();
		wave_trace();
		top->sys_clk = !top->sys_clk;
		top->eval();
		wave_trace();
		inst_num++;
#ifdef CONFIG_WATCHPOINT_SCAN
		bool triggered = scan_wp();
		if(triggered) {break;}
#endif
#ifdef CONFIG_ITRACE
		char buf[256];
		uint32_t inst = inst_get();
		int ret = snprintf(buf, 256, "%x", top->pc);

		disassemble(buf + ret, 256 - ret, top->pc, (uint8_t*)&inst, 4);
		printf("%s\n", buf);
#endif
	}

	if(NPC_TRAP == true) {
		if(NPC_END == false) {
			check_ret();
			NPC_END = true;
			printf("Executed instructions: %d\n", inst_num);
		}else {
			printf("Program execution has ended.\n");	
		}
	}
}

