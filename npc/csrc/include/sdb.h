#ifndef SDB_H__
#define SDB_H__

void sdb_mainloop();

//expr
uint32_t expr(char *e, bool *success);
void init_regex();

//watchpoint
void init_wp_pool();
int new_wp(char *expression);
void free_wp(int NO);
void display_wp();
bool scan_wp();

//monitor
void init_monitor();

#endif
