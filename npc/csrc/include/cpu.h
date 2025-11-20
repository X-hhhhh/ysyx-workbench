#ifndef CPU_H__
#define CPU_H__

#include <common.h>

enum {NPC_RUNNING, NPC_END, NPC_STOP, NPC_ABORT, NPC_QUIT};

typedef struct {
	int state;
	uint32_t halt_pc;
	int halt_ret;
}NPCstate;

extern NPCstate npc_state;

void cpu_exec(uint64_t n);

#endif
