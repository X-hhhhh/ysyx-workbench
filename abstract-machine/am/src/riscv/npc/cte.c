#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  if (user_handler) {
    Event ev = {0};
    switch (c->mcause) {
		case 8:
			//if a5 is -1, the event is yield
			if(c->gpr[15] == -1) {
				ev.event = EVENT_YIELD;
			}
			break;
      default: ev.event = EVENT_ERROR; break;
    }

    c = user_handler(ev, c);
    assert(c != NULL);
  }

  return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

  // register event handler
  user_handler = handler;

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  	Context *c = (Context*)(kstack.end - sizeof(Context));
	c->mepc = (uintptr_t)entry;
	//set mstatus to 0x1800 to pass difftest
	c->mstatus = 0x1800;
	for(int i = 0; i < 16; i++) {
		//pass parameters(a0)
		if(i == 10) {c->gpr[i] = (uintptr_t)arg; continue;}
		//set other gpr to zero
		c->gpr[i] = 0;
	}
	return c;
}

void yield() {
#ifdef __riscv_e
  asm volatile("li a5, -1; ecall");
#else
  asm volatile("li a7, -1; ecall");
#endif
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
