#include <common.h>
#include <dlfcn.h>
#include <capstone/capstone.h>

//point to the cs_disasm function
typedef size_t (*cs_disasm_dl)(csh handle, const uint8_t *code, 
	size_t code_size, uint64_t address, size_t count, cs_insn **insn);
//point to the cs_free function
typedef void (*cs_free_dl)(cs_insn *insn, size_t count);
//point to the cs_open function
typedef cs_err (*cs_open_dl)(cs_arch arch, cs_mode mode, csh *handle);

static csh handle;

cs_disasm_dl cs_disasm_handler;
cs_free_dl cs_free_handler;

void init_disasm() {
	void *capstone_handle;
	capstone_handle = dlopen("../nemu/tools/capstone/repo/libcapstone.so.5", RTLD_LAZY);
	assert(capstone_handle);
	
	//search for the cs_open function
	cs_open_dl cs_open_handler = NULL;
	cs_open_handler = (cs_open_dl)dlsym(capstone_handle, "cs_open");
	assert(cs_open_handler);

	//search for the cs_disasm function
	cs_disasm_handler = (cs_disasm_dl)dlsym(capstone_handle, "cs_disasm");
	assert(cs_disasm_handler);

	//search for the cs_free function
	cs_free_handler = (cs_free_dl)dlsym(capstone_handle, "cs_free");
	assert(cs_free_handler);

	int ret = cs_open_handler(CS_ARCH_RISCV, (cs_mode)(CS_MODE_RISCV32 | CS_MODE_RISCVC), &handle);
	assert(ret == CS_ERR_OK);
}

void disassemble(char *buf, int size, uint32_t pc, uint8_t *code, int nbyte) {
	cs_insn *insn;
	size_t count = cs_disasm_handler(handle, code, nbyte, pc, 0, &insn);
	assert(count == 1);

	int ret = snprintf(buf, size, "%s", insn->mnemonic);
	if(insn->op_str[0] != '\0') {
		snprintf(buf + ret, size - ret, "\t%s", insn->op_str);
	}
	cs_free_handler(insn, count);
}

