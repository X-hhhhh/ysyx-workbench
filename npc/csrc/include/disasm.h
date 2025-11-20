#ifndef DISASM_H__
#define DSIASM_H__

void init_disasm();
void disassemble(char *buf, int size, uint32_t pc, uint8_t *code, int nbyte);

#endif
