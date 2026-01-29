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

wire				ifu_axi_arvalid_d;
wire	[31:0]		ifu_axi_araddr_d;
wire				ifu_axi_arready_d;
wire				ifu_axi_rready_d;
wire	[31:0]		ifu_axi_rdata_d;
wire	[2:0]		ifu_axi_rresp_d;
wire				ifu_axi_rvalid_d;

wire				lsu_axi_arready_d;
wire				lsu_axi_arvalid_d;
wire	[31:0]		lsu_axi_araddr_d;
wire	[31:0]		lsu_axi_rdata_d;
wire	[2:0]		lsu_axi_rresp_d;
wire				lsu_axi_rvalid_d;
wire				lsu_axi_rready_d;
wire				lsu_axi_awready_d;
wire				lsu_axi_awvalid_d;
wire	[31:0]		lsu_axi_awaddr_d;
wire				lsu_axi_wready_d;
wire	[31:0]		lsu_axi_wdata_d;
wire	[3:0]		lsu_axi_wstrb_d;
wire				lsu_axi_wvalid_d;
wire	[2:0]		lsu_axi_bresp_d;
wire				lsu_axi_bvalid_d;
wire				lsu_axi_bready_d;

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
	//.axi_arready(ifu_axi_arready),
	.axi_arready(ifu_axi_arready_d),
	.axi_rready(ifu_axi_rready),
	//.axi_rdata(ifu_axi_rdata),
	//.axi_rresp(ifu_axi_rresp),
	//.axi_rvalid(ifu_axi_rvalid),
	.axi_rdata(ifu_axi_rdata_d),
	.axi_rresp(ifu_axi_rresp_d),
	.axi_rvalid(ifu_axi_rvalid_d),
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

LFSR_adv
#(
	.MAX_DELAY(5),
	.WIDTH_12(32),
	.WIDTH_13(1),
	.WIDTH_21(1)
)LFSR_adv_ifu1(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.signal1_1(ifu_axi_arvalid),
	.signal1_2(ifu_axi_araddr),
	.signal1_3(1'b0),
	.signal2_1(ifu_axi_arready),

	.signal1_1_d(ifu_axi_arvalid_d),
	.signal1_2_d(ifu_axi_araddr_d),
	.signal1_3_d(),
	.signal2_1_d(ifu_axi_arready_d)
);

LFSR_adv
#(
	.MAX_DELAY(5),
	.WIDTH_12(32),
	.WIDTH_13(3),
	.WIDTH_21(1)
)LFSR_adv_ifu2(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.signal1_1(ifu_axi_rvalid),
	.signal1_2(ifu_axi_rdata),
	.signal1_3(ifu_axi_rresp),
	.signal2_1(ifu_axi_rready),

	.signal1_1_d(ifu_axi_rvalid_d),
	.signal1_2_d(ifu_axi_rdata_d),
	.signal1_3_d(ifu_axi_rresp_d),
	.signal2_1_d(ifu_axi_rready_d)
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

	//.axi_arready(lsu_axi_arready),
	.axi_arready(lsu_axi_arready_d),
	.axi_arvalid(lsu_axi_arvalid),
	.axi_araddr(lsu_axi_araddr),
	//.axi_rdata(lsu_axi_rdata),
	//.axi_rresp(lsu_axi_rresp),
	//.axi_rvalid(lsu_axi_rvalid),
	.axi_rdata(lsu_axi_rdata_d),
	.axi_rresp(lsu_axi_rresp_d),
	.axi_rvalid(lsu_axi_rvalid_d),
	.axi_rready(lsu_axi_rready),
	//.axi_awready(lsu_axi_awready),
	.axi_awready(lsu_axi_awready_d),
	.axi_awvalid(lsu_axi_awvalid),
	.axi_awaddr(lsu_axi_awaddr),
	//.axi_wready(lsu_axi_wready),
	.axi_wready(lsu_axi_wready_d),
	.axi_wdata(lsu_axi_wdata),
	.axi_wstrb(lsu_axi_wstrb),
	.axi_wvalid(lsu_axi_wvalid),
	//.axi_bresp(lsu_axi_bresp),
	//.axi_bvalid(lsu_axi_bvalid),
	.axi_bresp(lsu_axi_bresp_d),
	.axi_bvalid(lsu_axi_bvalid_d),
	.axi_bready(lsu_axi_bready)
);

LFSR_adv
#(
	.MAX_DELAY(5),
	.WIDTH_12(32),
	.WIDTH_13(1),
	.WIDTH_21(1)
)LFSR_adv_lsu1(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.signal1_1(lsu_axi_arvalid),
	.signal1_2(lsu_axi_araddr),
	.signal1_3(1'b0),
	.signal2_1(lsu_axi_arready),

	.signal1_1_d(lsu_axi_arvalid_d),
	.signal1_2_d(lsu_axi_araddr_d),
	.signal1_3_d(),
	.signal2_1_d(lsu_axi_arready_d)
);

LFSR_adv
#(
	.MAX_DELAY(5),
	.WIDTH_12(3),
	.WIDTH_13(32),
	.WIDTH_21(1)
)LFSR_adv_lsu2(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.signal1_1(lsu_axi_rvalid),
	.signal1_2(lsu_axi_rresp),
	.signal1_3(lsu_axi_rdata),
	.signal2_1(lsu_axi_rready),

	.signal1_1_d(lsu_axi_rvalid_d),
	.signal1_2_d(lsu_axi_rresp_d),
	.signal1_3_d(lsu_axi_rdata_d),
	.signal2_1_d(lsu_axi_rready_d)
);

LFSR_adv
#(
	.MAX_DELAY(5),
	.WIDTH_12(32),
	.WIDTH_13(1),
	.WIDTH_21(1)
)LFSR_adv_lsu3(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.signal1_1(lsu_axi_awvalid),
	.signal1_2(lsu_axi_awaddr),
	.signal1_3(1'b0),
	.signal2_1(lsu_axi_awready),

	.signal1_1_d(lsu_axi_awvalid_d),
	.signal1_2_d(lsu_axi_awaddr_d),
	.signal1_3_d(),
	.signal2_1_d(lsu_axi_awready_d)
);

LFSR_adv
#(
	.MAX_DELAY(5),
	.WIDTH_12(32),
	.WIDTH_13(4),
	.WIDTH_21(1)
)LFSR_adv_lsu4(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.signal1_1(lsu_axi_wvalid),
	.signal1_2(lsu_axi_wdata),
	.signal1_3(lsu_axi_wstrb),
	.signal2_1(lsu_axi_wready),

	.signal1_1_d(lsu_axi_wvalid_d),
	.signal1_2_d(lsu_axi_wdata_d),
	.signal1_3_d(lsu_axi_wstrb_d),
	.signal2_1_d(lsu_axi_wready_d)
);

LFSR_adv
#(
	.MAX_DELAY(5),
	.WIDTH_12(3),
	.WIDTH_13(1),
	.WIDTH_21(1)
)LFSR_adv_lsu5(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.signal1_1(lsu_axi_bvalid),
	.signal1_2(lsu_axi_bresp),
	.signal1_3(1'b0),
	.signal2_1(lsu_axi_bready),

	.signal1_1_d(lsu_axi_bvalid_d),
	.signal1_2_d(lsu_axi_bresp_d),
	.signal1_3_d(),
	.signal2_1_d(lsu_axi_bready_d)
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

rom rom_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	//.axi_arvalid(ifu_axi_arvalid),
	.axi_arvalid(ifu_axi_arvalid_d),
	//.axi_araddr(ifu_axi_araddr),
	.axi_araddr(ifu_axi_araddr_d),
	.axi_arready(ifu_axi_arready),
	//.axi_rready(ifu_axi_rready),
	.axi_rready(ifu_axi_rready_d),
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

ram ram_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),

	//.axi_arvalid(lsu_axi_arvalid),
	.axi_arready(lsu_axi_arready),
	.axi_arvalid(lsu_axi_arvalid_d),
	//.axi_araddr(lsu_axi_araddr),
	.axi_araddr(lsu_axi_araddr_d),
	.axi_rdata(lsu_axi_rdata),
	.axi_rresp(lsu_axi_rresp),
	.axi_rvalid(lsu_axi_rvalid),
	//.axi_rready(lsu_axi_rready),
	.axi_rready(lsu_axi_rready_d),
	.axi_awready(lsu_axi_awready),
	//.axi_awvalid(lsu_axi_awvalid),
	//.axi_awaddr(lsu_axi_awaddr),
	.axi_awvalid(lsu_axi_awvalid_d),
	.axi_awaddr(lsu_axi_awaddr_d),
	.axi_wready(lsu_axi_wready),
	//.axi_wdata(lsu_axi_wdata),
	//.axi_wstrb(lsu_axi_wstrb),
	//.axi_wvalid(lsu_axi_wvalid),
	.axi_wdata(lsu_axi_wdata_d),
	.axi_wstrb(lsu_axi_wstrb_d),
	.axi_wvalid(lsu_axi_wvalid_d),
	.axi_bresp(lsu_axi_bresp),
	.axi_bvalid(lsu_axi_bvalid),
	//.axi_bready(lsu_axi_bready)
	.axi_bready(lsu_axi_bready_d)
);

endmodule

