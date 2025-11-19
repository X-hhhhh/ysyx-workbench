#ifndef MACRO_H__
#define MACRO_H__

//Enable waveforms will consume more resources
#define CONFIG_FST_WAVE_TRACE 1

#define ANSI_FG_RED	"\33[1;31m"
#define ANSI_FG_GREEN	"\33[1;32m"
#define ANSI_FG_YELLOW	"\33[1;33m"
#define ANSI_FG_BLUE	"\33[1;34m"
#define ANSI_BG_RED	"\33[1;41m"
#define ANSI_BG_YELLOW	"\33[1;43m"
#define ANSI_NONE	"\33[0m"

//#define CONFIG_WATCHPOINT_SCAN 1
#define CONFIG_ITRACE 1
#define CONFIG_MTRACE 1
//#define CONFIG_FTRACE 1
#define CONFIG_DIFFTEST 1

#define PMEM_BASE	0x80000000
#define DEVICE_BASE	0x10000000
#define PMEM_SIZE	0x8000000
#define MMIO_SIZE	0x10000

#define SERIAL_ADDR	(DEVICE_BASE + 0x0)
#define TIMER_ADDR	(DEVICE_BASE + 0x40)

typedef uint32_t paddr_t;

//calculate the length of an array
#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))

#define SEXT(x, len) ({struct {int64_t n : len;} __x = {.n = x}; (uint64_t)__x.n;})

#define Assert(cond, format, ...) \
	do { \
		if(!(cond)) { \
			fflush(stdout); \
			fprintf(stderr, ANSI_FG_RED format ANSI_NONE "\n", ##__VA_ARGS__); \
			extern void assert_fali_msg(); \
			extern void wave_trace_end(); \
			assert_fali_msg(); \
			wave_trace_end(); \
			assert(cond); \
		} \
	}while(0)

#endif
