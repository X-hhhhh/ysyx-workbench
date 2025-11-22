module top
(
	input	wire			sys_clk,
	input	wire			sys_rst,

	output	wire	[31:0]		pc,
	output	wire			mem_valid
);

/* verilator lint_off UNOPTFLAT */
wire	[4:0]		gpr_raddr1;
wire	[4:0]		gpr_raddr2;
/* verilator lint_on UNOPTFLAT */

wire	[31:0]		inst;

wire			gpr_wen;
wire	[4:0]		gpr_waddr;
wire	[31:0]		imm;
wire	[31:0]		gpr_wdata;
wire	[31:0]		gpr_rdata1_in;
wire	[31:0]		gpr_rdata2_in;
wire	[31:0]		gpr_rdata1;
wire	[31:0]		gpr_rdata2;
wire			pc_wen;
wire	[31:0]		pc_wdata;

wire	[31:0]		EXU_data;
wire	[10:0]		EXU_mode;

wire	[31:0]		mem_rdata;
//wire			mem_valid;
wire			mem_wen;
wire	[31:0]		mem_raddr;
wire	[31:0]		mem_waddr;
wire	[31:0]		mem_wdata;
wire	[3:0]		mem_wmask;
wire	[1:0]		mem_rbyte_num;


IFU	IFU_inst
(
	.sys_rst(sys_rst),
	.pc(pc),

	.inst(inst)
);

IDU	IDU_inst
(
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	.inst(inst),
	.gpr_rdata1_in(gpr_rdata1_in),
	.gpr_rdata2_in(gpr_rdata2_in),
	.EXU_data(EXU_data),
	.pc(pc),
	.mem_rdata(mem_rdata),

	.gpr_raddr1(gpr_raddr1),
	.gpr_raddr2(gpr_raddr2),
	.gpr_wen(gpr_wen),
	.gpr_waddr(gpr_waddr),
	.gpr_wdata(gpr_wdata),
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
	.mem_rbyte_num(mem_rbyte_num)
);

EXU	EXU_inst
(
	.gpr_rdata1_in(gpr_rdata1_in),
	.gpr_rdata2_in(gpr_rdata2_in),
	.imm(imm),
	.EXU_mode(EXU_mode),

	.EXU_data(EXU_data)
);

LSU	LSU_inst
(
	.sys_clk(sys_clk),
	.raddr(mem_raddr),
	.waddr(mem_waddr),
	.wdata(mem_wdata),
	.wmask(mem_wmask),
	.valid(mem_valid),
	.wen(mem_wen),
	.rbyte_num(mem_rbyte_num),

	.rdata(mem_rdata)
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
	.pc_wen(pc_wen),
	.pc_wdata(pc_wdata),

	.gpr_rdata1(gpr_rdata1_in),
	.gpr_rdata2(gpr_rdata2_in),
	.pc(pc)
);

endmodule

