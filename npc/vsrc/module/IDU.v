module	IDU(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input	wire	[31:0]		inst,
	input	wire	[31:0]		gpr_rdata1_in,
	input	wire	[31:0]		gpr_rdata2_in,
	input	wire	[31:0]		EXU_data,
	input	wire	[31:0] 		pc,
	input	wire	[31:0]		mem_rdata,

	output	reg	[4:0]		gpr_raddr1,
	output	reg	[4:0]		gpr_raddr2,
	output	reg			gpr_wen,
	output	reg	[4:0]		gpr_waddr,
	output	reg	[31:0]		gpr_wdata,
	output	reg	[31:0]		imm,
	output	reg			pc_wen,
	output	reg	[31:0]		pc_wdata,
	output	reg	[1:0]		EXU_mode,	//bit[0]: 0 for rs1 and rs2, 1 for rs1 and imm, bit[1]: 0 for add, 1 for sub
	output	reg			mem_valid,
	output	reg			mem_wen,
	output	reg	[31:0]		mem_raddr,
	output	reg	[31:0]		mem_waddr,
	output	reg	[31:0]		mem_wdata,
	output	reg	[3:0]		mem_wmask,
	output	reg	[1:0]		mem_rbyte_num	//the num of bytes when reading memory, 00: 1byte, 01: 2bytes, 10: 4bytes, 11: 8bytes
);

import "DPI-C" function void nemu_trap();

wire	[6:0]	opcode;
wire	[2:0]	funct3;
wire	[4:0]	rd;
wire	[4:0]	rs1;
wire	[4:0]	rs2;

/* verilator lint_off UNOPTFLAT */
reg	[5:0]	imm_type;
/* verilator lint_on UNOPTFLAT */

assign opcode 	= inst[6:0];
assign funct3 	= inst[14:12];
assign rd 	= inst[11:7];
assign rs1	= inst[19:15];
assign rs2	= inst[24:20];

always@(*) begin
	casez({funct3, opcode})
		//addi, I type
		10'b000_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= 6'b000001;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//jalr, I type
		10'b000_1100111: begin 
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= pc + 4;
			imm_type	= 6'b000001;
			pc_wen 		= 1'b1;
			pc_wdata 	= (gpr_rdata1_in + imm) & 32'hFFFFFFFE;
		end
		//lw, I type
		10'b010_0000011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= mem_rdata;
			imm_type	= 6'b000001;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//lbu, I type
		10'b100_0000011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= mem_rdata;
			imm_type	= 6'b000001;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		10'b000_0110011: 
			case(inst[31:25])
				//add, R type
				7'b0000000: begin
					gpr_raddr1 	= rs1;
					gpr_raddr2	= rs2;
					gpr_wen 	= 1'b1;
					gpr_waddr	= rd;
					gpr_wdata	= EXU_data;
					imm_type	= 6'b000010;
					pc_wen 		= 1'b0;
					pc_wdata	= 32'b0;
				end
				default: begin
					gpr_raddr1 	= 5'b0;
					gpr_raddr2 	= 5'b0;
					gpr_wen 	= 1'b0;
					gpr_waddr	= 5'b0;
					gpr_wdata	= 32'b0;
					imm_type	= 6'b0;
					pc_wen		= 1'b0;
					pc_wdata	= 32'b0;
				end
			endcase
		//lui, U type
		10'b???_0110111: begin
			gpr_raddr1 	= 5'b0;
			gpr_raddr2	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= imm;
			imm_type	= 6'b000010;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//sw, S type
		10'b010_0100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= 6'b000100;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//sb, S type
		10'b000_0100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= 6'b000100;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		10'b000_1110011: begin
			case(inst) 
				//ebreak
				32'h00100073: begin
					nemu_trap();
					gpr_raddr1 	= 5'b0;
					gpr_raddr2	= 5'b0;
					gpr_wen 	= 1'b0;
					gpr_waddr	= 5'b0;
					gpr_wdata	= 32'b0;
					imm_type	= 6'b0;
					pc_wen 		= 1'b0;
					pc_wdata	= 32'b0;
				end
				default: begin
					gpr_raddr1 	= 5'b0;
					gpr_raddr2 	= 5'b0;
					gpr_wen 	= 1'b0;
					gpr_waddr	= 5'b0;
					gpr_wdata	= 32'b0;
					imm_type	= 6'b0;
					pc_wen		= 1'b0;
					pc_wdata	= 32'b0;

				end
			endcase
		end
		default: begin
			gpr_raddr1 	= 5'b0;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= 6'b0;
			pc_wen		= 1'b0;
			pc_wdata	= 32'b0;
		end
	endcase
end

//memory operation instruction
always@(*) begin
	casez({funct3, opcode})
		//lw, I type
		10'b010_0000011: begin
			mem_valid 	= 1'b1;
                        mem_wen		= 1'b0;
                        mem_raddr 	= EXU_data;
                        mem_waddr	= 32'b0;
                        mem_wdata 	= 32'b0;
                        mem_wmask	= 4'b0;
			mem_rbyte_num	= 2'b10;	//4bytes
		end
		//lbu, I type
		10'b100_0000011: begin
			mem_valid 	= 1'b1;
                        mem_wen		= 1'b0;
                        mem_raddr 	= EXU_data;
                        mem_waddr	= 32'b0;
                        mem_wdata 	= 32'b0;
                        mem_wmask	= 4'b0;
			mem_rbyte_num	= 2'b00;	//1byte
		end
		//sw, S type
		10'b010_0100011: begin
			mem_valid 	= 1'b1;
                        mem_wen		= 1'b1;
                        mem_raddr 	= 32'b0;
                        mem_waddr	= EXU_data;
                        mem_wdata 	= gpr_rdata2_in;
                        mem_wmask	= 4'b1111;
			mem_rbyte_num	= 2'b00;	//no need to read
		end
		//sb, S type
		10'b000_0100011: begin
			mem_valid 	= 1'b1;
                        mem_wen		= 1'b1;
                        mem_raddr 	= 32'b0;
                        mem_waddr	= EXU_data;
                        mem_wdata 	= {24'b0, gpr_rdata2_in[7:0]} << ((EXU_data & 32'h3) << 3);
                        mem_wmask	= 4'b1 << EXU_data[1:0];
			mem_rbyte_num	= 2'b00;	//no need to read
		end
		default: begin
			mem_valid 	= 1'b0;
                        mem_wen		= 1'b0;
                        mem_raddr 	= 32'b0;
                        mem_waddr	= 32'b0;
                        mem_wdata 	= 32'b0;
                        mem_wmask	= 4'b0;
			mem_rbyte_num	= 2'b0;
		end
	endcase
end

always@(*) begin
	casez({inst[31:25], funct3, opcode})
		//add, R type
		17'b0000000_000_0110011: EXU_mode = 2'b00;
		//addi, lw, lbu, I type
		17'b???????_000_0010011, 17'b???????_010_0000011, 17'b???????_100_0000011:
		       	EXU_mode = 2'b01;
		//sw, sb, S type
		17'b???????_010_0100011, 17'b???????_000_0100011:
			EXU_mode = 2'b01;
		default: EXU_mode = 2'b00;
	endcase
end

always@(*) begin
	case(imm_type) 
		6'b000001: imm = {{20{inst[31]}}, inst[31:20]};			//I-type: sign extension
		6'b000010: imm = {{12{inst[31]}}, inst[31:12]} << 12;		//U-type: sign extension
		6'b000100: imm = {{20{inst[31]}}, {inst[31:25], inst[11:7]}};	//S-type: sign extension
		default: imm = 32'b0;
	endcase	
end

endmodule

