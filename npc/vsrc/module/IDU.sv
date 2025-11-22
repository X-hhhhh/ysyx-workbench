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
	output	reg	[10:0]		EXU_mode,	//bit[0]: 0 for rs1 and rs2, 1 for rs1 and imm, bit[1]: 0 for add, 1 for sub
	output	reg			mem_valid,
	output	reg			mem_wen,
	output	reg	[31:0]		mem_raddr,
	output	reg	[31:0]		mem_waddr,
	output	reg	[31:0]		mem_wdata,
	output	reg	[3:0]		mem_wmask,
	output	reg	[1:0]		mem_rbyte_num	//the num of bytes when reading memory, 00: 1byte, 01: 2bytes, 10: 4bytes, 11: 8bytes
);

import "DPI-C" context function void npc_trap();

parameter	IMM_I 		= 6'b000001,
		IMM_U 		= 6'b000010,
		IMM_S 		= 6'b000100,
		IMM_B 		= 6'b001000,
		IMM_J 		= 6'b010000,
		IMM_SHAMT 	= 6'b100000;

parameter	EXU_SRC_SRC 	= 11'b000_0000_0000,
		EXU_SRC_IMM 	= 11'b000_0000_0001,
		EXU_ADD 	= 11'b000_0000_0000,
		EXU_SUB		= 11'b000_0000_0010,
		EXU_UNSCMP	= 11'b000_0000_0100,
		EXU_SCMP	= 11'b000_0000_1000,
		EXU_UNSSR	= 11'b000_0001_0000,
		EXU_SSR		= 11'b000_0010_0000,
		EXU_SL		= 11'b000_0100_0000,
		EXU_XOR		= 11'b000_1000_0000,
		EXU_AND		= 11'b001_0000_0000,
		EXU_OR		= 11'b010_0000_0000,
		EXU_NOT		= 11'b100_0000_0000;

wire	[6:0]	opcode;
wire	[2:0]	funct3;
wire	[6:0]	funct7;
wire	[4:0]	rd;
wire	[4:0]	rs1;
wire	[4:0]	rs2;

/* verilator lint_off UNOPTFLAT */
reg	[5:0]	imm_type;
/* verilator lint_on UNOPTFLAT */

assign opcode 	= inst[6:0];
assign funct3 	= inst[14:12];
assign funct7	= inst[31:25];
assign rd 	= inst[11:7];
assign rs1	= inst[19:15];
assign rs2	= inst[24:20];

always@(*) begin
	casez({funct7, funct3, opcode})
		//addi, I type
		17'b???????_000_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//jalr, I type
		17'b???????_000_1100111: begin 
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= pc + 4;
			imm_type	= IMM_I;
			pc_wen 		= 1'b1;
			pc_wdata 	= (gpr_rdata1_in + imm) & 32'hFFFFFFFE;
		end
		//lw, I type
		17'b???????_010_0000011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= mem_rdata;
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//lb, I type
		17'b???????_000_0000011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= {{24{mem_rdata[7]}}, mem_rdata[7:0]};
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//lbu, I type
		17'b???????_100_0000011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= mem_rdata;
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//lh, I type
		17'b???????_001_0000011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= {{16{mem_rdata[15]}}, mem_rdata[15:0]};
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//lhu, I type
		17'b???????_101_0000011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= {16'b0, mem_rdata[15:0]};
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//sltiu, I type
		17'b???????_011_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= (EXU_data == 32'b100) ? 32'b1 : 32'b0;
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//slti, I type
		17'b???????_010_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= (EXU_data == 32'b100) ? 32'b1 : 32'b0;
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//srai, I type
		17'b010000?_101_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= IMM_SHAMT;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//sll, I type
		17'b0000000_001_0110011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//slli, I type
		17'b0000000_001_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//srli, I type
		17'b0000000_101_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= IMM_SHAMT;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//xori, I type
		17'b???????_100_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//ori, I type
		17'b???????_110_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//andi, I type
		17'b???????_111_0010011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= IMM_I;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//sltu, R type
		17'b0000000_011_0110011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= (EXU_data == 32'b100) ? 32'b1 : 32'b0;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//slt, R type
		17'b0000000_010_0110011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= (EXU_data == 32'b100) ? 32'b1 : 32'b0;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//sra, R type
		17'b0100000_101_0110011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		//srl, R type
		17'b0000000_101_0110011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2 	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata 	= 32'b0;	
		end
		17'b0000000_000_0110011: begin
		//add, R type
			gpr_raddr1 	= rs1;	
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//sub, R type
		17'b0100000_000_0110011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//xor, R type
		17'b0000000_100_0110011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//or, R type
		17'b0000000_110_0110011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//and, R type
		17'b0000000_111_0110011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= EXU_data;
			imm_type	= 6'b0;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//lui, U type
		17'b???????_???_0110111: begin
			gpr_raddr1 	= 5'b0;
			gpr_raddr2	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= imm;
			imm_type	= IMM_U;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//auipc, U type
		17'b???????_???_0010111: begin
			gpr_raddr1 	= 5'b0;
			gpr_raddr2	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= pc + imm;
			imm_type	= IMM_U;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//sw, S type
		17'b???????_010_0100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= IMM_S;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//sh, S type
		17'b???????_001_0100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= IMM_S;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		//sb, S type
		17'b???????_000_0100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= IMM_S;
			pc_wen 		= 1'b0;
			pc_wdata	= 32'b0;
		end
		17'b0000000_000_1110011: begin
			case(inst) 
				//ebreak
				32'h00100073: begin
					npc_trap();
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
		//bne, B type
		17'b???????_001_1100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= IMM_B;
			pc_wen 		= (EXU_data == 32'b0) ? 1'b0 : 1'b1;
			pc_wdata	= (EXU_data == 32'b0) ? 32'b0 : pc + imm;
		end
		//beq, B type
		17'b???????_000_1100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= IMM_B;
			pc_wen 		= (EXU_data == 32'b0) ? 1'b1 : 1'b0;
			pc_wdata	= (EXU_data == 32'b0) ? pc + imm : 32'b0;
		end
		//bge, B type
		17'b???????_101_1100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= IMM_B;
			pc_wen 		= (EXU_data == 32'b100) ? 1'b0 : 1'b1;
			pc_wdata	= (EXU_data == 32'b100) ? 32'b0 : pc + imm;
		end
		//bgeu, B type
		17'b???????_111_1100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= IMM_B;
			pc_wen 		= (EXU_data == 32'b100) ? 1'b0 : 1'b1;
			pc_wdata	= (EXU_data == 32'b100) ? 32'b0 : pc + imm;
		end
		//bltu, B type
		17'b???????_110_1100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= IMM_B;
			pc_wen 		= (EXU_data == 32'b100) ? 1'b1 : 1'b0;
			pc_wdata	= (EXU_data == 32'b100) ? pc + imm : 32'b0;
		end
		//blt, B type
		17'b???????_100_1100011: begin
			gpr_raddr1 	= rs1;
			gpr_raddr2	= rs2;
			gpr_wen 	= 1'b0;
			gpr_waddr	= 5'b0;
			gpr_wdata	= 32'b0;
			imm_type	= IMM_B;
			pc_wen 		= (EXU_data == 32'b100) ? 1'b1 : 1'b0;
			pc_wdata	= (EXU_data == 32'b100) ? pc + imm : 32'b0;
		end
		//jal, J type
		17'b???????_???_1101111: begin
			gpr_raddr1 	= 5'b0;
			gpr_raddr2	= 5'b0;
			gpr_wen 	= 1'b1;
			gpr_waddr	= rd;
			gpr_wdata	= pc + 4;
			imm_type	= IMM_J;
			pc_wen 		= 1'b1;
			pc_wdata	= pc + imm;
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
		//lb, I type
		10'b000_0000011: begin
			mem_valid 	= 1'b1;
                        mem_wen		= 1'b0;
                        mem_raddr 	= EXU_data;
                        mem_waddr	= 32'b0;
                        mem_wdata 	= 32'b0;
                        mem_wmask	= 4'b0;
			mem_rbyte_num	= 2'b00;	//1byte
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
		//lh, I type
		10'b001_0000011: begin
			mem_valid 	= 1'b1;
                        mem_wen		= 1'b0;
                        mem_raddr 	= EXU_data;
                        mem_waddr	= 32'b0;
                        mem_wdata 	= 32'b0;
                        mem_wmask	= 4'b0;
			mem_rbyte_num	= 2'b01;	//2bytes
		end
		//lhu, I type
		10'b101_0000011: begin
			mem_valid 	= 1'b1;
                        mem_wen		= 1'b0;
                        mem_raddr 	= EXU_data;
                        mem_waddr	= 32'b0;
                        mem_wdata 	= 32'b0;
                        mem_wmask	= 4'b0;
			mem_rbyte_num	= 2'b01;	//2bytes
		end
		//sw, S type
		10'b010_0100011: begin
			mem_valid 	= 1'b0;
                        mem_wen		= 1'b1;
                        mem_raddr 	= 32'b0;
                        mem_waddr	= EXU_data;
                        mem_wdata 	= gpr_rdata2_in;
                        mem_wmask	= 4'b1111;
			mem_rbyte_num	= 2'b00;	//no need to read
		end
		//sh, S type
		10'b001_0100011: begin
			mem_valid 	= 1'b0;
                        mem_wen		= 1'b1;
                        mem_raddr 	= 32'b0;
                        mem_waddr	= EXU_data;
			if(EXU_data[1:0] == 2'b11) begin
				//Need to write memory for 2 times
				mem_wdata	= {gpr_rdata2_in[7:0], 16'b0, gpr_rdata2_in[15:8]};
				mem_wmask	= 4'b1001;
			end else begin
                        	mem_wdata 	= {16'b0, gpr_rdata2_in[15:0]} << ((EXU_data & 32'h3) << 3);
                        	mem_wmask	= 4'h3 << EXU_data[1:0];
			end
			mem_rbyte_num	= 2'b00;	//no need to read
		end
		//sb, S type
		10'b000_0100011: begin
			mem_valid 	= 1'b0;
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
		//add
		17'b0000000_000_0110011: EXU_mode = EXU_SRC_SRC | EXU_ADD;
		//addi, lw, lbu
		17'b???????_000_0010011, 17'b???????_010_0000011, 17'b???????_100_0000011:
		       	EXU_mode = EXU_SRC_IMM | EXU_ADD;
		//sw, sb, sh, lh, lhu, lb
		17'b???????_010_0100011, 17'b???????_000_0100011, 17'b???????_001_0100011, 17'b???????_001_0000011,
			17'b???????_101_0000011, 17'b???????_000_0000011:
			EXU_mode = EXU_SRC_IMM | EXU_ADD;
		//bne, beq, sltu, bltu, bgeu
		17'b???????_001_1100011, 17'b???????_000_1100011, 17'b0000000_011_0110011, 17'b???????_110_1100011, 17'b???????_111_1100011:
			EXU_mode = EXU_SRC_SRC | EXU_UNSCMP;
		//sltiu
		17'b???????_011_0010011:
			EXU_mode = EXU_SRC_IMM | EXU_UNSCMP;
		//bge, slt, blt
		17'b???????_101_1100011, 17'b0000000_010_0110011, 17'b???????_100_1100011:
			EXU_mode = EXU_SRC_SRC | EXU_SCMP;
		//slti
		17'b???????_010_0010011:
			EXU_mode = EXU_SRC_IMM | EXU_SCMP;
		//sub
		17'b0100000_000_0110011:
			EXU_mode = EXU_SRC_SRC | EXU_SUB;
		//xor
		17'b0000000_100_0110011:
			EXU_mode = EXU_XOR;
		//xori
		17'b???????_100_0010011:
			EXU_mode = EXU_SRC_IMM | EXU_XOR;
		//or
		17'b0000000_110_0110011:
			EXU_mode = EXU_SRC_SRC | EXU_OR;
		//ori
		17'b???????_110_0010011:
			EXU_mode = EXU_SRC_IMM | EXU_OR;
		//and
		17'b0000000_111_0110011:
			EXU_mode = EXU_AND;
		//andi
		17'b???????_111_0010011:
			EXU_mode = EXU_SRC_IMM | EXU_AND;
		//srl
		17'b0000000_101_0110011:
			EXU_mode = EXU_SRC_SRC | EXU_UNSSR;
		//srli
		17'b0000000_101_0010011:
			EXU_mode = EXU_SRC_IMM | EXU_UNSSR;
		//srai
		17'b010000?_101_0010011:
			EXU_mode = EXU_SRC_IMM | EXU_SSR;
		//sra
		17'b0100000_101_0110011:
			EXU_mode = EXU_SRC_SRC | EXU_SSR;
		//sll
		17'b0000000_001_0110011:
			EXU_mode = EXU_SRC_SRC | EXU_SL;
		//slli
		17'b0000000_001_0010011:
			EXU_mode = EXU_SRC_IMM | EXU_SL;
		default: EXU_mode = 11'b0;
	endcase
end

always@(*) begin
	case(imm_type) 
		IMM_I: imm = {{20{inst[31]}}, inst[31:20]};					//I-type
		IMM_U: imm = {{12{inst[31]}}, inst[31:12]} << 12;				//U-type
		IMM_S: imm = {{20{inst[31]}}, {inst[31:25], inst[11:7]}};			//S-type
		IMM_B: imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};		//B-type
		IMM_J: imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};	//J-type
		IMM_SHAMT: imm = {26'b0, inst[25:20]};						//imm for shift
		default: imm = 32'b0;
	endcase	
end

endmodule

