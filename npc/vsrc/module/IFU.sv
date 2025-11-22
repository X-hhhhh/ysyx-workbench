module IFU(
	input	wire		sys_rst,
	input 	wire	[31:0]	pc,

	output	wire	[31:0]	inst
);

import "DPI-C" function int pmem_read(input int paddr);

export "DPI-C" function dpi_inst_get;

function int dpi_inst_get();
	return inst;
endfunction

assign inst = (sys_rst == 1'b0) ? pmem_read(pc) : 32'b0;

endmodule

