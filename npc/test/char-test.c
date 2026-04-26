#define UART_BASE 0x10000000
#define UART_TX 0x0

void sta() {
	asm volatile ("li sp , 0x0F000000");
	*(volatile char*)(UART_BASE + UART_TX) = 'A';
	//*(volatile char*)(UART_BASE + UART_TX) = '\n';
	while(1);
}

