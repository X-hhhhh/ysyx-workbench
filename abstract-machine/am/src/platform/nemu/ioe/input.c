#include <am.h>
#include <nemu.h>

#include <klib.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
	int keycode = (int)inl(KBD_ADDR);
	if(keycode == AM_KEY_NONE) {
		kbd -> keydown = false;
		kbd -> keycode = AM_KEY_NONE;
	}else if((keycode & KEYDOWN_MASK)) {
		kbd -> keydown = true;
		kbd -> keycode = keycode & ~KEYDOWN_MASK;
		printf("%d\n", keycode);
	}else {
		kbd -> keydown = false;
		kbd -> keycode = keycode;
		printf("%d\n", keycode);
	}
}
