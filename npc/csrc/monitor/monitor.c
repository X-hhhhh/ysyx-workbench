#include <macro.h>

void init_sdb();
void init_disasm();

void init_monitor() {
	init_sdb();
#ifdef CONFIG_ITRACE
	init_disasm();
#endif
}

