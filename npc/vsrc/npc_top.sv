module npc_top
(
	input	wire			clock,
	input	wire			reset,
	input	wire			io_interrupt,

	input  	wire	  		io_master_awready,
	output 	wire	        io_master_awvalid,
	output 	wire	[31:0]  io_master_awaddr,
	output 	wire	[3:0]   io_master_awid,
	output 	wire	[7:0]  	io_master_awlen,
	output 	wire	[2:0]   io_master_awsize,
	output 	wire	[1:0]   io_master_awburst,
	input  	wire	        io_master_wready,
	output 	wire	        io_master_wvalid,
	output 	wire	[31:0]  io_master_wdata,
	output 	wire	[3:0]   io_master_wstrb,
	output 	wire	        io_master_wlast,
	output 	wire	        io_master_bready,
	input  	wire	        io_master_bvalid,
	input  	wire	[1:0]   io_master_bresp,
	input  	wire	[3:0]   io_master_bid,
	input  	wire	        io_master_arready,
	output 	wire	        io_master_arvalid,
	output 	wire	[31:0]  io_master_araddr,
	output 	wire	[3:0]   io_master_arid,
	output 	wire	[7:0]   io_master_arlen,
	output 	wire	[2:0]   io_master_arsize,
	output 	wire	[1:0]   io_master_arburst,
	output 	wire	        io_master_rready,
	input  	wire	        io_master_rvalid,
	input  	wire	[1:0]   io_master_rresp,
	input  	wire	[31:0]  io_master_rdata,
	input  	wire	        io_master_rlast,
	input  	wire	[3:0]   io_master_rid,

	output  wire	  		io_slave_awready,
	input 	wire	        io_slave_awvalid,
	input 	wire	[31:0]  io_slave_awaddr,
	input 	wire	[3:0]   io_slave_awid,
	input 	wire	[7:0]  	io_slave_awlen,
	input 	wire	[2:0]   io_slave_awsize,
	input 	wire	[1:0]   io_slave_awburst,
	output 	wire	        io_slave_wready,
	input 	wire	        io_slave_wvalid,
	input 	wire	[31:0]  io_slave_wdata,
	input 	wire	[3:0]   io_slave_wstrb,
	input 	wire	        io_slave_wlast,
	input 	wire	        io_slave_bready,
	output  wire	        io_slave_bvalid,
	output  wire	[1:0]   io_slave_bresp,
	output  wire	[3:0]   io_slave_bid,
	output  wire	        io_slave_arready,
	input 	wire	        io_slave_arvalid,
	input 	wire	[31:0]  io_slave_araddr,
	input 	wire	[3:0]   io_slave_arid,
	input 	wire	[7:0]   io_slave_arlen,
	input 	wire	[2:0]   io_slave_arsize,
	input 	wire	[1:0]   io_slave_arburst,
	input 	wire	        io_slave_rready,
	output  wire	        io_slave_rvalid,
	output  wire	[1:0]   io_slave_rresp,
	output  wire	[31:0]  io_slave_rdata,
	output  wire	        io_slave_rlast,
	output  wire	[3:0]   io_slave_rid
);

/* verilator lint_off UNOPTFLAT */
wire	[4:0]		gpr_raddr1;
wire	[4:0]		gpr_raddr2;
/* verilator lint_on UNOPTFLAT */

wire	[31:0]		inst_in;
wire				pc_add_en;

wire				gpr_wen;
wire	[4:0]		gpr_waddr;
wire	[31:0]		imm;
wire	[31:0]		gpr_wdata;
wire	[31:0]		gpr_rdata1_in;
wire	[31:0]		gpr_rdata2_in;
wire	[31:0]		gpr_rdata1;
wire	[31:0]		gpr_rdata2;
wire				pc_wen;
wire	[31:0]		pc_wdata;
wire	[11:0]		csr_raddr;
wire	[11:0]		csr_waddr1;
wire	[31:0]		csr_wdata1;
wire				csr_wen1;
wire	[11:0]		csr_waddr2;
wire	[31:0]		csr_wdata2;
wire				csr_wen2;
wire	[31:0]		csr_rdata_in;

wire	[31:0]		EXU_data;
wire	[12:0]		EXU_mode;

wire	[31:0]		mem_rdata;
wire				mem_valid;
wire				mem_wen;
wire	[31:0]		mem_raddr;
wire	[31:0]		mem_waddr;
wire	[31:0]		mem_wdata;
wire	[3:0]		mem_wmask;
wire	[1:0]		mem_rbyte_num;

wire				ifu_valid;
wire	[31:0]		ifu_raddr;
wire				ifu_axi_arvalid;
wire	[31:0]		ifu_axi_araddr;
wire				ifu_axi_arready;
wire	[3:0]		ifu_axi_arid;
wire	[7:0]		ifu_axi_arlen;
wire	[2:0]		ifu_axi_arsize;
wire	[1:0]		ifu_axi_arburst;
wire				ifu_axi_rready;
wire	[31:0]		ifu_axi_rdata;
wire	[1:0]		ifu_axi_rresp;
wire				ifu_axi_rvalid;
wire	[3:0]		ifu_axi_rid;
wire				ifu_axi_rlast;
wire				ifu_axi_awvalid;
wire	[31:0]		ifu_axi_awaddr;
wire				ifu_axi_awready;
wire	[3:0]		ifu_axi_awid;
wire	[7:0]		ifu_axi_awlen;
wire	[2:0]		ifu_axi_awsize;
wire	[1:0]		ifu_axi_awburst;
wire	[31:0]		ifu_axi_wdata;
wire	[3:0]		ifu_axi_wstrb;
wire				ifu_axi_wvalid;
wire				ifu_axi_wlast;
wire				ifu_axi_wready;
wire				ifu_axi_bready;
wire	[1:0]		ifu_axi_bresp;
wire				ifu_axi_bvalid;
wire	[3:0]		ifu_axi_bid;

wire				idu_ready;
wire				idu_valid;
wire				exu_valid;
wire				exu_ready;

wire				lsu_valid;
wire				lsu_ready;
wire				lsu_axi_arvalid;
wire	[31:0]		lsu_axi_araddr;
wire				lsu_axi_arready;
wire	[3:0]		lsu_axi_arid;
wire	[7:0]		lsu_axi_arlen;
wire	[2:0]		lsu_axi_arsize;
wire	[1:0]		lsu_axi_arburst;
wire				lsu_axi_rready;
wire	[31:0]		lsu_axi_rdata;
wire	[1:0]		lsu_axi_rresp;
wire				lsu_axi_rvalid;
wire	[3:0]		lsu_axi_rid;
wire				lsu_axi_rlast;
wire				lsu_axi_awvalid;
wire	[31:0]		lsu_axi_awaddr;
wire				lsu_axi_awready;
wire	[3:0]		lsu_axi_awid;
wire	[7:0]		lsu_axi_awlen;
wire	[2:0]		lsu_axi_awsize;
wire	[1:0]		lsu_axi_awburst;
wire	[31:0]		lsu_axi_wdata;
wire	[3:0]		lsu_axi_wstrb;
wire				lsu_axi_wvalid;
wire				lsu_axi_wlast;
wire				lsu_axi_wready;
wire				lsu_axi_bready;
wire	[1:0]		lsu_axi_bresp;
wire				lsu_axi_bvalid;
wire	[3:0]		lsu_axi_bid;

wire				wbu_ready;
wire				wbu_inst_end;
wire	[31:0]		pc;

wire				mem_axi_arready;
wire				mem_axi_arvalid;
wire	[31:0]		mem_axi_araddr;
wire	[3:0]		mem_axi_arid;
wire	[7:0]		mem_axi_arlen;
wire	[2:0]		mem_axi_arsize;
wire	[1:0]		mem_axi_arburst;
wire	[31:0]		mem_axi_rdata;
wire	[1:0]		mem_axi_rresp;
wire				mem_axi_rvalid;
wire				mem_axi_rready;
wire	[3:0]		mem_axi_rid;
wire				mem_axi_rlast;
wire				mem_axi_awready;
wire				mem_axi_awvalid;
wire	[31:0]		mem_axi_awaddr;
wire	[3:0]		mem_axi_awid;
wire	[7:0]		mem_axi_awlen;
wire	[2:0]		mem_axi_awsize;
wire	[1:0]		mem_axi_awburst;
wire				mem_axi_wready;
wire	[31:0]		mem_axi_wdata;
wire	[3:0]		mem_axi_wstrb;
wire				mem_axi_wvalid;
wire				mem_axi_wlast;
wire	[1:0]		mem_axi_bresp;
wire				mem_axi_bvalid;
wire				mem_axi_bready;
wire	[3:0]		mem_axi_bid;

wire				clint_axi_arready;
wire				clint_axi_arvalid;
wire	[31:0]		clint_axi_araddr;
wire	[31:0]		clint_axi_rdata;
wire	[1:0]		clint_axi_rresp;
wire				clint_axi_rvalid;
wire				clint_axi_rready;
wire				clint_axi_awready;
wire				clint_axi_awvalid;
wire	[31:0]		clint_axi_awaddr;
wire				clint_axi_wready;
wire	[31:0]		clint_axi_wdata;
wire	[3:0]		clint_axi_wstrb;
wire				clint_axi_wvalid;
wire	[1:0]		clint_axi_bresp;
wire				clint_axi_bvalid;
wire				clint_axi_bready;

//temporarily not used
assign io_slave_awready = 1'b0;
assign io_slave_wready 	= 1'b0;
assign io_slave_bvalid 	= 1'b0;
assign io_slave_bresp 	= 2'b0;
assign io_slave_bid 	= 4'b0;
assign io_slave_arready = 1'b0;
assign io_slave_rvalid 	= 1'b0;
assign io_slave_rresp	= 2'b0;
assign io_slave_rdata	= 32'b0;
assign io_slave_rlast	= 1'b0;
assign io_slave_rid		= 4'b0;

IFU	IFU_inst
(
	.sys_clk(clock),
	.sys_rst(reset),
	.pc(pc),
	.idu_ready(idu_ready),
	.wbu_inst_end(wbu_inst_end),

	.ifu_valid(ifu_valid),
	.inst(inst_in),

	.axi_arvalid(ifu_axi_arvalid),
	.axi_araddr(ifu_axi_araddr),
	.axi_arready(ifu_axi_arready),
	.axi_arid(ifu_axi_arid),
	.axi_arlen(ifu_axi_arlen),
	.axi_arsize(ifu_axi_arsize),
	.axi_arburst(ifu_axi_arburst),
	.axi_rready(ifu_axi_rready),
	.axi_rdata(ifu_axi_rdata),
	.axi_rresp(ifu_axi_rresp),
	.axi_rvalid(ifu_axi_rvalid),
	.axi_rid(ifu_axi_rid),
	.axi_rlast(ifu_axi_rlast),
	.axi_awvalid(ifu_axi_awvalid),
	.axi_awaddr(ifu_axi_awaddr),
	.axi_awid(ifu_axi_awid),
	.axi_awlen(ifu_axi_awlen),
	.axi_awsize(ifu_axi_awsize),
	.axi_awburst(ifu_axi_awburst),
	.axi_awready(ifu_axi_awready),
	.axi_wdata(ifu_axi_wdata),
	.axi_wstrb(ifu_axi_wstrb),
	.axi_wvalid(ifu_axi_wvalid),
	.axi_wlast(ifu_axi_wlast),
	.axi_wready(ifu_axi_wready),
	.axi_bready(ifu_axi_bready),
	.axi_bresp(ifu_axi_bresp),
	.axi_bvalid(ifu_axi_bvalid),
	.axi_bid(ifu_axi_bid)
);

IDU	IDU_inst
(
	.sys_clk(clock),
	.sys_rst(reset),
	.inst_in(inst_in),
	.gpr_rdata1_in(gpr_rdata1_in),
	.gpr_rdata2_in(gpr_rdata2_in),
	.EXU_data(EXU_data),
	.pc(pc),
	.mem_rdata(mem_rdata),
	.csr_rdata_in(csr_rdata_in),
	.ifu_valid(ifu_valid),
	.exu_ready(exu_ready),

	.gpr_raddr1(gpr_raddr1),
	.gpr_raddr2(gpr_raddr2),
	.gpr_wen(gpr_wen),
	.gpr_waddr(gpr_waddr),
	.gpr_wdata(gpr_wdata),
	.csr_raddr(csr_raddr),
	.csr_waddr1(csr_waddr1),
	.csr_wdata1(csr_wdata1),
	.csr_wen1(csr_wen1),
	.csr_waddr2(csr_waddr2),
	.csr_wdata2(csr_wdata2),
	.csr_wen2(csr_wen2),
	.imm(imm),	
	.pc_wen(pc_wen),
	.pc_wdata(pc_wdata),
	.EXU_mode(EXU_mode),
	.mem_valid(mem_valid),
	.mem_wen(mem_wen),
	.mem_raddr(mem_raddr),
	.mem_waddr(mem_waddr),
	.mem_wdata(mem_wdata),
	.mem_wmask(mem_wmask),
	.mem_rbyte_num(mem_rbyte_num),
	.idu_ready(idu_ready),
	.idu_valid(idu_valid)
);

EXU	EXU_inst
(
	.sys_clk(clock),
	.sys_rst(reset),
	.gpr_rdata1_in(gpr_rdata1_in),
	.gpr_rdata2_in(gpr_rdata2_in),
	.csr_rdata_in(csr_rdata_in),
	.imm(imm),
	.EXU_mode(EXU_mode),
	.idu_valid(idu_valid),
	.lsu_ready(lsu_ready),

	.EXU_data(EXU_data),
	.exu_valid(exu_valid),
	.exu_ready(exu_ready)
);

LSU	LSU_inst
(
	.sys_clk(clock),
	.sys_rst(reset),
	.raddr(mem_raddr),
	.waddr(mem_waddr),
	.wdata(mem_wdata),
	.wmask(mem_wmask),
	.valid(mem_valid),
	.wen(mem_wen),
	.rbyte_num(mem_rbyte_num),
	.exu_valid(exu_valid),
	.wbu_ready(wbu_ready),

	.rdata(mem_rdata),

	.lsu_valid(lsu_valid),
	.lsu_ready(lsu_ready),

	.axi_arready(lsu_axi_arready),
	.axi_arvalid(lsu_axi_arvalid),
	.axi_araddr(lsu_axi_araddr),
	.axi_arid(lsu_axi_arid),
	.axi_arlen(lsu_axi_arlen),
	.axi_arsize(lsu_axi_arsize),	 
	.axi_arburst(lsu_axi_arburst),
	.axi_rdata(lsu_axi_rdata),
	.axi_rresp(lsu_axi_rresp),
	.axi_rvalid(lsu_axi_rvalid),
	.axi_rid(lsu_axi_rid),
	.axi_rlast(lsu_axi_rlast),
	.axi_rready(lsu_axi_rready),
	.axi_awready(lsu_axi_awready),
	.axi_awvalid(lsu_axi_awvalid),
	.axi_awaddr(lsu_axi_awaddr),
	.axi_awid(lsu_axi_awid),
	.axi_awlen(lsu_axi_awlen),
	.axi_awsize(lsu_axi_awsize),
	.axi_awburst(lsu_axi_awburst),
	.axi_wready(lsu_axi_wready),
	.axi_wdata(lsu_axi_wdata),
	.axi_wstrb(lsu_axi_wstrb),
	.axi_wvalid(lsu_axi_wvalid),
	.axi_wlast(lsu_axi_wlast),
	.axi_bresp(lsu_axi_bresp),
	.axi_bvalid(lsu_axi_bvalid),
	.axi_bid(lsu_axi_bid),
	.axi_bready(lsu_axi_bready)
);

WBU	WBU_inst
(
	.sys_clk(clock),
	.sys_rst(reset),
	.gpr_raddr1(gpr_raddr1),
	.gpr_raddr2(gpr_raddr2),
	.gpr_waddr(gpr_waddr),
	.gpr_wdata(gpr_wdata),
	.gpr_wen(gpr_wen),
	.csr_raddr(csr_raddr),
	.csr_waddr1(csr_waddr1),
	.csr_wdata1(csr_wdata1),
	.csr_wen1(csr_wen1),
	.csr_waddr2(csr_waddr2),
	.csr_wdata2(csr_wdata2),
	.csr_wen2(csr_wen2),
	.pc_wen(pc_wen),
	.pc_wdata(pc_wdata),
	.lsu_valid(lsu_valid),

	.gpr_rdata1(gpr_rdata1_in),
	.gpr_rdata2(gpr_rdata2_in),
	.csr_rdata(csr_rdata_in),
	.pc(pc),
	.wbu_ready(wbu_ready),
	.wbu_inst_end(wbu_inst_end)
);

axi_xbar axi_xbar_inst
(
	.sys_clk(clock),
	.sys_rst(reset),
	//ifu
	.ifu_axi_arvalid(ifu_axi_arvalid),
	.ifu_axi_araddr(ifu_axi_araddr),
	.ifu_axi_arid(ifu_axi_arid),
	.ifu_axi_arlen(ifu_axi_arlen),
	.ifu_axi_arsize(ifu_axi_arsize),
	.ifu_axi_arburst(ifu_axi_arburst),
	.ifu_axi_arready(ifu_axi_arready),
	.ifu_axi_rready(ifu_axi_rready),
	.ifu_axi_rdata(ifu_axi_rdata),
	.ifu_axi_rresp(ifu_axi_rresp),
	.ifu_axi_rvalid(ifu_axi_rvalid),
	.ifu_axi_rid(ifu_axi_rid),
	.ifu_axi_rlast(ifu_axi_rlast),
	.ifu_axi_awvalid(ifu_axi_awvalid),
	.ifu_axi_awaddr(ifu_axi_awaddr),
	.ifu_axi_awid(ifu_axi_awid),
	.ifu_axi_awlen(ifu_axi_awlen),
	.ifu_axi_awsize(ifu_axi_awsize),
	.ifu_axi_awburst(ifu_axi_awburst),
	.ifu_axi_awready(ifu_axi_awready),
	.ifu_axi_wdata(ifu_axi_wdata),
	.ifu_axi_wstrb(ifu_axi_wstrb),
	.ifu_axi_wvalid(ifu_axi_wvalid),
	.ifu_axi_wlast(ifu_axi_wlast),
	.ifu_axi_wready(ifu_axi_wready),
	.ifu_axi_bready(ifu_axi_bready),
	.ifu_axi_bresp(ifu_axi_bresp),
	.ifu_axi_bvalid(ifu_axi_bvalid),
	.ifu_axi_bid(ifu_axi_bid),
	//lsu
	.lsu_axi_arvalid(lsu_axi_arvalid),
	.lsu_axi_araddr(lsu_axi_araddr),
	.lsu_axi_arid(lsu_axi_arid),
	.lsu_axi_arlen(lsu_axi_arlen),
	.lsu_axi_arsize(lsu_axi_arsize),
	.lsu_axi_arburst(lsu_axi_arburst),
	.lsu_axi_arready(lsu_axi_arready),

	.lsu_axi_rready(lsu_axi_rready),
	.lsu_axi_rdata(lsu_axi_rdata),
	.lsu_axi_rresp(lsu_axi_rresp),
	.lsu_axi_rvalid(lsu_axi_rvalid),
	.lsu_axi_rid(lsu_axi_rid),
	.lsu_axi_rlast(lsu_axi_rlast),

	.lsu_axi_awvalid(lsu_axi_awvalid),
	.lsu_axi_awaddr(lsu_axi_awaddr),
	.lsu_axi_awid(lsu_axi_awid),
	.lsu_axi_awlen(lsu_axi_awlen),
	.lsu_axi_awsize(lsu_axi_awsize),
	.lsu_axi_awburst(lsu_axi_awburst),
	.lsu_axi_awready(lsu_axi_awready),

	.lsu_axi_wdata(lsu_axi_wdata),
	.lsu_axi_wstrb(lsu_axi_wstrb),
	.lsu_axi_wvalid(lsu_axi_wvalid),
	.lsu_axi_wlast(lsu_axi_wlast),
	.lsu_axi_wready(lsu_axi_wready),

	.lsu_axi_bready(lsu_axi_bready),
	.lsu_axi_bresp(lsu_axi_bresp),
	.lsu_axi_bvalid(lsu_axi_bvalid),
	.lsu_axi_bid(lsu_axi_bid),
	//sram
	.mem_axi_arready(io_master_arready),
	.mem_axi_arvalid(io_master_arvalid),
	.mem_axi_araddr(io_master_araddr),
	.mem_axi_arid(io_master_arid),
	.mem_axi_arlen(io_master_arlen),
	.mem_axi_arsize(io_master_arsize),
	.mem_axi_arburst(io_master_arburst),

	.mem_axi_rdata(io_master_rdata),
	.mem_axi_rresp(io_master_rresp),
	.mem_axi_rvalid(io_master_rvalid),
	.mem_axi_rid(io_master_rid),
	.mem_axi_rlast(io_master_rlast),
	.mem_axi_rready(io_master_rready),

	.mem_axi_awready(io_master_awready),
	.mem_axi_awvalid(io_master_awvalid),
	.mem_axi_awaddr(io_master_awaddr),
	.mem_axi_awid(io_master_awid),
	.mem_axi_awlen(io_master_awlen),
	.mem_axi_awsize(io_master_awsize),
	.mem_axi_awburst(io_master_awburst),

	.mem_axi_wready(io_master_wready),
	.mem_axi_wdata(io_master_wdata),
	.mem_axi_wstrb(io_master_wstrb),
	.mem_axi_wvalid(io_master_wvalid),
	.mem_axi_wlast(io_master_wlast),

	.mem_axi_bresp(io_master_bresp),
	.mem_axi_bvalid(io_master_bvalid),
	.mem_axi_bid(io_master_bid),
	.mem_axi_bready(io_master_bready),
	//clint
	.clint_axi_arready(clint_axi_arready),
	.clint_axi_arvalid(clint_axi_arvalid),
	.clint_axi_araddr(clint_axi_araddr),
	.clint_axi_rdata(clint_axi_rdata),
	.clint_axi_rresp(clint_axi_rresp),
	.clint_axi_rvalid(clint_axi_rvalid),
	.clint_axi_rready(clint_axi_rready),
	.clint_axi_awready(clint_axi_awready),
	.clint_axi_awvalid(clint_axi_awvalid),
	.clint_axi_awaddr(clint_axi_awaddr),
	.clint_axi_wready(clint_axi_wready),
	.clint_axi_wdata(clint_axi_wdata),
	.clint_axi_wstrb(clint_axi_wstrb),
	.clint_axi_wvalid(clint_axi_wvalid),
	.clint_axi_bresp(clint_axi_bresp),
	.clint_axi_bvalid(clint_axi_bvalid),
	.clint_axi_bready(clint_axi_bready)
);

/*
ram ram_inst
(
	.sys_clk(clock),
	.sys_rst(reset),
	.axi_arvalid(mem_axi_arvalid),
	.axi_arready(mem_axi_arready),
	.axi_araddr(mem_axi_araddr),
	.axi_rdata(mem_axi_rdata),
	.axi_rresp(mem_axi_rresp),
	.axi_rvalid(mem_axi_rvalid),
	.axi_rready(mem_axi_rready),
	.axi_awready(mem_axi_awready),
	.axi_awvalid(mem_axi_awvalid),
	.axi_awaddr(mem_axi_awaddr),
	.axi_wready(mem_axi_wready),
	.axi_wdata(mem_axi_wdata),
	.axi_wstrb(mem_axi_wstrb),
	.axi_wvalid(mem_axi_wvalid),
	.axi_bresp(mem_axi_bresp),
	.axi_bvalid(mem_axi_bvalid),
	.axi_bready(mem_axi_bready)
);*/
/*
uart_ctrl uart_ctrl_inst
(
	.sys_clk(clock),
	.sys_rst(reset),
	.axi_arvalid(uart_axi_arvalid),
	.axi_araddr(uart_axi_araddr),
	.axi_arready(uart_axi_arready),
	.axi_rready(uart_axi_rready),
	.axi_rdata(uart_axi_rdata),
	.axi_rresp(uart_axi_rresp),
	.axi_rvalid(uart_axi_rvalid),
	.axi_awvalid(uart_axi_awvalid),
	.axi_awaddr(uart_axi_awaddr),
	.axi_awready(uart_axi_awready),
	.axi_wdata(uart_axi_wdata),
	.axi_wstrb(uart_axi_wstrb),
	.axi_wvalid(uart_axi_wvalid),
	.axi_wready(uart_axi_wready),
	.axi_bready(uart_axi_bready),
	.axi_bresp(uart_axi_bresp),
	.axi_bvalid(uart_axi_bvalid)
);
*/
clint clint_inst
(
	.sys_clk(clock),
	.sys_rst(reset),
	.axi_arvalid(clint_axi_arvalid),
	.axi_araddr(clint_axi_araddr),
	.axi_arready(clint_axi_arready),
	.axi_rready(clint_axi_rready),
	.axi_rdata(clint_axi_rdata),
	.axi_rresp(clint_axi_rresp),
	.axi_rvalid(clint_axi_rvalid),
	.axi_awvalid(clint_axi_awvalid),
	.axi_awaddr(clint_axi_awaddr),
	.axi_awready(clint_axi_awready),
	.axi_wdata(clint_axi_wdata),
	.axi_wstrb(clint_axi_wstrb),
	.axi_wvalid(clint_axi_wvalid),
	.axi_wready(clint_axi_wready),
	.axi_bready(clint_axi_bready),
	.axi_bresp(clint_axi_bresp),
	.axi_bvalid(clint_axi_bvalid)
);

endmodule

