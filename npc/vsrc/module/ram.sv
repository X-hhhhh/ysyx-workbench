module	ram
(
	input	wire				sys_clk,
	input	wire				sys_rst,
	input	wire	[31:0] 		lsu_addr,
	input	wire	[31:0]		lsu_wdata,
	input	wire				lsu_wen,
	input	wire	[3:0]		lsu_wmask,
	input	wire				lsu_reqValid,
	input	wire				lsu_respReady,

	output	reg 	[31:0]		lsu_rdata,
	output	reg					lsu_respValid,
	output	reg					lsu_reqReady
);

import "DPI-C" function int pmem_read(int paddr);
import "DPI-C" function void pmem_write(int paddr, int wdata, byte wmask);

parameter 	IDLE			= 2'b01,
			WAIT_RESPREADY	= 2'b10;

reg		[1:0]	state;

assign lsu_reqReady = (state == IDLE);

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		state <= IDLE;
	end else begin
		case(state)
			IDLE: 
				if(lsu_reqValid) begin
					state <= WAIT_RESPREADY;
				end
			WAIT_RESPREADY:
				if(lsu_respReady) begin
					state <= IDLE;
				end
			default: state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		lsu_rdata <= 32'b0;
	end else if(state == IDLE && lsu_reqValid) begin
		if(!lsu_wen) begin
			lsu_rdata <= pmem_read(lsu_addr);
		end else begin
			lsu_rdata <= 32'b0;
			pmem_write(lsu_addr, lsu_wdata, {4'b0, lsu_wmask});
		end
	end else if(state == WAIT_RESPREADY && lsu_respReady) begin
		lsu_rdata <= 32'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		lsu_respValid <= 1'b0;
	end else if(state == IDLE && lsu_reqValid) begin
		lsu_respValid <= 1'b1;
	end else if(state == WAIT_RESPREADY && lsu_respReady) begin
		lsu_respValid <= 1'b0;
	end
end

endmodule

