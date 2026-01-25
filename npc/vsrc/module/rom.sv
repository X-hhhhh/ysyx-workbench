module rom(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input	wire	[31:0]	ifu_raddr,
	input	wire			ifu_reqValid,
	input	wire			ifu_respReady,

	output	reg		[31:0]	ifu_rdata,
	output	reg				ifu_respValid,
	output	reg				ifu_reqReady
);

import "DPI-C" function int pmem_read(input int paddr);

parameter	IDLE 			= 2'b01,
			WAIT_RESPREADY	= 2'b10;	

reg		[1:0]	state;

assign ifu_reqReady = (state == IDLE);

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		state <= IDLE;
	end else begin
		case(state)
			IDLE: 
				if(ifu_reqValid) begin
					state <= WAIT_RESPREADY;
				end
			WAIT_RESPREADY:
				if(ifu_respReady) begin
					state <= IDLE;
				end
			default: state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		ifu_rdata <= 32'b0;
	end	else if(state == IDLE && ifu_reqValid) begin
		ifu_rdata <= pmem_read(ifu_raddr);
	end else if(state == WAIT_RESPREADY && ifu_respReady) begin
		ifu_rdata <= 32'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		ifu_respValid <= 1'b0;
	end else if(state == IDLE && ifu_reqValid) begin
		ifu_respValid <= 1'b1;
	end else if(ifu_respReady) begin
		ifu_respValid <= 1'b0;
	end
end

endmodule

