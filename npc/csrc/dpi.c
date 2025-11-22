#include <svdpi.h>
#include <Vtop__Dpi.h>
#include <assert.h>

extern int dpi_gpr_read(char addr);
extern int dpi_inst_get();

uint32_t gpr_read(char addr) {	
	svScope wbu_scope = svGetScopeFromName("TOP.top.WBU_inst");
	assert(wbu_scope);
	svSetScope(wbu_scope);
	return dpi_gpr_read(addr);
}

uint32_t inst_get() {
	svScope ifu_scope = svGetScopeFromName("TOP.top.IFU_inst");
	assert(ifu_scope);
	svSetScope(ifu_scope);
	return dpi_inst_get();
}


