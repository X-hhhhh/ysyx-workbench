#include <am.h>
#include <nemu.h>

#include <klib.h>

#define AUDIO_FREQ_ADDR      (AUDIO_ADDR + 0x00)
#define AUDIO_CHANNELS_ADDR  (AUDIO_ADDR + 0x04)
#define AUDIO_SAMPLES_ADDR   (AUDIO_ADDR + 0x08)
#define AUDIO_SBUF_SIZE_ADDR (AUDIO_ADDR + 0x0c)
#define AUDIO_INIT_ADDR      (AUDIO_ADDR + 0x10)
#define AUDIO_COUNT_ADDR     (AUDIO_ADDR + 0x14)
#define AUDIO_SBUF_REAR	     (AUDIO_ADDR + 0x18)

void __am_audio_init() {
}

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
  	cfg->present = true;
	cfg->bufsize = inl(AUDIO_SBUF_SIZE_ADDR);
}

void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
	outl(AUDIO_FREQ_ADDR, ctrl->freq);
	outl(AUDIO_CHANNELS_ADDR, ctrl->channels);
	outl(AUDIO_SAMPLES_ADDR, ctrl->samples);
	//set audio initialization flag
	outl(AUDIO_INIT_ADDR, 1);
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
  	stat->count = inl(AUDIO_COUNT_ADDR);
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
	static int sbuf_size = -1;
	if(sbuf_size == -1) {sbuf_size = inl(AUDIO_SBUF_SIZE_ADDR);}
	
	int count = inl(AUDIO_COUNT_ADDR);
	int free = sbuf_size - count - 1;		//the queue sacrifices a space
	int datanum = ctl->buf.end - ctl->buf.start;
	int sbuf_rear = inl(AUDIO_SBUF_REAR);
	printf("sbuf_size=%d, count=%d, free=%d, datanum=%d, sbuf_rear=%d\n", sbuf_size, count, free, datanum, sbuf_rear);
	
	//if the space of sbuf is not enough to write, wait until it is enough
	while(datanum > free) {printf(".");}
	while(ctl->buf.start < ctl->buf.end) {
		outl(AUDIO_SBUF_ADDR + sbuf_rear, *(uint8_t *)ctl->buf.start);
		sbuf_rear = (sbuf_rear + 1) % sbuf_size;
		ctl->buf.start = (uint8_t*)ctl->buf.start + 1;
	}
	//synchronize sbuf_rear to memory
	outl(AUDIO_SBUF_REAR, sbuf_rear);
}

