//#include <Vtop.h>
#include <VysyxSoCFull.h>
#include <stdio.h>
#include <sdb.h>
#include <macro.h>
#include <wave_trace.h>

extern "C" void flash_read(int32_t addr, int32_t *data) {assert(0);}
extern "C" void mrom_read(int32_t addr, int32_t *data) {assert(0);}

static void reset(int n){
	top->reset = 1;
	while(n-- > 0){
		top->clock = 1; top -> eval(); wave_trace();
		top->clock = 0; top -> eval(); wave_trace();
	}
	top->reset = 0;
}

int main(int argc, char* argv[]){
	wave_trace_init(argc, argv);

	int reset_time = 10;
	while(reset_time-- > 0){
		reset(1);
	}

	init_monitor(argc, argv);
	printf("Welcome to " ANSI_FG_YELLOW ANSI_BG_RED "NPC!" ANSI_NONE "\n");

	Verilated::commandArgs(argc, argv);
	top -> eval(); wave_trace();
	top -> eval(); wave_trace();

	
	sdb_mainloop();

	wave_trace_end();

	return 0;
}

