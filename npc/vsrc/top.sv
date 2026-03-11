module top
(
	input	wire			sys_clk,
	input	wire			sys_rst,

	output	wire	[31:0]	pc,
	output	wire			mem_valid
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
//wire				mem_valid;
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
wire				ifu_axi_rready;
wire	[31:0]		ifu_axi_rdata;
wire	[2:0]		ifu_axi_rresp;
wire				ifu_axi_rvalid;
wire				ifu_axi_awvalid;
wire	[31:0]		ifu_axi_awaddr;
wire				ifu_axi_awready;
wire	[31:0]		ifu_axi_wdata;
wire	[3:0]		ifu_axi_wstrb;
wire				ifu_axi_wvalid;
wire				ifu_axi_wready;
wire				ifu_axi_bready;
wire	[2:0]		ifu_axi_bresp;
wire				ifu_axi_bvalid;

wire				idu_ready;
wire				idu_valid;
wire				exu_valid;
wire				exu_ready;

wire				lsu_valid;
wire				lsu_ready;
wire				lsu_axi_arready;
wire				lsu_axi_arvalid;
wire	[31:0]		lsu_axi_araddr;
wire	[31:0]		lsu_axi_rdata;
wire	[2:0]		lsu_axi_rresp;
wire				lsu_axi_rvalid;
wire				lsu_axi_rready;
wire				lsu_axi_awready;
wire				lsu_axi_awvalid;
wire	[31:0]		lsu_axi_awaddr;
wire				lsu_axi_wready;
wire	[31:0]		lsu_axi_wdata;
wire	[3:0]		lsu_axi_wstrb;
wire				lsu_axi_wvalid;
wire	[2:0]		lsu_axi_bresp;
wire				lsu_axi_bvalid;
wire				lsu_axi_bready;

wire				wbu_ready;
wire				wbu_inst_end;

wire				mem_axi_arready;
wire				mem_axi_arvalid;
wire	[31:0]		mem_axi_araddr;
wire	[31:0]		mem_axi_rdata;
wire	[2:0]		mem_axi_rresp;
wire				mem_axi_rvalid;
wire				mem_axi_rready;
wire				mem_axi_awready;
wire				mem_axi_awvalid;
wire	[31:0]		mem_axi_awaddr;
wire				mem_axi_wready;
wire	[31:0]		mem_axi_wdata;
wire	[3:0]		mem_axi_wstrb;
wire				mem_axi_wvalid;
wire	[2:0]		mem_axi_bresp;
wire				mem_axi_bvalid;
wire				mem_axi_bready;

wire				uart_axi_arready;
wire				uart_axi_arvalid;
wire	[31:0]		uart_axi_araddr;
wire	[31:0]		uart_axi_rdata;
wire	[2:0]		uart_axi_rresp;
wire				uart_axi_rvalid;
wire				uart_axi_rready;
wire				uart_axi_awready;
wire				uart_axi_awvalid;
wire	[31:0]		uart_axi_awaddr;
wire				uart_axi_wready;
wire	[31:0]		uart_axi_wdata;
wire	[3:0]		uart_axi_wstrb;
wire				uart_axi_wvalid;
wire	[2:0]		uart_axi_bresp;
wire				uart_axi_bvalid;
wire				uart_axi_bready;

wire				clint_axi_arready;
wire				clint_axi_arvalid;
wire	[31:0]		clint_axi_araddr;
wire	[31:0]		clint_axi_rdata;
wire	[2:0]		clint_axi_rresp;
wire				clint_axi_rvalid;
wire				clint_axi_rready;
wire				clint_axi_awready;
wire				clint_axi_awvalid;
wire	[31:0]		clint_axi_awaddr;
wire				clint_axi_wready;
wire	[31:0]		clint_axi_wdata;
wire	[3:0]		clint_axi_wstrb;
wire				clint_axi_wvalid;
wire	[2:0]		clint_axi_bresp;
wire				clint_axi_bvalid;
wire				clint_axi_bready;

IFU	IFU_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.pc(pc),
	.idu_ready(idu_ready),
	.wbu_inst_end(wbu_inst_end),

	.ifu_valid(ifu_valid),
	.inst(inst_in),

	.axi_arvalid(ifu_axi_arvalid),
	.axi_araddr(ifu_axi_araddr),
	.axi_arready(ifu_axi_arready),
	.axi_rready(ifu_axi_rready),
	.axi_rdata(ifu_axi_rdata),
	.axi_rresp(ifu_axi_rresp),
	.axi_rvalid(ifu_axi_rvalid),
	.axi_awvalid(ifu_axi_awvalid),
	.axi_awaddr(ifu_axi_awaddr),
	.axi_awready(ifu_axi_awready),
	.axi_wdata(ifu_axi_wdata),
	.axi_wstrb(ifu_axi_wstrb),
	.axi_wvalid(ifu_axi_wvalid),
	.axi_wready(ifu_axi_wready),
	.axi_bready(ifu_axi_bready),
	.axi_bresp(ifu_axi_bresp),
	.axi_bvalid(ifu_axi_bvalid)
);

IDU	IDU_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
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
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
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
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
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
	.axi_rdata(lsu_axi_rdata),
	.axi_rresp(lsu_axi_rresp),
	.axi_rvalid(lsu_axi_rvalid),
	.axi_rready(lsu_axi_rready),
	.axi_awready(lsu_axi_awready),
	.axi_awvalid(lsu_axi_awvalid),
	.axi_awaddr(lsu_axi_awaddr),
	.axi_wready(lsu_axi_wready),
	.axi_wdata(lsu_axi_wdata),
	.axi_wstrb(lsu_axi_wstrb),
	.axi_wvalid(lsu_axi_wvalid),
	.axi_bresp(lsu_axi_bresp),
	.axi_bvalid(lsu_axi_bvalid),
	.axi_bready(lsu_axi_bready)
);

WBU	WBU_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
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

xbar xbar_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	//ifu
	.ifu_axi_arvalid(ifu_axi_arvalid),
	.ifu_axi_araddr(ifu_axi_araddr),
	.ifu_axi_arready(ifu_axi_arready),
	.ifu_axi_rready(ifu_axi_rready),
	.ifu_axi_rdata(ifu_axi_rdata),
	.ifu_axi_rresp(ifu_axi_rresp),
	.ifu_axi_rvalid(ifu_axi_rvalid),
	.ifu_axi_awvalid(ifu_axi_awvalid),
	.ifu_axi_awaddr(ifu_axi_awaddr),
	.ifu_axi_awready(ifu_axi_awready),
	.ifu_axi_wdata(ifu_axi_wdata),
	.ifu_axi_wstrb(ifu_axi_wstrb),
	.ifu_axi_wvalid(ifu_axi_wvalid),
	.ifu_axi_wready(ifu_axi_wready),
	.ifu_axi_bready(ifu_axi_bready),
	.ifu_axi_bresp(ifu_axi_bresp),
	.ifu_axi_bvalid(ifu_axi_bvalid),
	//lsu
	.lsu_axi_arvalid(lsu_axi_arvalid),
	.lsu_axi_araddr(lsu_axi_araddr),
	.lsu_axi_arready(lsu_axi_arready),
	.lsu_axi_rready(lsu_axi_rready),
	.lsu_axi_rdata(lsu_axi_rdata),
	.lsu_axi_rresp(lsu_axi_rresp),
	.lsu_axi_rvalid(lsu_axi_rvalid),
	.lsu_axi_awvalid(lsu_axi_awvalid),
	.lsu_axi_awaddr(lsu_axi_awaddr),
	.lsu_axi_awready(lsu_axi_awready),
	.lsu_axi_wdata(lsu_axi_wdata),
	.lsu_axi_wstrb(lsu_axi_wstrb),
	.lsu_axi_wvalid(lsu_axi_wvalid),
	.lsu_axi_wready(lsu_axi_wready),
	.lsu_axi_bready(lsu_axi_bready),
	.lsu_axi_bresp(lsu_axi_bresp),
	.lsu_axi_bvalid(lsu_axi_bvalid),
	//sram
	.mem_axi_arready(mem_axi_arready),
	.mem_axi_arvalid(mem_axi_arvalid),
	.mem_axi_araddr(mem_axi_araddr),
	.mem_axi_rdata(mem_axi_rdata),
	.mem_axi_rresp(mem_axi_rresp),
	.mem_axi_rvalid(mem_axi_rvalid),
	.mem_axi_rready(mem_axi_rready),
	.mem_axi_awready(mem_axi_awready),
	.mem_axi_awvalid(mem_axi_awvalid),
	.mem_axi_awaddr(mem_axi_awaddr),
	.mem_axi_wready(mem_axi_wready),
	.mem_axi_wdata(mem_axi_wdata),
	.mem_axi_wstrb(mem_axi_wstrb),
	.mem_axi_wvalid(mem_axi_wvalid),
	.mem_axi_bresp(mem_axi_bresp),
	.mem_axi_bvalid(mem_axi_bvalid),
	.mem_axi_bready(mem_axi_bready),
	//uart
	.uart_axi_arready(uart_axi_arready),
	.uart_axi_arvalid(uart_axi_arvalid),
	.uart_axi_araddr(uart_axi_araddr),
	.uart_axi_rdata(uart_axi_rdata),
	.uart_axi_rresp(uart_axi_rresp),
	.uart_axi_rvalid(uart_axi_rvalid),
	.uart_axi_rready(uart_axi_rready),
	.uart_axi_awready(uart_axi_awready),
	.uart_axi_awvalid(uart_axi_awvalid),
	.uart_axi_awaddr(uart_axi_awaddr),
	.uart_axi_wready(uart_axi_wready),
	.uart_axi_wdata(uart_axi_wdata),
	.uart_axi_wstrb(uart_axi_wstrb),
	.uart_axi_wvalid(uart_axi_wvalid),
	.uart_axi_bresp(uart_axi_bresp),
	.uart_axi_bvalid(uart_axi_bvalid),
	.uart_axi_bready(uart_axi_bready),
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

ram ram_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
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
);

uart_ctrl uart_ctrl_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
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

clint clint_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
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

