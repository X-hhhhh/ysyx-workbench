#include <am.h>
#include <ysyxsoc.h>

int main(const char *args);

static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {
	outb(SERIAL_ADDR, ch);
}

void halt(int code) {
	ysyxsoc_trap(code);

	while(1);
}

void _trm_init() {
	int ret = main(mainargs);
	halt(ret);
}

