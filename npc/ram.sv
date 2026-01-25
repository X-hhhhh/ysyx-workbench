module mem(
	input	wire				sys_clk,
	input	wire				sys_rst,
	input	wire				reqValid,
	input	wire	[31:0]		addr,
	input	wire	[31:0]		wdata,
	input	wire				wen,
	input	wire	[3:0]		mask,
	input	wire				ren,

	output	reg					resValid,
	output	reg		[31:0]		rdata
);

import "DPI-C" function int pmem_read(int paddr);
import "DPI-C" function void pmem_write(int paddr, int wdata, byte wmask);

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		rdata <= 32'b0;
	end else if(reqValid) begin
		rdata <= pmem_read(addr);
	end
end


always@(posedge sys_clk or sys_rst) begin
	if(sys_rst) begin
		resValid <= 1'b0;
	end else begin
		resValid <= ;
	end
end

endmodule

