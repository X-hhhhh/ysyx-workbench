module rom(
	input	wire			sys_clk,
	input	wire			sys_rst,
	//AXI4-Lite interface
	input	wire				axi_arvalid,
	input	wire	[31:0]		axi_araddr,
	output	wire				axi_arready,

	input	wire				axi_rready,
	output	reg		[31:0]		axi_rdata,
	output	reg		[2:0]		axi_rresp,
	output	reg					axi_rvalid,

	input	wire				axi_awvalid,
	input	wire	[31:0]		axi_awaddr,
	output	wire				axi_awready,

	input	wire	[31:0]		axi_wdata,
	input	wire	[3:0]		axi_wstrb,
	input	wire				axi_wvalid,
	output	wire				axi_wready,

	input	wire				axi_bready,
	output	wire	[2:0]		axi_bresp,
	output	wire				axi_bvalid
);

import "DPI-C" function int pmem_read(input int paddr);

parameter	IDLE 				= 3'b001,
			WAIT_ARVALID_FALL	= 3'b010,
			WAIT_RREADY			= 3'b100;	

wire			axi_arvalid_fall;

reg		[2:0]	state;
reg				axi_arvalid_reg;
reg		[31:0]	axi_araddr_reg;

assign axi_arready = (state == IDLE);

assign axi_awready = 1'b0;
assign axi_wready = 1'b0;
assign axi_bresp = 3'b0;
assign axi_bvalid = 1'b0;

assign axi_arvalid_fall = ~axi_arvalid && axi_arvalid_reg;

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_arvalid_reg <= 1'b0;
		axi_araddr_reg <= 32'b0;
	end else begin
		axi_arvalid_reg <= axi_arvalid;
		axi_araddr_reg <= axi_araddr;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		state <= IDLE;
	end else begin
		case(state)
			IDLE: 
				if(axi_arvalid) begin
					state <= WAIT_ARVALID_FALL;
				end
			WAIT_ARVALID_FALL:
				if(axi_arvalid_fall) begin
					state <= WAIT_RREADY;
				end
			WAIT_RREADY:
				if(axi_rready) begin
					state <= IDLE;
				end
			default: state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_rdata <= 32'b0;
		axi_rresp <=  3'b0;
		axi_rvalid <= 1'b0;
	end	else if(state == WAIT_ARVALID_FALL && axi_arvalid_fall) begin
		axi_rdata <= pmem_read(axi_araddr_reg);
		axi_rresp <=  3'b0;
		axi_rvalid <= 1'b1;
	end else if(state == WAIT_RREADY && axi_rready) begin
		axi_rdata <= 32'b0;
		axi_rresp <=  3'b0;
		axi_rvalid <= 1'b0;
	end
end

endmodule

