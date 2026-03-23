#include <common.h>
#include <svdpi.h>
//#include <Vtop__Dpi.h>
#include <VysyxSoCFull__Dpi.h>
#include <assert.h>
#include <sys/time.h>

extern int dpi_gpr_read(char addr);
extern int dpi_inst_get();
extern int dpi_get_pc();

uint32_t gpr_read(char addr) {	
	//svScope wbu_scope = svGetScopeFromName("TOP.top.WBU_inst");
	svScope wbu_scope = svGetScopeFromName("TOP.ysyxSoCFull.asic.cpu.cpu.WBU_inst");
	assert(wbu_scope);
	svSetScope(wbu_scope);
	return dpi_gpr_read(addr);
}

uint32_t inst_get() {
	//svScope ifu_scope = svGetScopeFromName("TOP.top.IFU_inst");
	svScope ifu_scope = svGetScopeFromName("TOP.ysyxSoCFull.asic.cpu.cpu.IFU_inst");

	assert(ifu_scope);
	svSetScope(ifu_scope);
	return dpi_inst_get();
}

uint32_t get_pc() {
	//svScope wbu_scope = svGetScopeFromName("TOP.top.WBU_inst");
	svScope wbu_scope = svGetScopeFromName("TOP.ysyxSoCFull.asic.cpu.cpu.WBU_inst");
	assert(wbu_scope);
	svSetScope(wbu_scope);
	return dpi_get_pc();
}

//this function is called by LFSR_adv
int dpi_gettime() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec;
}

