/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <common.h>
#include <device/map.h>
#include <SDL2/SDL.h>

enum {
  reg_freq,
  reg_channels,
  reg_samples,
  reg_sbuf_size,
  reg_init,
  reg_count,
  //add head and rear reg
  reg_sbuf_rear,

  nr_reg
};

static uint8_t *sbuf = NULL;
static int sbuf_head = 0;
static int sbuf_rear = 0;
static uint32_t *audio_base = NULL;

static uint8_t audio_dequeue() {
	uint8_t data = 0;
	if(sbuf_head != sbuf_rear) {
		data = sbuf[sbuf_head];
		sbuf_head = (sbuf_head + 1) % CONFIG_SB_SIZE;
	}
	return data;
}

void sdl_audio_callback(void *userdata, Uint8 *stream, int len) {
	int count = (sbuf_rear + CONFIG_SB_SIZE - sbuf_head) % CONFIG_SB_SIZE;
	if(len <= count) {
		while(len--) {
			*stream = audio_dequeue();
			stream++;
		}
	}else {
		int rest = len - count;
		while(count--) {
			*stream = audio_dequeue();
			stream++;
		}
		//set the rest portion to zero
		memset(stream, 0, rest);
	}
	printf("head=%d\n", sbuf_head);
}

static void init_sdl_audio() {
	SDL_AudioSpec s = {};
	s.freq = audio_base[0];
	s.channels = audio_base[1];
	s.samples = audio_base[2];
	s.format = AUDIO_S16SYS;
	s.userdata = NULL;
	s.callback = sdl_audio_callback;
	SDL_InitSubSystem(SDL_INIT_AUDIO);
	SDL_OpenAudio(&s, NULL);
	SDL_PauseAudio(0);
	printf("sdl initialization finish\n");
}

static void audio_io_handler(uint32_t offset, int len, bool is_write) {	
	//synchronize sbuf_rear to nemu
	if(offset == 24 && is_write) {
		sbuf_rear = audio_base[6];
		return;
	}
	//if accessing the count reg, update free space count
	if(offset == 20) {
		audio_base[5] = (sbuf_rear + CONFIG_SB_SIZE - sbuf_head) % CONFIG_SB_SIZE; 
		return;
	}
	//if init reg is non-zero, start sdl initialization
	if(offset == 16 && audio_base[4] != 0) {
		init_sdl_audio();
	}
}

void init_audio() {
  uint32_t space_size = sizeof(uint32_t) * nr_reg;
  audio_base = (uint32_t *)new_space(space_size);
  audio_base[3] = CONFIG_SB_SIZE;	//reg_sbuf_size
  audio_base[4] = 0;			//reg_init
  audio_base[6] = 0;			//reg_sbuf_rear
#ifdef CONFIG_HAS_PORT_IO
  add_pio_map ("audio", CONFIG_AUDIO_CTL_PORT, audio_base, space_size, audio_io_handler);
#else
  add_mmio_map("audio", CONFIG_AUDIO_CTL_MMIO, audio_base, space_size, audio_io_handler);
#endif

  sbuf = (uint8_t *)new_space(CONFIG_SB_SIZE);
  add_mmio_map("audio-sbuf", CONFIG_SB_ADDR, sbuf, CONFIG_SB_SIZE, NULL);
}
