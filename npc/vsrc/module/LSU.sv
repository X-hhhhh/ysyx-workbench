module LSU
(
	input	wire				sys_clk,
	input	wire				sys_rst,
	input	wire	[31:0]		raddr,
	input	wire	[31:0]		waddr,
	input	wire	[31:0]		wdata,
	input	wire	[3:0]		wmask,
	input	wire				valid,
	input	wire				wen,
	input	wire	[1:0]		rbyte_num,
	input	wire				exu_valid,
	input	wire				wbu_ready,

	output	reg		[31:0]		rdata,
	//signals between cpu modules
	output	reg					lsu_valid,
	output	reg					lsu_ready,
	//AXI4-Lite interface
	input	wire				axi_arready,
	output	wire				axi_arvalid,
	output	reg		[31:0]		axi_araddr,
	output	wire	[3:0]		axi_arid,
	output	wire	[7:0]		axi_arlen,
	output	wire	[2:0]		axi_arsize,
	output	wire	[1:0]		axi_arburst,

	input	wire	[31:0]		axi_rdata,
	input	wire	[1:0]		axi_rresp,
	input	wire				axi_rvalid,
	input	wire	[3:0]		axi_rid,
	input	wire				axi_rlast,
	output	wire				axi_rready,

	input	wire				axi_awready,
	output	reg					axi_awvalid,
	output	reg		[31:0]		axi_awaddr,
	output	wire	[3:0]		axi_awid,
	output	wire	[7:0]		axi_awlen,
	output	wire	[2:0]		axi_awsize,
	output	wire	[1:0]		axi_awburst,

	input	wire				axi_wready,
	output	reg		[31:0]		axi_wdata,
	output	reg		[3:0]		axi_wstrb,
	output	reg					axi_wvalid,
	output	reg					axi_wlast,

	input	wire	[1:0]		axi_bresp,
	input	wire				axi_bvalid,
	input	wire	[3:0]		axi_bid,
	output	wire				axi_bready
);

parameter 	IDLE 			= 5'b00001,
			WAIT_ARREADY	= 5'b00010,
			WAIT_RRESP		= 5'b00100,
			WAIT_AW_WREADY 	= 5'b01000,
			WAIT_BRESP		= 5'b10000;

reg	[4:0]	lsu_state;
reg	[31:0]	pmem_read_data0;
reg	[31:0]	pmem_read_data1;

reg			rw_across;			//this means to read or write memory 2 times(across words)

reg			waddr_sended;
reg			wdata_sended;

assign axi_arid		= 4'b0;
assign axi_arlen	= 8'b0;			//1 transfer per transaction
assign axi_arsize	= 3'b010;       //4 bytes per transfer
assign axi_arburst 	= 2'b0;         //fixed burst

assign axi_awid 	= 4'b0;
assign axi_awlen 	= 8'b0;			//1 transfer per transaction
assign axi_awsize 	= 3'b010;		//4 bytes per transfer
assign axi_awburst	= 2'b0;			//fixed burst

assign lsu_ready = (lsu_state == IDLE);

assign axi_rready = (lsu_state == WAIT_RRESP);
assign axi_bready = (lsu_state == WAIT_BRESP);

//if wen and valid is invalid, skip
always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		lsu_valid <= 1'b0;
	end else if((lsu_state == WAIT_RRESP && axi_rvalid && axi_rresp == 2'b00 || 
				lsu_state == WAIT_BRESP && axi_bvalid && axi_bresp == 2'b00) && wbu_ready && !rw_across) begin
		lsu_valid <= 1'b1;
	end else if(lsu_state == IDLE && exu_valid && !wen && !valid && wbu_ready) begin
		//this situation don't need to access memory
		lsu_valid <= 1'b1;
	end else begin
		lsu_valid <= 1'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		waddr_sended <= 1'b0;
	end else if(lsu_state == WAIT_AW_WREADY && axi_awvalid && axi_awready && wen) begin
		waddr_sended <= 1'b1;
	end else if(axi_rvalid && rw_across) begin
		waddr_sended <= 1'b1;
	end else if(lsu_state == WAIT_AW_WREADY && waddr_sended && wdata_sended) begin
		waddr_sended <= 1'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		wdata_sended <= 1'b0;
	end else if(lsu_state == WAIT_AW_WREADY && axi_wvalid && axi_wready && wen) begin
		wdata_sended <= 1'b1;
	end else if(axi_rvalid && rw_across) begin
		wdata_sended <= 1'b1;
	end else if(lsu_state == WAIT_AW_WREADY && waddr_sended && wdata_sended) begin
		wdata_sended <= 1'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		rw_across <= 1'b0;
	end else begin
		case(lsu_state)
			IDLE:
				if(exu_valid) begin
					//below 2 situations need to access memory 2 times
					if(rbyte_num == 2'b01 && raddr[1:0] == 2'b11 || wmask == 4'b1001) begin
						rw_across <= 1'b1;
					end
				end
			WAIT_RRESP:
				if(axi_rvalid && axi_rresp == 2'b00) begin
					rw_across <= 1'b0;
				end
			WAIT_BRESP:
				if(axi_bvalid && axi_bresp == 2'b00) begin
					rw_across <= 1'b0;
				end
			default: rw_across <= rw_across;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		lsu_state <= IDLE;
	end else begin
		case(lsu_state)
			IDLE: 
				if(exu_valid) begin
					if(wen) begin
						lsu_state <= WAIT_AW_WREADY;
					end else if(valid) begin
						lsu_state <= WAIT_ARREADY;
					end
				end
			WAIT_ARREADY:
				if(axi_arready) begin
					lsu_state <= WAIT_RRESP;
				end
			WAIT_RRESP:
				//while rdata is valid(when rresp is 0x00)
				if(axi_rvalid && axi_rresp == 2'b00) begin
					if(rw_across) begin
						// read the second time, switch to WAIT_ARREADY and wait
						// for arready signal
						lsu_state <= WAIT_ARREADY;
					end else if(wbu_ready) begin
						lsu_state <= IDLE;
					end
				end
				//else ... can add some error handling
			WAIT_AW_WREADY:
			//	if(waddr_sended && wdata_sended) begin
			//		lsu_state <= WAIT_BRESP;
			//	end
				if(axi_awready && axi_awvalid && axi_wready && axi_wvalid || 
					axi_awready && axi_awvalid && wdata_sended ||
					axi_wready && axi_wvalid && waddr_sended) begin
					lsu_state <= WAIT_BRESP;
				end
			WAIT_BRESP:
				//while data is wrote(when bresp is 0x00)
				if(axi_bvalid && axi_bresp == 2'b00) begin
					if(rw_across) begin
						// read the second time, switch to WAIT_ARREADY and wait
						// for arready signal
						lsu_state <= WAIT_AW_WREADY;
					end else if(wbu_ready) begin
						lsu_state <= IDLE;
					end
				end
				//else ... can add some error handling
			default: lsu_state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		pmem_read_data0 <= 32'b0;
		pmem_read_data1 <= 32'b0;
	end	else if(lsu_state == WAIT_RRESP && axi_rvalid && axi_rresp == 2'b00) begin
		if(!rw_across) begin
			pmem_read_data0 <= axi_rdata;
		end else begin
			pmem_read_data1 <= axi_rdata;
		end
	end
end

always@(*) begin
	if(valid == 1'b1) begin 	//if valid is 1, output the read data
		case(rbyte_num)			//00: 1byte, 01: 2bytes, 10: 4bytes, 11: 8bytes
			2'b00: rdata = (pmem_read_data0 >> ((raddr & 32'h3) << 3)) & 32'hFF;
			2'b01: 
				if(raddr[1:0] == 2'b11) begin
					//Need to read across bytes
					rdata = {16'b0, pmem_read_data0[7:0], pmem_read_data1[31:24]};
				end else begin
					rdata = (pmem_read_data0 >> ((raddr & 32'h3) << 3)) & 32'hFFFF;
				end
			2'b10: rdata = pmem_read_data0;
			default: rdata = 32'b0;
		endcase
	end else begin
		rdata = 32'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_araddr <= 32'b0;
		axi_arvalid <= 1'b0;
	end else if(lsu_state == IDLE && exu_valid && valid) begin
		axi_araddr <= raddr;
		axi_arvalid <= 1'b1;
	end else if(axi_rvalid && rw_across) begin	//set arvalid to read the second time(across word)
		axi_araddr <= raddr + 4;
		axi_arvalid <= 1'b1;
	end else if(lsu_state == WAIT_ARREADY && axi_arready) begin
		axi_araddr <= 32'b0;
		axi_arvalid <= 1'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_awaddr <= 32'b0;
		axi_awvalid <= 1'b0;
	end else if(lsu_state == IDLE && exu_valid && wen) begin
		axi_awaddr <= waddr;
		axi_awvalid <= 1'b1;
	end else if(axi_bvalid && rw_across) begin
		axi_awaddr <= waddr + 4;
		axi_awvalid <= 1'b1;
	end else if(lsu_state == WAIT_AW_WREADY && axi_awready) begin
		axi_awaddr <= 32'b0;
		axi_awvalid <= 1'b0;
	end
end
		
always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		axi_wdata 	<= 32'b0;
		axi_wstrb	<= 4'b0;
		axi_wvalid	<= 1'b0;
		axi_wlast	<= 1'b0;
	end else if(lsu_state == IDLE && exu_valid && wen) begin
		axi_wdata	<= wdata;
		axi_wstrb	<= (wmask == 4'b1001) ? 4'b1000 : wmask;
		axi_wvalid 	<= 1'b1;
		axi_wlast 	<= 1'b1;
	end else if(axi_bvalid && rw_across) begin
		axi_wdata	<= wdata;
		axi_wstrb	<= 4'b0001;
		axi_wvalid 	<= 1'b1;
		axi_wlast	<= 1'b1;
	end else if(lsu_state == WAIT_AW_WREADY && axi_wready) begin
		axi_wdata	<= 32'b0;
		axi_wstrb	<= 4'b0;
		axi_wvalid 	<= 1'b0;
		axi_wlast	<= 1'b0;
	end
end

endmodule

