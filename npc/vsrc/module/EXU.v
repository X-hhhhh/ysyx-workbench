module 	EXU(
	input	wire	[31:0]	gpr_rdata1_in,
	input	wire	[31:0]	gpr_rdata2_in,
	input	wire	[31:0]	imm,
	input	wire	[1:0]	EXU_mode,

	output	reg	[31:0]	EXU_data
);

always@(*) begin
	case(EXU_mode)
		2'b00: EXU_data = gpr_rdata1_in + gpr_rdata2_in; 
		2'b01: EXU_data = gpr_rdata1_in + imm;
		default: EXU_data = 32'b0;
	endcase
end

endmodule

