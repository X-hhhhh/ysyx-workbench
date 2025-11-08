#include <am.h>
#include <nemu.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  uint32_t gpu_size = inl(VGACTL_ADDR);
  uint32_t w = gpu_size >> 16;
  uint32_t h = gpu_size & 0xFFFF;
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = w, .height = h,
    .vmemsz = w * h * 32
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
	static uint32_t width = 0; 
	if(width == 0) {width = inl(VGACTL_ADDR) >> 16;}

	uintptr_t pfb = FB_ADDR + ctl->y * width * 4 + ctl->x * 4;
	for(int y = 0; y < ctl->h; y++) {
		for(int x = 0; x < ctl->w; x++) {
			outl(pfb, *(uint32_t*)ctl->pixels);
			pfb += 4;
			ctl->pixels = (uint32_t*)ctl->pixels + 1;
		}
		pfb = pfb - (ctl->w - width) * 4;
	}
 	if(ctl->sync) {
    		outl(SYNC_ADDR, 1);
 	}
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
