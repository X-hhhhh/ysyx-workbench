module	WBU(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input	wire	[4:0]	gpr_raddr1,
	input	wire	[4:0]	gpr_raddr2,
	input	wire	[4:0]	gpr_waddr,
	input	wire	[31:0]	gpr_wdata,
	input	wire			gpr_wen,
	input	wire	[11:0]	csr_raddr,
	input	wire	[11:0]	csr_waddr1,
	input	wire	[31:0]	csr_wdata1,
	input	wire			csr_wen1,
	input	wire	[11:0]	csr_waddr2,
	input	wire	[31:0]	csr_wdata2,
	input	wire			csr_wen2,
	input	wire			pc_wen,
	input	wire	[31:0]	pc_wdata,

	output	wire	[31:0]	gpr_rdata1,
	output	wire	[31:0]	gpr_rdata2,
	output	reg		[31:0]	csr_rdata,
	output	reg		[31:0] 	pc
);

export "DPI-C" function dpi_gpr_read;

function int dpi_gpr_read(input byte addr);
	if(addr >= 0 && addr <= 15) begin
		return gpr[addr[3:0]];
	end
	return 0;
endfunction

reg	[31:0]		gpr		[15:0];
reg	[31:0]		csr_mcycle;
reg	[31:0]		csr_mcycleh;
reg	[31:0]		csr_mvendorid;
reg	[31:0]		csr_marchid;
reg	[31:0]		csr_mtvec;
reg	[31:0]		csr_mepc;
reg	[31:0]		csr_mcause;
reg	[31:0]		csr_status; 

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

always@(*) begin
	case(csr_raddr)
		12'hB00: csr_rdata = csr_mcycle;	//mcycle
		12'hB80: csr_rdata = csr_mcycleh;	//mcycleh
		12'hF11: csr_rdata = csr_mvendorid;	//mvendorid
		12'hF12: csr_rdata = csr_marchid;	//marchid
		12'h305: csr_rdata = csr_mtvec;		//mtvec
		12'h341: csr_rdata = csr_mepc;		//mepc
		12'h342: csr_rdata = csr_mcause;	//mcause
		12'h300: csr_rdata = csr_status;	//status
		default: csr_rdata = 32'b0;
	endcase
end

//mcycle, mcycleh
always@(posedge sys_clk or negedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		csr_mcycle 	<= 32'b0;
		csr_mcycleh <= 32'b0;
	end else if(csr_mcycle == 32'hFFFFFFFF) begin
		csr_mcycle 	<= csr_mcycle + 1'b1;
		csr_mcycleh <= csr_mcycleh + 1'b1;
	end else begin
		csr_mcycle <= csr_mcycle + 1'b1;
	end
end

//mvendorid, marchid
always@(posedge sys_clk or negedge sys_rst) begin 
	csr_mvendorid 	<= 32'h79737978;		//ysyx(ASCII)
	csr_marchid 	<= 32'h66666666;		//student ID
end

//mtvec, mepc, mcause, mstatus
always@(posedge sys_clk or negedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		csr_mtvec 	<= 32'b0;
		csr_mepc 	<= 32'b0;
		csr_mcause 	<= 32'b0;
		csr_status 	<= 32'h1800;		//set status to 0x1800 to pass difftest
	end else if(csr_wen1 == 1'b1) begin
		case(csr_waddr1)
			12'h305: csr_mtvec 	<= csr_wdata1;
			12'h341: csr_mepc 	<= csr_wdata1;
			12'h342: csr_mcause <= csr_wdata1;
			12'h300: csr_status <= csr_wdata1;
			default: begin
				csr_mtvec 	<= csr_mtvec;
				csr_mepc 	<= csr_mepc;
				csr_mcause 	<= csr_mcause;
				csr_status	<= csr_status;
			end
		endcase
		//wen2 is valid only when wen1 is valid
		if(csr_wen2 == 1'b1) begin
			case(csr_waddr2)
				12'h305: csr_mtvec 	<= csr_wdata2;
				12'h341: csr_mepc 	<= csr_wdata2;
				12'h342: csr_mcause <= csr_wdata2;
				12'h300: csr_status <= csr_wdata2;
				default: begin
					csr_mtvec 	<= csr_mtvec;
					csr_mepc 	<= csr_mepc;
					csr_mcause 	<= csr_mcause;
					csr_status	<= csr_status;
				end
			endcase
		end
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

