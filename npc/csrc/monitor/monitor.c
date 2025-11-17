#include <common.h>
#include <macro.h>
#include <elf.h>
#include <getopt.h>
#include <pmem.h>
#include <dpi.h>

void init_sdb();
void init_disasm();
void init_difftest(char *ref_so_file, long img_size, int port);

#define MAX_FUNCNUM 512
#define MAX_CALL_RET 512

static struct {
	uint32_t address_b[MAX_FUNCNUM];
	uint32_t address_e[MAX_FUNCNUM];
	char name[MAX_FUNCNUM][64];
	int count;
} func_add_table;

#ifdef CONFIG_FTRACE
static struct {
	uint32_t pc[MAX_CALL_RET];
	char type[MAX_CALL_RET];	//'c' for call, 'r' for ret
	char info[MAX_CALL_RET][64];	//call func's name or return func's name
	int count;
} func_call_info;
#endif

static char *img_file = NULL;
static char *elf_file = NULL;
static char *diff_so_file = NULL;

static int analyze_elf() {
	if(elf_file == NULL) {
        	printf("No elf_file is given. Function trace is disabled.\n");
		return 0;
	}

	FILE *fp = fopen(elf_file, "rb");
	Assert(fp, "Can not open '%s'", elf_file);

	int ret;

	//analyze elf header
	Elf32_Ehdr ehdr;
	ret = fread(&ehdr, sizeof(Elf32_Ehdr), 1, fp);
	if(ret != 1) return 1;
	
	//check if it is an elf file
	if(ehdr.e_ident[0] != 0x7f || ehdr.e_ident[1] != 'E' || ehdr.e_ident[2] != 'L' || ehdr.e_ident[3] != 'F') {
		printf("Please make sure it is an elf file\n");
		return 1;
	}

	//analyze section header
	ret = fseek(fp, ehdr.e_shoff, SEEK_SET);
	if(ret == -1) return 1;
	Elf32_Shdr shdr[ehdr.e_shnum];
	for(int i = 0; i < ehdr.e_shnum; i++) {
		ret = fread(&shdr[i], sizeof(Elf32_Shdr), 1, fp);
		if(ret != 1) return 1;
	}

	//go to section name string table 
	int symtab_idx = -1, strtab_idx = -1;
	Elf32_Off shstrtab_off = shdr[ehdr.e_shstrndx].sh_addr + shdr[ehdr.e_shstrndx].sh_offset;
	char buf[128];
	int count = 0;
	ret = fseek(fp, shstrtab_off, SEEK_SET);
	if(ret == -1) return 1;
	for(int i = 0; i < ehdr.e_shnum; i++) {
		fseek(fp, shstrtab_off + shdr[i].sh_name, SEEK_SET);
		while(1) {
			ret = fread(&buf[count], 1, 1, fp);
			if(ret != 1) return 1;
			if(buf[count] == '\0') {
				count = 0;
				if(strcmp(buf, ".symtab") == 0) {
					symtab_idx = i;
				}else if(strcmp(buf, ".strtab") == 0) {
					strtab_idx = i;
				}
				break;
			}
			count++;
		}
	}

	if(symtab_idx == -1 || strtab_idx == -1) return 1;
	
	Elf32_Off symtab_off = shdr[symtab_idx].sh_addr + shdr[symtab_idx].sh_offset;
	Elf32_Off strtab_off = shdr[strtab_idx].sh_addr + shdr[strtab_idx].sh_offset;
	
	//analyze symtab
	ret = fseek(fp, symtab_off, SEEK_SET);
	if(ret == -1) return 1;
	int sym_num = shdr[symtab_idx].sh_size / sizeof(Elf32_Sym);
	Elf32_Sym sym[sym_num];
	count = 0;
	ret = fread(&sym, shdr[symtab_idx].sh_size, 1, fp);
	if(ret != 1) return 1;
	for(int i = 0; i < sym_num; i++) {
		if(ELF32_ST_TYPE(sym[i].st_info) == STT_FUNC) {
			assert(func_add_table.count < MAX_FUNCNUM);
			func_add_table.address_b[func_add_table.count] = sym[i].st_value;
			func_add_table.address_e[func_add_table.count] = sym[i].st_value + sym[i].st_size;
			fseek(fp, strtab_off + sym[i].st_name, SEEK_SET);
			while(1) {
				ret = fread(&buf[count], 1, 1, fp);
				if(ret != 1) return 1;
				if(buf[count] == '\0') {
					strcpy(func_add_table.name[func_add_table.count], buf);
					count = 0;
					break;
				}
				count++;	
			}	
			func_add_table.count++;
		}
	}
	
	fclose(fp);
	fp = NULL;
	return 0;
}

void Ftrace(uint32_t pc, uint32_t inst) {
#ifdef CONFIG_FTRACE
	assert(func_call_info.count < MAX_CALL_RET);
	
	uint32_t dnpc = 0;
	uint32_t imm;
	if(inst == 0x8067) {
		//ret
		dnpc = gpr_read(1);
		func_call_info.type[func_call_info.count] = 'r';
	}else if(((inst >> 12) & 0x7) == 0 && (inst & 0x7F) == 0x67) {
		//jalr
		imm = SEXT(inst >> 20, 12);
		dnpc = (gpr_read(((inst >> 15) & 0x1F)) + imm) & 0xFFFFFFFE;
		func_call_info.type[func_call_info.count] = 'c';
	}else if((inst & 0x7F) == 0x6F) {
		//jal
		imm = SEXT(((inst & 0x80000000) >> 11) | ((inst & 0x7FE00000) >> 20) | ((inst & 100000) >> 9) | (inst & 0xFF000), 21);
		dnpc = pc + imm;
		func_call_info.type[func_call_info.count] = 'c';
	}else {
		return;
	}
	func_call_info.pc[func_call_info.count] = pc;
	
	int i;
	for(i = 0; i < func_add_table.count; i++) {
		if(dnpc >= func_add_table.address_b[i] && dnpc < func_add_table.address_e[i]) {
			strcpy(func_call_info.info[func_call_info.count], func_add_table.name[i]);
			break;
		}
	}
	if(i == func_add_table.count) {
		strcpy(func_call_info.info[func_call_info.count], "???");
	}
	func_call_info.count++;
#endif
}

void Ftrace_report() {
#ifdef CONFIG_FTRACE
	printf("Ftrace information:\n");
	for(int i = 0; i < func_call_info.count; i++) {
		if(func_call_info.type[i] == 'c') {
			printf("%x:  call %s\n", func_call_info.pc[i], func_call_info.info[i]);
		}else {
			printf("%x:  ret  %s\n", func_call_info.pc[i], func_call_info.info[i]);
		}
	}
	printf("\n");
#endif
}

static long load_memory(const char *filename) {
	if(filename == NULL) {
		printf("No img is given\n");
		exit(0);
	}
	FILE *fp = fopen(filename, "rb");
	assert(fp);

	fseek(fp, 0, SEEK_END);
	long img_size = ftell(fp);

	printf("Img is %s\n, size = %ld", filename, img_size);
	assert(img_size < PMEM_SIZE);
	
	fseek(fp, 0, SEEK_SET);
	int ret = fread(&pmem, img_size, 1, fp);
	assert(ret == 1);

	fclose(fp);
	fp = NULL;
	return img_size;
}
/*
static long load_memory(const char *filename) {
	if(filename == NULL) {
		printf("No img is given\n");
		exit(0);
	}
	FILE *fp = fopen(filename, "rb");
	int ret;
	int img_size = 0;
	assert(fp);
	printf("Img is %s\n", filename);
	for(int i = 0; feof(fp) != 1; i++) {
		ret = fread(&pmem[i], 4, 1, fp);
		if(ret != 1) break;
		img_size++;
	}
	printf("Img_size is %d bytes\n", img_size * 4);
	assert(img_size < PMEM_SIZE);
	fclose(fp);
	fp = NULL;
}
*/
static int parse_args(int argc, char *argv[]) {
	const struct option table[] = {
		{"ftrace"  , required_argument	, NULL	, 'f'},
		{"diff"	   , required_argument  , NULL  , 'd'},
		{0	   ,	0		, NULL	,  0},
	};
	int o;
	while( (o = getopt_long(argc, argv, "-f:d:", table, NULL)) != -1) {
		switch(o) {
			case 'f': elf_file = optarg; analyze_elf(); break;
			case 'd': diff_so_file = optarg; break;
			case 1: img_file = optarg; return 0;
			default:
				printf("\t-f,--ftrace=ELF_FILE	include elf file ELF_FILE to enable function trace\n");
				printf("\t-d,--diff=REF_SO	run Difftest with reference REF_SO\n");
				printf("\n");
				exit(0);
		}
	}
	return 0;
}

void init_monitor(int argc, char *argv[]) {
	parse_args(argc, argv);
	long img_size = load_memory(img_file);
	
#ifdef CONFIG_DIFFTEST
	init_difftest(diff_so_file, img_size, 666);
#endif
	init_sdb();
#ifdef CONFIG_ITRACE
	init_disasm();
#endif
}
