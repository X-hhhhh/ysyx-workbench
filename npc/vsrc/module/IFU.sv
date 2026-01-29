module IFU(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input 	wire	[31:0]	pc,
	input	wire			idu_ready,
	input	wire			wbu_inst_end,

	output	reg				ifu_valid,
	output	reg		[31:0]	inst,
	//AXI4-Lite interface
	input	wire			axi_arready,
	output	wire			axi_arvalid,
	output	reg		[31:0]	axi_araddr,

	input	wire	[31:0]	axi_rdata,
	input	wire	[2:0]	axi_rresp,
	input	wire			axi_rvalid,
	output	reg				axi_rready,

	input	wire			axi_awready,
	output	wire			axi_awvalid,
	output	wire	[31:0]	axi_awaddr,

	input	wire			axi_wready,
	output	wire	[31:0]	axi_wdata,
	output	wire	[3:0]	axi_wstrb,
	output	wire			axi_wvalid,

	input	wire	[2:0]	axi_bresp,
	input	wire			axi_bvalid,
	output	wire			axi_bready
);

parameter 	IDLE			= 3'b001,		//set raddr status
			WAIT_ARREADY	= 3'b010,		//wait for arready
			WAIT_RRESP		= 3'b100;		//wait until rresp is valid and idu is ready

export "DPI-C" function dpi_inst_get;
export "DPI-C" function dpi_ifu_state_get;

function int dpi_inst_get();
	return inst;
endfunction

function int dpi_ifu_state_get();
	return {29'b0, ifu_state};
endfunction

reg		[2:0]	ifu_state;
reg				startup;
reg				startup_reg;
wire			startup_rise;

assign startup_rise = startup && ~startup_reg;
assign axi_rready = (ifu_state == WAIT_RRESP);

//no need to write
assign	axi_awvalid	= 1'b0;
assign	axi_awaddr	= 32'b0;
assign	axi_wdata	= 32'b0;
assign	axi_wstrb	= 4'b0;
assign	axi_wvalid	= 1'b0;
assign	axi_bready	= 1'b0;

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		startup <= 1'b0;
		startup_reg <= 1'b0;
	end else begin
		startup <= 1'b1;
		startup_reg <= startup;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		ifu_state <= IDLE;
	end else begin
		case(ifu_state)
			IDLE:
				if(wbu_inst_end || startup_rise) begin
					ifu_state <= WAIT_ARREADY;
				end
			WAIT_ARREADY:
				if(axi_arready) begin
					ifu_state <= WAIT_RRESP;
				end
			WAIT_RRESP: 
				if(idu_ready && axi_rvalid && axi_rresp == 3'b000) begin
					ifu_state <= IDLE;
				end
			default: ifu_state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_araddr <= 32'b0;
		axi_arvalid <= 1'b0;
	end else if(ifu_state == IDLE && (wbu_inst_end || startup_rise)) begin
		axi_araddr <= pc;
		axi_arvalid <= 1'b1;
	end else if(ifu_state == WAIT_ARREADY && axi_arready) begin
		//while rready is valid, rom has received data, set data invalid
		axi_araddr <= 32'b0;
		axi_arvalid <= 1'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		inst <= 32'h80000000;
	end	else if(ifu_state == WAIT_RRESP && axi_rvalid && axi_rresp == 3'b000) begin
		inst <= axi_rdata;
	end 
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		ifu_valid <= 1'b0;
	end else if(ifu_state == WAIT_RRESP && axi_rvalid && axi_rresp == 3'b000 && idu_ready) begin
		ifu_valid <= 1'b1;
	end else begin
		ifu_valid <= 1'b0;
	end
end

endmodule

