#include <Vtop.h>
#include <macro.h>

#if CONFIG_FST_WAVE_TRACE
#include "verilated_fst_c.h"
VerilatedFstC *tfp = new VerilatedFstC;
#endif

VerilatedContext* contextp = new VerilatedContext;
Vtop* top = new Vtop{contextp};

void wave_trace_init(int argc, char* argv[]) {
	contextp->commandArgs(argc, argv);
#if CONFIG_FST_WAVE_TRACE
	contextp->traceEverOn(true);
	top->trace(tfp, 99);
	tfp->open("wave.fst");
#endif
}

void wave_trace_end() {
#if CONFIG_FST_WAVE_TRACE
	tfp->close();
#endif
	top->final();
	delete top;
	top = nullptr;
	delete contextp;
	contextp = nullptr;
}

void wave_trace() {
	contextp->timeInc(1);
#if CONFIG_FST_WAVE_TRACE
	tfp->dump(contextp->time());
#endif
}


