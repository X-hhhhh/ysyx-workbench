.section entry, "ax"
.globl _start
.type _start, @function

_start:
	//copy .data segments from rom to ram
	la t0, _data_loadaddr
	la t1, _data_start
	la t2, _data_end
	beq t1, t2, _s2

_s1:
	lw a5, 0(t0)
	sw a5, 0(t1)
	addi t0, t0, 4
	addi t1, t0, 4
	blt t1, t2, _s1

_s2:
	mv s0, zero	
	la sp, _stack_pointer
	call _trm_init

.size _start, . - _start
