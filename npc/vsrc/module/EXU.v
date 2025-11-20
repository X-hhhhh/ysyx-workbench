module 	EXU(
	input	wire	[31:0]	gpr_rdata1_in,
	input	wire	[31:0]	gpr_rdata2_in,
	input	wire	[31:0]	imm,
	input	wire	[1:0]	EXU_mode, 	//bit[0]:0 for src1 and src2, 1 for src and imm, bit[1]: 0 for add, 1 for sub

	output	wire	[31:0]	EXU_data
);

reg	[31:0]	a;
reg	[31:0]	b;

always@(*) begin
	case(EXU_mode)
		2'b00: begin
			a = gpr_rdata1_in;
			b = gpr_rdata2_in;
		end
		2'b01: begin
			a = gpr_rdata1_in;
			b = imm;
		end
		default: begin 
			a = 32'b0;
			b = 32'b0;
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
	.out(EXU_data)
);

endmodule

