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
  char *expr;
  struct watchpoint *next;

  /* TODO: Add more members if necessary */

} WP;

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].expr = NULL;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

int new_wp(char *expr) {
	if(free_ == NULL) {
		return -1;
	}

	if(head == NULL) {
		head = free_;
		free_ = free_ -> next;
		head -> next = NULL;
		head -> expr = expr;
		return head -> NO;
	}

	WP *new_w = free_;

	free_ = free_ -> next;
	
	new_w -> next = head;
	new_w -> expr = expr;
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

void print_node(WP *w) {
	WP *node = w;
	while(node != NULL) {
		printf("0x%p->", node);
		node = node -> next;
	}
	printf("\n");
}

void test() {
	init_wp_pool();
	print_node(free_);

	new_wp("1");
	print_node(head);
	print_node(free_);

	new_wp("2");
	print_node(head);
	print_node(free_);

	new_wp("3");
	print_node(head);
	print_node(free_);

	free_wp(1);
	print_node(head);
	print_node(free_);
	
	free_wp(0);
	print_node(head);
	print_node(free_);

	free_wp(2);
	print_node(head);
	print_node(free_);

	free_wp(1);
	free_wp(2);
	free_wp(3);
}


/* TODO: Implement the functionality of watchpoint */


