#include <Vtop.h>
#include <stdio.h>
#include <sdb.h>
#include <macro.h>
#include <wave_trace.h>

static void reset(int n){
	top -> sys_rst = 1;
	while(n-- > 0){
		top -> sys_clk = 1; top -> eval(); wave_trace();
		printf("valid=%d\n", top->valid);
		top -> sys_clk = 0; top -> eval(); wave_trace();
		printf("\n\n\n\n");
	}
	top -> sys_rst = 0;
}

int main(int argc, char* argv[]){
	wave_trace_init(argc, argv);

	int reset_time = 10;
	while(reset_time-- > 0){
		reset(1);
	}

	init_monitor(argc, argv);
	printf("Welcome to " ANSI_FG_YELLOW ANSI_BG_RED "NPC!" ANSI_NONE "\n");

	top -> eval(); wave_trace();
	top -> eval(); wave_trace();

	
	sdb_mainloop();

	wave_trace_end();

	return 0;
}

