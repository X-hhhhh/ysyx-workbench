module 	uart_ctrl(
	input	wire			sys_clk,
	input	wire			sys_rst,

	input	wire			axi_arvalid,
	input	wire	[31:0]	axi_araddr,
	output	wire			axi_arready,

	input	wire			axi_rready,
	output	reg		[31:0]	axi_rdata,
	output	reg		[2:0]	axi_rresp,
	output	reg				axi_rvalid,

	input	wire			axi_awvalid,
	input	wire	[31:0]	axi_awaddr,
	output	reg				axi_awready,

	input	wire	[31:0]	axi_wdata,
	input	wire	[3:0]	axi_wstrb,
	input	wire			axi_wvalid,
	output	reg				axi_wready,

	input	wire			axi_bready,
	output	reg		[2:0]	axi_bresp,
	output	reg				axi_bvalid
);

parameter	IDLE				= 2'b01,
			WAIT_BREADY			= 2'b10;

reg		[1:0]	state;

reg				waddr_received;
reg				wdata_received;
reg		[31:0]	waddr_reg;
reg		[31:0]	wdata_reg;
reg		[3:0]	wstrb_reg;

//can not read
assign axi_arready 	= 1'b0;
assign axi_rdata 	= 32'b0;
assign axi_rresp	= 3'b0;
assign axi_rvalid	= 1'b0;

assign axi_awready = ~waddr_received;
assign axi_wready  = ~wdata_received;

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		state <= IDLE;
	end else begin
		case(state)
			IDLE:
				if(waddr_received && wdata_received) begin
					state <= WAIT_BREADY;
				end
			WAIT_BREADY:
				if(axi_bready) begin
					state <= IDLE;
				end
			default: state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		waddr_received <= 1'b0;
	end else if(state == WAIT_BREADY && axi_bready) begin
		waddr_received <= 1'b0;
	end else if(state == IDLE && axi_awvalid) begin
		waddr_received <= 1'b1;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		wdata_received <= 1'b0;
	end else if(state == WAIT_BREADY && axi_bready) begin
		wdata_received <= 1'b0;
	end else if(state == IDLE && axi_wvalid) begin
		wdata_received <= 1'b1;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		waddr_reg <= 32'b0;
	end else if(state == IDLE && axi_awvalid) begin
		waddr_reg <= axi_awaddr;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		wdata_reg <= 32'b0;
		wstrb_reg <= 4'b0;
	end else if(state == IDLE && axi_wvalid) begin
		wdata_reg <= axi_wdata;
		wstrb_reg <= axi_wstrb;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(state == IDLE && waddr_received && wdata_received) begin
		//while waddr and wdata is received, display characters accoding to wdata
		$write("%c", wdata_reg[7:0]);
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_bresp <= 3'b0;
		axi_bvalid <= 1'b0;
	end else if(state == WAIT_BREADY && axi_bready) begin
		axi_bresp <= 3'b0;
		axi_bvalid <= 1'b1;
	end else begin
		axi_bresp <= 3'b0;
		axi_bvalid <= 1'b0;
	end
end

endmodule

