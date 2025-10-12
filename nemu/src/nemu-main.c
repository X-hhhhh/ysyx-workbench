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

#include <common.h>


#include "monitor/sdb/sdb.h"
#include "isa.h"



void init_monitor(int, char *[]);
void am_init_monitor();
void engine_start();
int is_exit_status_bad();

int main(int argc, char *argv[]) {
  /* Initialize the monitor. */
#ifdef CONFIG_TARGET_AM
  am_init_monitor();
#else
  init_monitor(argc, argv);
#endif

	/* test  	
	FILE * fp = fopen("tools/gen-expr/input", "r");
	if(fp == NULL) {
		printf("error opening file");
		return 1;
	}

	int res;
	int exp;
	int r1;
	char *r2;
	char buf_str[1000];
	int cycle = 2000;
	bool success;
	while(!feof(fp) && cycle) {
		r1 = fscanf(fp, "%d", &res);	
		if(r1 == EOF) {break;}	
		
		r2 = fgets(buf_str, 1000, fp);	
		if(r2 == NULL) {break;}

		buf_str[strcspn(buf_str, "\n")] = '\0';
		
		exp = expr(buf_str, &success);
		
		printf("exp=%d, res=%d\n", exp, res);
		Assert(exp == res, "%d\n", 2000 - cycle);

		cycle--;
	}


	fclose(fp);
	fp = NULL;
	*/	

 
  	cpu.gpr[1] = 1;
  	cpu.gpr[2] = 2;

	bool success;
	char str[32] = "--- 1";
	int exp = expr(str, &success);
	printf("exp=%d, success=%d", exp, success);





  /* Start engine. */
  engine_start();

  return is_exit_status_bad();
}
