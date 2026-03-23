#ifndef WAVE_TRACE_H__
#define WAVE_TRACE_H__

//#include <Vtop.h>
#include <VysyxSoCFull.h>

//extern Vtop* top;
extern VysyxSoCFull* top;

void wave_trace_init(int argc, char* argv[]);
void wave_trace_end();
void wave_trace();

#endif
