module	ram
(
	input	wire				sys_clk,
	input	wire				sys_rst,
	//AXI4-Lite interface
	input	wire				axi_arvalid,
	input	wire	[31:0]		axi_araddr,
	output	wire				axi_arready,

	input	wire				axi_rready,
	output	reg		[31:0]		axi_rdata,
	output	reg		[1:0]		axi_rresp,
	output	reg					axi_rvalid,

	input	wire				axi_awvalid,
	input	wire	[31:0]		axi_awaddr,
	output	wire				axi_awready,

	input	wire	[31:0]		axi_wdata,
	input	wire	[3:0]		axi_wstrb,
	input	wire				axi_wvalid,
	output	wire				axi_wready,

	input	wire				axi_bready,
	output	reg		[1:0]		axi_bresp,
	output	reg					axi_bvalid
);

import "DPI-C" function int pmem_read(int paddr);
import "DPI-C" function void pmem_write(int paddr, int wdata, byte wmask);

parameter 	IDLE					= 4'b0001,
			WAIT_AR_AW_WVALID_FALL	= 4'b0010,
			WAIT_RREADY				= 4'b0100,
			WAIT_BREADY				= 4'b1000;

wire			axi_arvalid_fall;

reg		[3:0]	rstate;
reg		[3:0]	wstate;

reg				waddr_received;
reg				wdata_received;
reg		[31:0]	raddr_reg;
reg		[31:0]	waddr_reg;
reg		[31:0]	wdata_reg;
reg		[3:0]	wstrb_reg;

reg				axi_arvalid_reg;

assign axi_arready = (rstate == IDLE);
assign axi_awready = ~waddr_received; 
assign axi_wready  = ~wdata_received;

assign axi_arvalid_fall = ~axi_arvalid && axi_arvalid_reg;

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_arvalid_reg <= 1'b0;
		raddr_reg <= 32'b0;
	end else begin
		axi_arvalid_reg <= axi_arvalid;
		raddr_reg <= axi_araddr;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		waddr_received <= 1'b0;
	end else if(wstate == WAIT_BREADY && axi_bready) begin
		waddr_received <= 1'b0;
	end else if(wstate == IDLE && axi_awvalid) begin
		waddr_received <= 1'b1;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		wdata_received <= 1'b0;
	end else if(wstate == WAIT_BREADY && axi_bready) begin
		wdata_received <= 1'b0;
	end else if(wstate == IDLE && axi_wvalid) begin
		wdata_received <= 1'b1;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		waddr_reg <= 32'b0;
	end else if(wstate == IDLE && axi_awvalid) begin
		waddr_reg <= axi_awaddr;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		wdata_reg <= 32'b0;
		wstrb_reg <= 4'b0;
	end else if(wstate == IDLE && axi_wvalid) begin
		wdata_reg <= axi_wdata;
		wstrb_reg <= axi_wstrb;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		rstate <= IDLE;
	end else begin
		case(rstate)
			IDLE:
				if(axi_arvalid) begin
					rstate <= WAIT_AR_AW_WVALID_FALL;
				end
			WAIT_AR_AW_WVALID_FALL:
				if(axi_arvalid_fall) begin
					rstate <= WAIT_RREADY;
				end
			WAIT_RREADY:
				if(axi_rready) begin
					rstate <= IDLE;
				end
			default: rstate <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		wstate <= IDLE;
	end else begin
		case(wstate)
			IDLE:
				if(waddr_received && wdata_received) begin
					wstate <= WAIT_BREADY;
				end
			WAIT_BREADY:
				if(axi_bready) begin
					wstate <= IDLE;
				end
			default: wstate <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_rdata <= 32'b0;
		axi_rresp <= 2'b0;
		axi_rvalid <= 1'b0;
	end else if(rstate == WAIT_AR_AW_WVALID_FALL && axi_arvalid_fall) begin
		axi_rdata <= pmem_read(raddr_reg);
		axi_rresp <= 2'b0;
		axi_rvalid <= 1'b1;
	end else if(rstate == WAIT_RREADY && axi_rready) begin
		axi_rdata <= 32'b0;
		axi_rresp <= 2'b0;
		axi_rvalid <= 1'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(wstate == IDLE && waddr_received && wdata_received) begin
		pmem_write(waddr_reg, wdata_reg, {4'b0, wstrb_reg});
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_bresp <= 2'b0;
		axi_bvalid <= 1'b0;
	end else if(wstate == WAIT_BREADY && axi_bready) begin
		axi_bresp <= 2'b0;
		axi_bvalid <= 1'b1;
	end else begin
		axi_bresp <= 2'b0;
		axi_bvalid <= 1'b0;
	end
end

endmodule

