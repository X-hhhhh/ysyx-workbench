module IFU(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input 	wire	[31:0]	pc,

	output	reg		[31:0]	inst,
	output	reg		[1:0]	ifu_state,
	output	wire			pc_add_en
);

parameter 	IDLE	= 2'b01,		//set raddr status
			WAIT	= 2'b10;		//wait until the instruction execution is completed

parameter	LSU_WB	= 2'b10;

import "DPI-C" function int pmem_read(input int paddr);

export "DPI-C" function dpi_inst_get;
export "DPI-C" function dpi_ifu_state_get;

function int dpi_inst_get();
	return inst;
endfunction

function int dpi_ifu_state_get();
	return {30'b0, ifu_state};
endfunction

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		pc_add_en <= 1'b0;
	end else if(ifu_state == IDLE) begin
		pc_add_en <= 1'b1;
	end else begin
		pc_add_en <= 1'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		ifu_state <= IDLE;
	end else begin
		case(ifu_state)
			IDLE: ifu_state <= WAIT;
			WAIT: ifu_state <= IDLE;
			default: ifu_state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		inst <= 32'h80000000;
	end	else begin
		case(ifu_state)
			IDLE: inst <= pmem_read(pc);
			WAIT: inst <= 32'h80000000;
			default: inst <= 32'h80000000;
		endcase
	end
end

endmodule

