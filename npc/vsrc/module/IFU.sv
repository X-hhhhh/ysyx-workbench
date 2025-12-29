module IFU(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input 	wire	[31:0]	pc,
	input	wire			idu_ready,
	input	wire			wbu_inst_end,

	output	wire			ifu_valid,
	output	reg		[31:0]	inst
);

parameter 	IDLE		= 2'b01,		//set raddr status
			WAIT_READY	= 2'b10;		//wait until the instruction execution is completed

import "DPI-C" function int pmem_read(input int paddr);

export "DPI-C" function dpi_inst_get;
export "DPI-C" function dpi_ifu_state_get;

function int dpi_inst_get();
	return inst;
endfunction

function int dpi_ifu_state_get();
	return {30'b0, ifu_state};
endfunction

reg		[1:0]	ifu_state;
reg				startup;

assign ifu_valid = (ifu_state == WAIT_READY);

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		startup <= 1'b0;
	end else if(ifu_state == WAIT_READY) begin
		startup <= 1'b1;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		ifu_state <= IDLE;
	end else begin
		case(ifu_state)
			IDLE:
				if(wbu_inst_end || ~startup) begin
					ifu_state <= WAIT_READY;
				end
			WAIT_READY: 
				if(idu_ready) begin
					ifu_state <= IDLE;
				end
			default: ifu_state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		inst <= pmem_read(32'h80000000);
	end	else if(wbu_inst_end || ~startup) begin
		inst <= pmem_read(pc);
	end
end

endmodule

