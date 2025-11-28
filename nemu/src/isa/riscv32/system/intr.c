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

#include <isa.h>

#define ETRACE_MAX 1000

#ifdef CONFIG_ETRACE
static struct {
	word_t mcause[ETRACE_MAX];
	vaddr_t pc[ETRACE_MAX];
	word_t a7[ETRACE_MAX];
	int count;
}Etrace_Info;

static void Etrace(word_t mcause, vaddr_t pc) {
	Assert(Etrace_Info.count < ETRACE_MAX, "Etrace Information is full");
	Etrace_Info.mcause[Etrace_Info.count] = mcause;
	Etrace_Info.pc[Etrace_Info.count] = pc;
	Etrace_Info.a7[Etrace_Info.count] = cpu.gpr[17];
	Etrace_Info.count++;
}

void Etrace_report() {
	printf("Etrace Information:\n");
	for(int i = 0; i < Etrace_Info.count; i++) {
		printf("ecall at pc=%x, mcause=%x, a7=%x\n", Etrace_Info.pc[i], Etrace_Info.mcause[i], Etrace_Info.a7[i]);
	}
}
#else
static void Etrace(word_t mcause, vaddr_t pc) {}
void Etrace_report();
#endif


word_t isa_raise_intr(word_t NO, vaddr_t epc) {
  /* TODO: Trigger an interrupt/exception with ``NO''.
   * Then return the address of the interrupt/exception vector.
   */

	cpu.csr[0x341] = epc;		//mepc
	cpu.csr[0x342] = NO;		//mcause

	Etrace(NO, epc);

  	return cpu.csr[0x305];
}

word_t isa_query_intr() {
  return INTR_EMPTY;
}
