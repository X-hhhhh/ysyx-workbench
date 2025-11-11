#include <am.h>
#include <npc.h>

void __am_timer_init() {
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
 	/* static uint64_t start_time = 0;
	 if(start_time == 0) {
	 	start_time = ((uint64_t)inl(TIMER_ADDR + 4) << 32) | (uint64_t)inl(TIMER_ADDR);
	 }
	 	uint64_t now = ((uint64_t)inl(TIMER_ADDR + 4) << 32) | (uint64_t)inl(TIMER_ADDR);
		uptime->us = now - start_time;*/
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}
