#include <Vtop.h>
#include <stdio.h>
#include <getopt.h>

#include <sdb.h>
#include <pmem.h>
#include <macro.h>
#include <wave_trace.h>
#include <cpu.h>

static char* img_file = NULL;

void load_memory(const char *filename) {
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

static void reset(int n){
	top -> sys_rst = 1;
	while(n-- > 0){
		top -> sys_clk = 1; top -> eval(); wave_trace();
		top -> sys_clk = 0; top -> eval(); wave_trace();
	}
	top -> sys_rst = 0;
}

static int parse_args(int argc, char *argv[]) {
	const struct option table[] = {
		{"img"	, required_argument, NULL, 'i'},	
		{0      ,   		  0, NULL, 0},
	};
	int o;
	while( (o = getopt_long(argc, argv, "-i:", table, NULL)) != -1) {
		switch(o) {
			case 1: img_file = optarg; return 0;
			default:
				  printf("-i, --img: import an img file\n");
				  exit(0);
		}
	}
	return 0;
}

int main(int argc, char* argv[]){
	wave_trace_init(argc, argv);

	init_monitor();

	parse_args(argc, argv);
	load_memory(img_file);
	printf("Welcome to " ANSI_FG_YELLOW ANSI_BG_RED "NPC!" ANSI_NONE "\n");

	int reset_time = 10;
	while(reset_time-- > 0){
		reset(1);
	}
	top -> eval(); wave_trace();
	top -> eval(); wave_trace();

	
	sdb_mainloop();

	wave_trace_end();

	return 0;
}

