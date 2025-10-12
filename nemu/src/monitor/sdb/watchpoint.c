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
  bool enabled;
  struct watchpoint *next;

  /* TODO: Add more members if necessary */

} WP;

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].enabled = false;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

WP* new_wp() {
	if(free_ == NULL) {
		return NULL;
	}
	if(head == NULL) {
		head = free_;
		free_ = free_ -> next;
		head -> next = NULL;
		head -> enabled = true;
		return head;
	}

	WP *new_w = free_;

	free_ = free_ -> next;
	
	new_w -> next = head;
	new_w -> enabled = true;
	head = new_w;

	return new_w;
}

void free_wp(WP* wp) {
	if(wp == NULL || wp -> enabled == false) {return;}
	if(wp == head) {
		head = head -> next;
		wp -> next = free_;
		wp -> enabled = false;
		free_ = wp;
	}else {
		WP *node = head;
		WP *free_node;

		//search for the node before wp
		while(node -> next != wp) {
			node = node -> next;
		}
		free_node = node -> next;

		node -> next = wp -> next;

		free_node -> next = free_;
		free_node -> enabled = false;
		free_ = free_node;
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

	new_wp();
	print_node(head);
	print_node(free_);

	new_wp();
	print_node(head);
	print_node(free_);

	WP *wp = new_wp();
	print_node(head);
	print_node(free_);

	free_wp(wp);
	print_node(head);
	print_node(free_);
	
}


/* TODO: Implement the functionality of watchpoint */


