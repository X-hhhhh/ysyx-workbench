#include <Vtop.h>
#include <verilated.h>

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define CONFIG_FST_WAVE_TRACE 1

VerilatedContext* contextp = new VerilatedContext;
Vtop* top = new Vtop{contextp};

#if CONFIG_FST_WAVE_TRACE
#include "verilated_fst_c.h"
VerilatedFstC *tfp = new VerilatedFstC;
#endif

int main(int argc, char** argv){
	contextp->commandArgs(argc, argv);

	#if CONFIG_FST_WAVE_TRACE
	contextp->traceEverOn(true);
	top->trace(tfp, 99);
	tfp->open("build/logs/cpu_wave.fst");
	#endif

	//initialize the top port
	top->clk = 0;
	top->rst = 0;

	//define the number of cycles
	int cycle = 50;

	while(cycle){
		int a = rand() & 1;
		int b = rand() & 1;
		top -> a = a;
		top -> b = b;
		top->clk = !top->clk;
		top->eval();
		printf("a=%d, b=%d, f=%d\n", a, b, top->f);
		contextp->timeInc(1);

		#if CONFIG_FST_WAVE_TRACE
		tfp->dump(contextp->time());
		#endif
		cycle--;
	}

	#if CONFIG_FST_WAVE_TRACE
	tfp->close();
	#endif

	top->final();
	delete top;
	top = nullptr;
	delete contextp;
	contextp = nullptr;

	return 0;
}
