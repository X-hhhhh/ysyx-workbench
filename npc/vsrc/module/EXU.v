module 	EXU(
	input	wire	[31:0]	gpr_rdata1_in,
	input	wire	[31:0]	gpr_rdata2_in,
	input	wire	[31:0]	imm,
	
	//bit[0]:0 for src1 and src2, 1 for src and imm, bit[1]: 0 for add, 1 for sub
	//bit[2]:1 for unsigned comparation, bit[3]: 1 for signed comparation
	//bit[4]:1 for unsigned shift right, bit[5]:1 for signed shift right 
	//bit[6]:1 for unsigned/signed shift left, bit[7]:1 for logical XOR
	//bit[8]:1 for logical AND, bit[9]:1 for logical OR
	//bit[10]1 for logical NOT
	input	wire	[10:0]	EXU_mode, 	

	output	reg	[31:0]	EXU_data
);

reg	[31:0] 	a;
reg	[31:0] 	b;
reg		mode;
wire	[31:0] 	out;
wire	       	carry;
wire		overflow;

wire	[63:0] 	shift_right;

assign a = gpr_rdata1_in;
assign shift_right = {{32{gpr_rdata1_in[31]}}, gpr_rdata1_in} >> imm;

always@(*) begin
	if(EXU_mode[0] == 1'b0)
		b = gpr_rdata2_in;
	else
		b = imm;
end

always@(*) begin
	case(EXU_mode[10:1])
		10'b00_0000_0000: begin
			mode = 1'b0;
			EXU_data = out;
		end
		10'b00_0000_0001: begin
			mode = 1'b1;
			EXU_data = out;
		end
		10'b00_0000_0010: begin
			//if equal, EXU_data is 0, if a > b, EXU_data is 32'10, if a < b, EXU_data is 32'b100
			mode = 1'b1;
			EXU_data = (out == 32'b0) ? 32'b0 : (carry == 0) ? 32'b100 : 32'b10;
		end
		10'b00_0000_0100: begin
			//if equal, EXU_data is 0, if a > b, EXU_data is 32'10, if a < b, EXU_data is 32'b100
			mode = 1'b1;
			EXU_data = (out == 32'b0) ? 32'b0 : (out[31] ^ overflow) ? 32'b100: 32'b10;
		end
		10'b00_0001_0000: begin
			mode = 1'b0;
			EXU_data = shift_right[31:0];
		end
		10'b00_0100_0000: begin
			mode = 1'b0;
			EXU_data = gpr_rdata1_in ^ gpr_rdata2_in;
		end
		10'b00_1000_0000: begin
			mode = 1'b0;
			EXU_data = gpr_rdata1_in & gpr_rdata2_in;
		end
		default: begin 
			mode = 1'b0;
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
	.mode(mode),
	.out(out),
	.carry(carry),
	.overflow(overflow)
);

endmodule

