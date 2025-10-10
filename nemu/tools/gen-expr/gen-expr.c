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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {};
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

static char gen_operator() {
	char operators[] = {'+', '-', '*', '/'};
	return operators[rand() % 4];
}

static int gen_operand(int min, int max) {
	return rand() % (max - min + 1) + min;	//generate num between min and max
}

static void gen_rand_expr(char *buf, int max_depth) {
	if(max_depth <= 0) {
		sprintf(buf, "%d", rand() % 10 + 1);
		return;
	}
	switch(rand() % 10) {
		case 0:
			sprintf(buf, "%d", rand() % 10 + 1);
			break;
		case 1:
			char buf_t[500];
			gen_rand_expr(buf_t, max_depth - 1);
			sprintf(buf, "(%s)", buf_t);
			break;
		default:
			char left[500];
			char right[500];
			char op = gen_operator();
			
			if(op == '+' || op == '*'){
				gen_rand_expr(left, max_depth - 1);
				gen_rand_expr(right, max_depth - 1);
				sprintf(buf, "%s %c %s", left, op, right);
			}else if(op == '-'){
				sprintf(left, "%d", gen_operand(10, 20));
				sprintf(right, "%d", gen_operand(1, 9));
				sprintf(buf, "(%s %c %s)", left, op, right);
			}else {
				sprintf(left, "%d", gen_operand(10, 20));
				sprintf(right, "%d", gen_operand(1, 9));	
				sprintf(buf, "(%s %c %s)", left, op, right);
			}

			break;
	}

	return;
}

int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {
    gen_rand_expr(buf, 15);

    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp);

    printf("%u %s\n", result, buf);
  }
  return 0;
}
