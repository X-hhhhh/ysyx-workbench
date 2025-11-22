#include <sys/time.h>
#include <common.h>

uint64_t get_time() {
	struct timeval tv;
	gettimeofday(&tv, NULL);
	uint64_t us = tv.tv_sec * 1000000 + tv.tv_usec;
	return us;
}
