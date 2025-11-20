#include <common.h>
#include <dpi.h>

const char *regs[] = {
	"$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5"
};

void riscve_reg_display() {
	int i;
	for(int i = 0; i < 16; i++) {
		printf("%s : 0x%x  ", regs[i], gpr_read(i));
		if(i % 8 == 7) {printf("\n");}
	}
}

uint32_t riscve_reg_str2val(const char *s, bool *success) {
	int i;
	for(i = 0; i < 32; i++) {
		if(strcmp(s, regs[i]) == 0) {
			*success = true;
			return gpr_read(i);
		}
	}
	*success = false;
	return 0;
}

