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

#include "sdb.h"

#define NR_WP 32

typedef struct watchpoint {
  int NO;
  char expr[128];
  word_t val_old;
  struct watchpoint *next;

  /* TODO: Add more members if necessary */

} WP;

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

int new_wp(char *expression) {
	if(free_ == NULL) {return -1;}

	bool success;
	word_t val = expr(expression, &success);
	if(success == false) {return -2;}

	if(head == NULL) {
		head = free_;
		free_ = free_ -> next;
		head -> next = NULL;
		strcpy(head -> expr, expression);
		head -> val_old = val;
		return head -> NO;
	}

	WP *new_w = free_;

	free_ = free_ -> next;
	
	new_w -> next = head;
	strcpy(new_w -> expr, expression);
	new_w -> val_old = val;

	head = new_w;

	return new_w -> NO;
}

void free_wp(int NO) {
	if(NO < 0 || NO >= NR_WP) {return;}
	
	WP *wp = head;
	WP *node = NULL;	//node before wp
	while(wp != NULL && wp -> NO != NO) {
		node = wp;
		wp = wp -> next;
	}

	//watchpoint NO isn't exist
	if(wp == NULL) {return;}

	if(wp == head) {
		head = head -> next;
		wp -> next = free_;
		free_ = wp;
	}else {
		node -> next = wp -> next;
		wp -> next = free_;
		free_ = wp;
	}
}

void display_wp() {
	WP *wp = head;
	if(head == NULL) {
		printf("There are no watchpoints\n");
	}else {
		printf("Num	What\n");
		while(wp != NULL){
			printf("%d	%s\n", wp -> NO, wp -> expr);
			wp = wp -> next;
		}
	}
}

bool scan_wp() {
	if(head == NULL) {return false;}

	WP *wp = head;
	bool success;
	bool triggered = false;
	word_t val_new;
	while(wp != NULL) {
		val_new = expr(wp -> expr, &success);
		if(success == true) {
			if(val_new != wp -> val_old) {
				printf("Watchpoint %d: %s\n", wp -> NO, wp -> expr);
				printf("Old_value: 0x%x\n", wp -> val_old);
				printf("New_value: 0x%x\n\n", val_new);

				wp -> val_old = val_new;
				triggered = true;
			}
		}else {
			printf("Watchpoint %d: %s evaluation falied, but the value of variable changed\n", wp -> NO, wp -> expr);
			printf("Old_value: 0x%x\n", wp -> val_old);
		}

		wp = wp -> next;
	}
	return triggered;
}

