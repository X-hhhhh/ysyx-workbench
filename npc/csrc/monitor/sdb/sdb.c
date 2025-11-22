#include <common.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <cpu.h>
#include <pmem.h>
#include <reg.h>
#include <sdb.h>

#define SET_BATCH_MODE 1

static int cmd_c(char *args) {
	cpu_exec(-1);
	return 0;
}

static int cmd_q(char *args) {
	npc_state.state = NPC_QUIT;
	return -1;
}

static int cmd_si(char *args) {
	if(args == NULL) {
		cpu_exec(1);
	}else {
		cpu_exec(atoi(args));
	}
	return 0;
}

static int cmd_info(char *args) {
	if(args == NULL) {
		printf("cmd \"info\" needs an argument");
	}else if(strcmp(args, "r") == 0) {
		riscve_reg_display();
	}else if(strcmp(args, "w") == 0) {
		display_wp();
	}
	return 0;
}

static int cmd_x(char *args) {
	char *arg = strtok(NULL, " ");
	if(arg == NULL) {
		printf("cmd \"x\" needs two arguments\n");
		return 1;
	}

	int n = atoi(arg);
	if(n == 0) {
		printf("The first argument must be an integer\n");
		return 1;
	}
	arg = strtok(NULL, "\0");
	if(arg == NULL) {
		printf("cmd \"x\" needs two arguments\n");
		return 1;
	}

	bool success;
	uint32_t paddr_b = expr(arg, &success);
	if(success == false) {
		printf("There are errors in the expression\n");
	}

	for(int i = 0; i < n; i++) {
		int paddr = paddr_b + i * 4;
		if(in_pmem(paddr)) {
			printf("0x%x: 0x%x\n", paddr, pmem_rd(paddr));
		}else {
			printf("paddr:[%x, %x] out of range [%x, %x)\n", paddr, paddr + 4, PMEM_BASE, PMEM_BASE + PMEM_SIZE * 4);
			break;
		}
	}
	return 0;
}

static int cmd_p(char *args) {
	if(args == NULL) {
		printf("cmd \"p\" needs an expression\n");
		return 1;
	}
	bool success;
	word_t exp = expr(args, &success);
	if(success == false) {
		printf("There are errors in the expression\n");
		return 1;
	}
	printf("=%d\n", exp);
	return 0;
}

static int cmd_w(char *args) {
	if(args == NULL) {
		printf("cmd \"w\" needs an expression\n");
		return 1;
	}

	int NO = new_wp(args);
	if(NO == -1) {
		printf("The number of watchpoints has reached the maximum limit\n");
		return 1;
	}
	if(NO == -2) {
		printf("There are errors in the expression\n");
		return 1;
	}
	printf("watchpoint:%d\n", NO);
	return 0;
}

static int cmd_d(char *args) {
	if(args == NULL) {
		printf("cmd \"d\" needs an argument\n");
		return 1;
	}

	int NO = atoi(args);
	if(NO == 0 && args[0] != '0') {
		printf("cmd \"d\" needs an integer\n");
		return 1;
	}
	free_wp(NO);
	return 0;
}

static struct {
	const char *name;
	const char *description;
	int (*handler) (char*);
}cmd_table[] = {
	{"c", "Run NPC", cmd_c},
	{"q", "Exit NPC", cmd_q},
	{"si", "Execute n instructions, the default value of n is 1", cmd_si},
	{"info", "Display informations about gprs or watchpoints", cmd_info},
	{"x", "Scan memory", cmd_x},
	{"p", "Evaluate expressions", cmd_p},
	{"w", "Set up a watchpoint", cmd_w},
	{"d", "Delete a watchpoint", cmd_d},
};

#define NR_CMD ARRLEN(cmd_table)

static char* rl_gets() {
	static char *line_read = NULL;
	if(line_read) {
		free(line_read);
		line_read = NULL;
	}

	line_read = readline("(npc) ");

	if(line_read && *line_read) {
		add_history(line_read);
	}

	return line_read;
}

void sdb_mainloop() {
	if(SET_BATCH_MODE) {
		cpu_exec(-1);
		return;
	}
	for(char *str; (str = rl_gets()) != NULL; ) {
		char *str_end = str + strlen(str);

		char *cmd = strtok(str, " ");
		if(cmd == NULL) {continue;}

		char *args = cmd + strlen(cmd) + 1;
		if(args >= str_end) {
			args = NULL;	
		}

		int i;
		for(i = 0; i < NR_CMD; i++) {
			if(strcmp(cmd, cmd_table[i].name) == 0) {
				//call function, if the return value is less than 0, stop mainloop
				if(cmd_table[i].handler(args) < 0) {return;}
				break;
			}
		}
		if(i == NR_CMD) {printf("Unknown command '%s'\n", cmd);}
	}
}

void init_sdb() {
	//init expr
	init_regex();
	//init watchpoint
	init_wp_pool();
}

