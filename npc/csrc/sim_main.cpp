#include <Vtop.h>
#include <verilated.h>

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <nvboard.h>

#define CONFIG_FST_WAVE_TRACE 0

VerilatedContext* contextp = new VerilatedContext;
Vtop* top = new Vtop{contextp};

#if CONFIG_FST_WAVE_TRACE
#include "verilated_fst_c.h"
VerilatedFstC *tfp = new VerilatedFstC;
#endif

static TOP_NAME dut;

void nvboard_bind_all_pins(TOP_NAME* top);

static void single_cycle(){
	dut.clk = 0;
	dut.eval();
	dut.clk = 1;
       	dut.eval();
}

static void reset(int n){
	dut.rst = 1;
	while (n-- > 0) single_cycle();
	dut.rst = 0;
}

int main(int argc, char** argv){
	contextp->commandArgs(argc, argv);

	#if CONFIG_FST_WAVE_TRACE
	contextp->traceEverOn(true);
	top->trace(tfp, 99);
	tfp->open("build/logs/cpu_wave.fst");
	#endif

	//reset
	reset(10);

	//define the number of cycles
	//int cycle = 50;

	//bind and initialize nvboard
	nvboard_bind_all_pins(&dut);
	nvboard_init();

	while(1){
		contextp->timeInc(1);

		#if CONFIG_FST_WAVE_TRACE
		tfp->dump(contextp->time());
		#endif
		//cycle--;
		
		//update nvboard
		nvboard_update();
		single_cycle();
	}

	#if CONFIG_FST_WAVE_TRACE
	tfp->close();
	#endif

	top->final();
	delete top;
	top = nullptr;
	delete contextp;
	contextp = nullptr;

	//destroy nvboard
	nvboard_quit();

	return 0;
}
