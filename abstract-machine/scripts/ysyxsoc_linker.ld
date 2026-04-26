MEMORY {
	ROM(rx) : ORIGIN = 0x20000000, LENGTH = 4K
	RAM(rwx) : ORIGIN = 0x0F000000, LENGTH = 8K
}

ENTRY(_start)

SECTIONS {
	.text : {
		*(entry)
		*(.text*)
	} > ROM
	etext = .;
	_etext = .;
	.rodata : {
		*(.rodata*)
	} > ROM
	.data : {
		_data_start = .;
		*(.data*)
		_data_end = .;
	} > RAM AT> ROM
	_data_loadaddr = LOADADDR(.data);
	edata = .;
	_data = .;
	.bss : {
		_bss_start = .;
		*(.bss*)
		*(.sbss*)
		*(.scommon)
	} > RAM
	/*below regions are ram*/
	_stack_top = ALIGN(0x10);
	/*stack size is 4K*/
	. = _stack_top + 0x1000;
	_stack_pointer = .;
	end = .;
	_end = .;
	_heap_start = ALIGN(0x10);
}
