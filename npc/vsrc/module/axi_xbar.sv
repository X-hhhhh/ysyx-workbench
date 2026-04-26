module axi_xbar(
	input	wire			sys_clk,
	input	wire			sys_rst,
	//ifu
	input	wire			ifu_axi_arvalid,
	input	wire	[31:0]	ifu_axi_araddr,
	input	wire	[3:0]	ifu_axi_arid,
	input	wire	[7:0]	ifu_axi_arlen,
	input	wire	[2:0]	ifu_axi_arsize,
	input	wire	[1:0]	ifu_axi_arburst,
	output	reg				ifu_axi_arready,

	input	wire			ifu_axi_rready,
	output	reg		[31:0]	ifu_axi_rdata,
	output	reg		[1:0]	ifu_axi_rresp,
	output	reg				ifu_axi_rvalid,
	output	reg		[3:0]	ifu_axi_rid,
	output	reg				ifu_axi_rlast,

	input	wire			ifu_axi_awvalid,
	input	wire	[31:0]	ifu_axi_awaddr,
	input	wire	[3:0]	ifu_axi_awid,
	input	wire	[7:0]	ifu_axi_awlen,
	input	wire	[2:0]	ifu_axi_awsize,
	input	wire	[1:0]	ifu_axi_awburst,
	output	reg				ifu_axi_awready,

	input	wire	[31:0]	ifu_axi_wdata,
	input	wire	[3:0]	ifu_axi_wstrb,
	input	wire			ifu_axi_wvalid,
	input	wire			ifu_axi_wlast,
	output	reg				ifu_axi_wready,

	input	wire			ifu_axi_bready,
	output	reg		[1:0]	ifu_axi_bresp,
	output	reg				ifu_axi_bvalid,
	output	reg		[3:0]	ifu_axi_bid,
	//lsu
	input	wire			lsu_axi_arvalid,
	input	wire	[31:0]	lsu_axi_araddr,
	input	wire	[3:0]	lsu_axi_arid,
	input	wire	[7:0]	lsu_axi_arlen,
	input	wire	[2:0]	lsu_axi_arsize,
	input	wire	[1:0]	lsu_axi_arburst,
	output	reg				lsu_axi_arready,

	input	wire			lsu_axi_rready,
	output	reg		[31:0]	lsu_axi_rdata,
	output	reg		[1:0]	lsu_axi_rresp,
	output	reg				lsu_axi_rvalid,
	output	reg		[3:0]	lsu_axi_rid,
	output	reg				lsu_axi_rlast,

	input	wire			lsu_axi_awvalid,
	input	wire	[31:0]	lsu_axi_awaddr,
	input	wire	[3:0]	lsu_axi_awid,
	input	wire	[7:0]	lsu_axi_awlen,
	input	wire	[2:0]	lsu_axi_awsize,
	input	wire	[1:0]	lsu_axi_awburst,
	output	reg				lsu_axi_awready,

	input	wire	[31:0]	lsu_axi_wdata,
	input	wire	[3:0]	lsu_axi_wstrb,
	input	wire			lsu_axi_wvalid,
	input	wire			lsu_axi_wlast,
	output	reg				lsu_axi_wready,

	input	wire			lsu_axi_bready,
	output	reg		[1:0]	lsu_axi_bresp,
	output	reg				lsu_axi_bvalid,
	output	reg		[3:0]	lsu_axi_bid,
	//sram
	input	wire			mem_axi_arready,
	output	wire			mem_axi_arvalid,
	output	reg		[31:0]	mem_axi_araddr,
	output	wire	[3:0]	mem_axi_arid,
	output	wire	[7:0]	mem_axi_arlen,
	output	wire	[2:0]	mem_axi_arsize,
	output	wire	[1:0]	mem_axi_arburst,

	input	wire	[31:0]	mem_axi_rdata,
	input	wire	[1:0]	mem_axi_rresp,
	input	wire			mem_axi_rvalid,
	input	wire	[3:0]	mem_axi_rid,
	input	wire			mem_axi_rlast,
	output	wire			mem_axi_rready,

	input	wire			mem_axi_awready,
	output	reg				mem_axi_awvalid,
	output	reg		[31:0]	mem_axi_awaddr,
	output	wire	[3:0]	mem_axi_awid,
	output	wire	[7:0]	mem_axi_awlen,
	output	wire	[2:0]	mem_axi_awsize,
	output	wire	[1:0]	mem_axi_awburst,

	input	wire			mem_axi_wready,
	output	reg		[31:0]	mem_axi_wdata,
	output	reg		[3:0]	mem_axi_wstrb,
	output	reg				mem_axi_wvalid,
	output	wire			mem_axi_wlast,

	input	wire	[1:0]	mem_axi_bresp,
	input	wire			mem_axi_bvalid,
	input	wire	[3:0]	mem_axi_bid,
	output	wire			mem_axi_bready,
	//clint
	input	wire			clint_axi_arready,
	output	reg				clint_axi_arvalid,
	output	reg		[31:0]	clint_axi_araddr,

	input	wire	[31:0]	clint_axi_rdata,
	input	wire	[1:0]	clint_axi_rresp,
	input	wire			clint_axi_rvalid,
	output	reg				clint_axi_rready,

	input	wire			clint_axi_awready,
	output	reg				clint_axi_awvalid,
	output	reg		[31:0]	clint_axi_awaddr,

	input	wire			clint_axi_wready,
	output	reg		[31:0]	clint_axi_wdata,
	output	reg		[3:0]	clint_axi_wstrb,
	output	reg				clint_axi_wvalid,

	input	wire	[1:0]	clint_axi_bresp,
	input	wire			clint_axi_bvalid,
	output	reg				clint_axi_bready
);

//also define in macro.c
parameter	//SRAM_ADDR	= 32'h80000000,
			//SRAM_SIZE	= 32'h8000000,
			CLINT_ADDR	= 32'h02000000,
			CLINT_SIZE	= 32'h10000;

parameter	IFU_ACC_MEM 	= 4'b0001,
			LSU_ACC_MEM 	= 4'b0010,
			LSU_ACC_CLINT	= 4'b0100,
			ADDR_ERROR		= 4'b1000;	

reg		[3:0]	state;

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		state <= IFU_ACC_MEM;
	end else if(lsu_axi_arvalid || lsu_axi_awvalid || lsu_axi_wvalid) begin
		//if((lsu_axi_araddr >= SRAM_ADDR) && (lsu_axi_araddr < SRAM_ADDR + SRAM_SIZE) ||
		//		(lsu_axi_awaddr >= SRAM_ADDR) && (lsu_axi_awaddr < SRAM_ADDR + SRAM_SIZE)) begin
		if((lsu_axi_araddr >= CLINT_ADDR) && (lsu_axi_araddr < CLINT_ADDR + CLINT_SIZE) ||
			(lsu_axi_awaddr >= CLINT_ADDR) && (lsu_axi_awaddr < CLINT_ADDR + CLINT_SIZE)) begin
			state <= LSU_ACC_CLINT;
		end else begin
			state <= LSU_ACC_MEM;
		end 
	end else if(ifu_axi_arvalid || ifu_axi_awvalid || ifu_axi_wvalid) begin
		if( !((lsu_axi_araddr >= CLINT_ADDR) && (lsu_axi_araddr < CLINT_ADDR + CLINT_SIZE) ||
			(lsu_axi_awaddr >= CLINT_ADDR) && (lsu_axi_awaddr < CLINT_ADDR + CLINT_SIZE)) ) begin
			//ifu can only access mem, not clint
			state <= IFU_ACC_MEM;
		end else begin
			state <= ADDR_ERROR;
		end
	end
end

always@(*) begin
	if(state == LSU_ACC_CLINT) begin
        clint_axi_arvalid 	= lsu_axi_arvalid;
        clint_axi_araddr	= lsu_axi_araddr;
                   
        clint_axi_rready	= lsu_axi_rready;
                   
       	clint_axi_awvalid	= lsu_axi_awvalid;
        clint_axi_awaddr	= lsu_axi_awaddr;
           
        clint_axi_wdata		= lsu_axi_wdata;
        clint_axi_wstrb		= lsu_axi_wstrb;
        clint_axi_wvalid	= lsu_axi_wvalid;

        clint_axi_bready	= lsu_axi_bready;
	end else begin
        clint_axi_arvalid 	= 1'b0;
        clint_axi_araddr	= 32'b0;
                   
        clint_axi_rready	= 1'b0;
                   
       	clint_axi_awvalid	= 1'b0;
        clint_axi_awaddr	= 32'b0;
           
        clint_axi_wdata		= 32'b0;
        clint_axi_wstrb		= 4'b0;
        clint_axi_wvalid	= 1'b0;

        clint_axi_bready	= 1'b0;
	end
end

always@(*) begin
	if(state == IFU_ACC_MEM) begin
        mem_axi_arvalid = ifu_axi_arvalid;
        mem_axi_araddr	= ifu_axi_araddr;
		mem_axi_arid	= ifu_axi_arid;
		mem_axi_arlen 	= ifu_axi_arlen;
		mem_axi_arsize	= ifu_axi_arsize;
		mem_axi_arburst = ifu_axi_arburst;
                       
        mem_axi_rready	= ifu_axi_rready;
                       
        mem_axi_awvalid	= ifu_axi_awvalid;
        mem_axi_awaddr	= ifu_axi_awaddr;
		mem_axi_awid	= ifu_axi_awid;
		mem_axi_awlen	= ifu_axi_awlen;
		mem_axi_awsize  = ifu_axi_awsize;
		mem_axi_awburst = ifu_axi_awburst;
               
        mem_axi_wdata	= ifu_axi_wdata;
        mem_axi_wstrb	= ifu_axi_wstrb;
        mem_axi_wvalid	= ifu_axi_wvalid;
		mem_axi_wlast 	= ifu_axi_wlast;

        mem_axi_bready	= ifu_axi_bready;
	end else if(state == LSU_ACC_MEM) begin
        mem_axi_arvalid = lsu_axi_arvalid;
        mem_axi_araddr	= lsu_axi_araddr;
		mem_axi_arid	= lsu_axi_arid;
		mem_axi_arlen 	= lsu_axi_arlen;
		mem_axi_arsize	= lsu_axi_arsize;
		mem_axi_arburst = lsu_axi_arburst;
                       
        mem_axi_rready	= lsu_axi_rready;
                       
        mem_axi_awvalid	= lsu_axi_awvalid;
        mem_axi_awaddr	= lsu_axi_awaddr;
		mem_axi_awid	= lsu_axi_awid;
		mem_axi_awlen	= lsu_axi_awlen;
		mem_axi_awsize  = lsu_axi_awsize;
		mem_axi_awburst = lsu_axi_awburst;
               
        mem_axi_wdata	= lsu_axi_wdata;
        mem_axi_wstrb	= lsu_axi_wstrb;
        mem_axi_wvalid	= lsu_axi_wvalid;
		mem_axi_wlast 	= lsu_axi_wlast;

        mem_axi_bready	= lsu_axi_bready;
	end else begin
        mem_axi_arvalid = 1'b0; 
        mem_axi_araddr	= 32'b0;
		mem_axi_arid	= 4'b0;
		mem_axi_arlen 	= 8'b0;
		mem_axi_arsize	= 3'b0;
		mem_axi_arburst = 2'b0;
        mem_axi_rready	= 1'b0;
        mem_axi_awvalid	= 1'b0;
        mem_axi_awaddr	= 32'b0;
		mem_axi_awid	= 4'b0;
		mem_axi_awlen	= 8'b0;
		mem_axi_awsize  = 3'b0;
		mem_axi_awburst = 2'b0;
        mem_axi_wdata	= 32'b0;
        mem_axi_wstrb	= 4'b0;
        mem_axi_wvalid	= 1'b0;
		mem_axi_wlast 	= 1'b0;
        mem_axi_bready	= 1'b0;
	end
end

always@(*) begin
	if(state == IFU_ACC_MEM) begin					//ifu accesses sram
		ifu_axi_arready	= mem_axi_arready;

        ifu_axi_rdata	= mem_axi_rdata;
        ifu_axi_rresp	= mem_axi_rresp;	
        ifu_axi_rvalid	= mem_axi_rvalid;
		ifu_axi_rid		= mem_axi_rid;
		ifu_axi_rlast	= mem_axi_rlast;
                       
        ifu_axi_awready	= mem_axi_awready;
               
        ifu_axi_wready	= mem_axi_wready;

        ifu_axi_bresp	= mem_axi_bresp;
        ifu_axi_bvalid	= mem_axi_bvalid;
		ifu_axi_bid 	= mem_axi_bid;
	end else if(state == ADDR_ERROR) begin
		ifu_axi_arready	= 1'b0;

        ifu_axi_rdata	= 32'b0;
        ifu_axi_rresp	= 2'b11;		//DECERR
        ifu_axi_rvalid	= 1'b0;
		ifu_axi_rid		= 4'b0;
		ifu_axi_rlast	= 1'b0;
                       
        ifu_axi_awready	= 1'b0;
               
        ifu_axi_wready	= 1'b0;

        ifu_axi_bresp	= 2'b0;
        ifu_axi_bvalid	= 1'b0;
		ifu_axi_bid		= 4'b0;
	end else begin
		ifu_axi_arready	= 1'b0;

        ifu_axi_rdata	= 32'b0;
        ifu_axi_rresp	= 2'b0;
        ifu_axi_rvalid	= 1'b0;
		ifu_axi_rid		= 4'b0;
		ifu_axi_rlast	= 1'b0;
                       
        ifu_axi_awready	= 1'b0;
               
        ifu_axi_wready	= 1'b0;

        ifu_axi_bresp	= 2'b0;
        ifu_axi_bvalid	= 1'b0;
		ifu_axi_bid		= 4'b0;
	end
end

always@(*) begin
	if(state == LSU_ACC_MEM) begin					//lsu accesses sram
		lsu_axi_arready	= mem_axi_arready;
                       
        lsu_axi_rdata	= mem_axi_rdata;
        lsu_axi_rresp	= mem_axi_rresp;	
        lsu_axi_rvalid	= mem_axi_rvalid;
		lsu_axi_rid		= mem_axi_rid;
		lsu_axi_rlast	= mem_axi_rlast;
                       
        lsu_axi_awready	= mem_axi_awready;
               
        lsu_axi_wready	= mem_axi_wready;

        lsu_axi_bresp	= mem_axi_bresp;
        lsu_axi_bvalid	= mem_axi_bvalid;
		lsu_axi_bid		= mem_axi_bid;
	end else if(state == LSU_ACC_CLINT) begin		//lsu accesses clint
		lsu_axi_arready	= clint_axi_arready;
                       
        lsu_axi_rdata	= clint_axi_rdata;
        lsu_axi_rresp	= clint_axi_rresp;	
        lsu_axi_rvalid	= clint_axi_rvalid;
		lsu_axi_rid		= 4'b0;
		lsu_axi_rlast	= 1'b0;
                       
        lsu_axi_awready	= clint_axi_awready;
               
        lsu_axi_wready	= clint_axi_wready;

        lsu_axi_bresp	= clint_axi_bresp;
        lsu_axi_bvalid	= clint_axi_bvalid;
		lsu_axi_bid		= 4'b0;
	end else begin
		lsu_axi_arready = 1'b0;
        lsu_axi_rdata	= 32'b0;
        lsu_axi_rresp	= 2'b0;
		lsu_axi_rvalid  = 1'b0;	
		lsu_axi_rid		= 4'b0;
		lsu_axi_rlast	= 1'b0;
        lsu_axi_awready	= 1'b0;
        lsu_axi_wready	= 1'b0;
        lsu_axi_bresp	= 2'b0;
        lsu_axi_bvalid	= 1'b0;
		lsu_axi_bid		= 4'b0;
	end
end

endmodule

