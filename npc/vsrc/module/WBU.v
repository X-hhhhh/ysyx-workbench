module	WBU(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input	wire	[4:0]		gpr_raddr1,
	input	wire	[4:0]		gpr_raddr2,
	input	wire	[4:0]		gpr_waddr,
	input	wire	[31:0]		gpr_wdata,
	input	wire			gpr_wen,
	input	wire			pc_wen,
	input	wire	[31:0]		pc_wdata,

	output	wire	[31:0]		gpr_rdata1,
	output	wire	[31:0]		gpr_rdata2,
	output	reg	[31:0] 		pc,
	output	reg	[31:0]		gpr	[15:0]
);

//reg	[31:0]		gpr	[15:0];
reg	[31:0]		PC;

integer	i;

assign gpr_rdata1 = gpr[gpr_raddr1[3:0]];
assign gpr_rdata2 = gpr[gpr_raddr2[3:0]];
assign pc = PC;

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		for(i = 0; i < 16; i = i + 1) begin
			gpr[i] <= 32'b0;
		end	
	end else if(gpr_wen == 1'b1 && gpr_waddr != 5'b0) begin
		gpr[gpr_waddr[3:0]] <= gpr_wdata;
	end else begin
		gpr[0] <= 32'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		PC <= 'h80000000;
	end else if(pc_wen == 1'b1) begin
		PC <= pc_wdata;
	end else begin
		PC <= PC + 4;	
	end
end

endmodule

