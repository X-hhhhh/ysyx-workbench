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

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ, TK_DEC_INT

  /* TODO: Add more token types */

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\+", '+'},         // plus
  {"==", TK_EQ},        // equal
  {"[0-9]+", TK_DEC_INT},
  {"-", '-'},
  {"\\*", '*'},
  {"/", '/'},
  {"\\(", '('},
  {"\\)", ')'},
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[32] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */

	// if substr is longer than 32 bytes, add code..


        switch (rules[i].token_type) {
		case '+':
			tokens[nr_token].type = '+';
			break;
		case '-':
			tokens[nr_token].type = '-';
			break;
		case TK_EQ:
			tokens[nr_token].type = TK_EQ;
			break;
		case '*':
			tokens[nr_token].type = '*';
			break;
		case '/':
			tokens[nr_token].type = '/';
			break;
		case '(':
			tokens[nr_token].type = '(';
			break;
		case ')':
			tokens[nr_token].type = ')';
			break;
		case TK_DEC_INT:
			tokens[nr_token].type = TK_DEC_INT;
			strncpy(tokens[nr_token].str, substr_start, substr_len);	//record data values
			tokens[nr_token].str[substr_len] = '\0';			//add '\0' to make sure it is a string
			break;
		default: 
			break;
        }
	
	if(rules[i].token_type != TK_NOTYPE) {
		nr_token++;
	}

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

static int check_parentheses(int p, int q) {
	bool matched1 = false;
	bool matched2 = false;
	if(tokens[p].type == '(' && tokens[q].type == ')') {
		matched1 = true;		//parentheses matched
	}
	
	char stack[32];
	int top = -1;
	int first_par_exi = 1;

	for(int i = p; i <= q; i++) {
		if(tokens[i].type == '(') {
			stack[++top] = '(';
		}else if(tokens[i].type == ')') {
			if(top != -1) {
				char ch = stack[top];
				if(ch == '(') {
					if(i == q && first_par_exi == 1) {matched2 = true;}
					if(top == 0) {
						first_par_exi = 0;
					}
					top--;
				}
				else {return -1;}
			}else {return -1;}
		}
	}

	if(top == -1) {
		if(matched1 == true && matched2 == true) {
			return 0;	//matched and valid expression
		}else {
			return 1;	//not matched and valid expression
		}
	}else {
		return -1;		//invalid expression
	}
}

static uint32_t eval(int p, int q, bool *valid) {
	*valid = true;
	if(p > q) {
		return 0;		
	}else if (p == q) {
		return atoi(tokens[p].str);
	}else if(check_parentheses(p, q) == 0) {
		return eval(p + 1, q - 1, valid);	
	}else if(check_parentheses(p, q) == -1){
		*valid = false;
		return -1;
	}else {
		int par_num = 0;
		int main_op_pos = 0;
		for(int i = p; i <= q; i++) {
			switch(tokens[i].type) {
				case '(': 
					par_num++;
					break;
				case ')':
					par_num--;
					break;
				case '+':
				case '-':
					if(par_num == 0) {
						main_op_pos = i;
					}
					break;
				case '*':
				case '/':
					if(par_num == 0 && tokens[main_op_pos].type != '+' &&
						tokens[main_op_pos].type != '-') {
						main_op_pos = i;
					}
					break;
				default: break;
			}
		}
		
		bool valid_t;
		uint32_t val1 = eval(p, main_op_pos - 1, valid); 
		uint32_t val2 = eval(main_op_pos + 1, q, &valid_t);
		*valid = (*valid) ? valid_t : false;

		switch(tokens[main_op_pos].type) {
			case '+': return val1 + val2; break;
			case '-': return val1 - val2; break;
			case '*': return val1 * val2; break;
			case '/': return val1 / val2; break;
			default: 
				  valid = false;
				  return -1;
		}
	}
}

word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */

  
  for(int i = 0; i < nr_token; i++) {
  	printf("tokens[%d].type=%d, str=%s\n", i, tokens[i].type, tokens[i].str);
  }

	printf("check_parentheses=%d\n", check_parentheses(0, nr_token - 1));

	bool valid;
	printf("expr=%d", eval(0, nr_token - 1, &valid));
	printf("valid=%d\n", valid);


  return 0;
}
