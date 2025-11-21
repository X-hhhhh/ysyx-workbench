module 	EXU(
	input	wire	[31:0]	gpr_rdata1_in,
	input	wire	[31:0]	gpr_rdata2_in,
	input	wire	[31:0]	imm,
	
	//bit[0]:0 for src1 and src2, 1 for src and imm, bit[1]: 0 for add, 1 for sub
	//bit[2]:1 for unisgned comparation, bit[3]: 1 for signed comparation
	input	wire	[3:0]	EXU_mode, 	

	output	reg	[31:0]	EXU_data
);

reg	[31:0] 	a;
reg	[31:0] 	b;
wire	[31:0] 	out;
wire	       	carry;

always@(*) begin
	case(EXU_mode)
		4'b0000: begin
			a = gpr_rdata1_in;
			b = gpr_rdata2_in;
			EXU_data = out;
		end
		4'b0001: begin
			a = gpr_rdata1_in;
			b = imm;
			EXU_data = out;
		end
		4'b0100: begin
			//if equal, EXU_data is 0, if a > b, EXU_data is 32'10, if a < b, EXU_data is 32'b100
			a = gpr_rdata1_in;
			b = ~gpr_rdata2_in + 1'b1;
			EXU_data = (out == 32'b0) ? 32'b0 : (carry == 0) ? 32'b100 : 32'b10;
		end
		default: begin 
			a = 32'b0;
			b = 32'b0;
			EXU_data = 32'b0;
		end
	endcase
end

universal_adder 
#(
	.DATAWIDTH(32)
)
universal_adder_inst
(
	.a(a),
	.b(b),
	.out(out),
	.carry(carry)
);

endmodule

