#include <Vtop.h>
#include <common.h>
#include <wave_trace.h>
#include "svdpi.h"
#include "Vtop__Dpi.h"
#include <sdb.h>
#include <dpi.h>
#include <disasm.h>
#include <pmem.h>
#include <reg.h>
#include <cpu.h>
#include <difftest.h>

#define MAX_INST_TO_PRINT 10

NPCstate npc_state = {.state = -1, .halt_ret = -1};

static int inst_num = 0;
static bool print_inst = false;

//This function is called by dpi interface
void npc_trap() {
	npc_state.state = NPC_END;
	npc_state.halt_pc = top->pc;
	npc_state.halt_ret = gpr_read(10);
}

void assert_fali_msg() {
	riscve_reg_display();
	Mtrace_report();
	Ftrace_report();
}

void cpu_exec(uint64_t n) {
	print_inst = (n < MAX_INST_TO_PRINT); 
	switch(npc_state.state) {
		case NPC_END: case NPC_ABORT: case NPC_QUIT:
			printf("Program execution has ended.\n");	
			return;
		default:
			npc_state.state = NPC_RUNNING;
	}

	while(n-- && npc_state.state == NPC_RUNNING) {
		//execute an instruction
		top->sys_clk = !top->sys_clk;
		top->eval();
		wave_trace();
		top->sys_clk = !top->sys_clk;
		top->eval();
		wave_trace();
		inst_num++;
		
		uint32_t inst = inst_get();
		if(print_inst) {
#ifdef CONFIG_ITRACE
			char buf[256];
			int ret = snprintf(buf, 256, "0x%x: %x\t", top->pc, inst);
			disassemble(buf + ret, 256 - ret, top->pc, (uint8_t*)&inst, 4);
			printf("%s\n", buf);
#endif
		}

		Ftrace(top->pc, inst);

#ifdef CONFIG_WATCHPOINT_SCAN
		bool triggered = scan_wp();
		if(triggered) {npc_state.state = NPC_STOP;}
#endif
		difftest_step(top->pc);
	}

	switch(npc_state.state) {
		case NPC_RUNNING:
			npc_state.state = NPC_STOP; break;
		case NPC_END:
			if(npc_state.halt_ret == 0) {
				printf("npc: " ANSI_FG_GREEN "HIT GOOD TRAP " ANSI_NONE "at pc = %x\n", npc_state.halt_pc);
			}else {
				assert_fali_msg();
				printf("npc: " ANSI_FG_RED "HIT BAD TRAP " ANSI_NONE "at pc = %x\n", npc_state.halt_pc);
			}
			printf("Executed instructions: %d\n", inst_num); 
			break;
		case NPC_ABORT:
			assert_fali_msg();
			printf("npc: " ANSI_FG_RED "ABORT " ANSI_NONE "at pc = %x\n", npc_state.halt_pc);
			printf("Executed instructions: %d\n", inst_num); 
			wave_trace_end();
			assert(0);
			break;
	}
}

