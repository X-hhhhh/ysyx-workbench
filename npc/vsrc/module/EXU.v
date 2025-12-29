module 	EXU(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input	wire	[31:0]	gpr_rdata1_in,
	input	wire	[31:0]	gpr_rdata2_in,
	input	wire	[31:0]	csr_rdata_in,
	input	wire	[31:0]	imm,
	
	//bit[0]: 0 for src1 and src2(default), 1 for src1 and imm, bit[1]: 0 for add, 1 for sub
	//bit[2]: 1 for unsigned comparation, bit[3]: 1 for signed comparation
	//bit[4]: 1 for unsigned shift right, bit[5]: 1 for signed shift right 
	//bit[6]: 1 for unsigned/signed shift left, bit[7]: 1 for logical XOR
	//bit[8]: 1 for logical AND, bit[9]: 1 for logical OR
	//bit[10]: 1 for logical NOT, bit[11]: 1 for src1 and csr
	//bit[12]: 1 for imm and csr
	input	wire	[12:0]	EXU_mode, 	

	input	wire			idu_valid,
	input	wire			lsu_ready,

	output	reg		[31:0]	EXU_data,
	output	reg				exu_valid,
	output	reg				exu_ready
);

parameter	IDLE 		= 2'b01,
			WAIT_READY	= 2'b10;

reg		[1:0]	exu_state;

reg 	[31:0] 	a;
reg		[31:0] 	b;
reg				mode;
reg		[31:0]	out;
wire	[31:0] 	adder_out;
wire	       	carry;
wire			overflow;

wire	[63:0] 	signed_shift_right;

assign exu_valid = (exu_state == WAIT_READY);
assign exu_ready = (exu_state != WAIT_READY);

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		exu_state <= IDLE;
	end else begin
		case(exu_state)
			IDLE:
				if(idu_valid) begin
					exu_state <= WAIT_READY;
				end	
			WAIT_READY:
				if(lsu_ready) begin
					exu_state <= IDLE;
				end
			default: begin
					exu_state <= IDLE;
				end
		endcase
	end
end

assign signed_shift_right = {{32{gpr_rdata1_in[31]}}, gpr_rdata1_in} >> b[4:0];	//only the low 5 bits of b is valid while shifting

always@(*) begin
	if(EXU_mode[11] == 1'b1) begin
		a = gpr_rdata1_in;
		b = csr_rdata_in;	
	end else if(EXU_mode[12] == 1'b1) begin
		a = csr_rdata_in;
		b = imm;
	end else if(EXU_mode[0] == 1'b0) begin
		a = gpr_rdata1_in;
		b = gpr_rdata2_in;
	end else begin
		a = gpr_rdata1_in;
		b = imm;
	end
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
		10'b00_0000_1000: begin
			mode = 1'b0;
			EXU_data = a >> b[4:0];
		end
		10'b00_0001_0000: begin
			mode = 1'b0;
			EXU_data = signed_shift_right[31:0];
		end
		10'b00_0010_0000: begin
			mode = 1'b0;
			EXU_data = a << b[4:0];
		end
		10'b00_0100_0000: begin
			mode = 1'b0;
			EXU_data = a ^ b;
		end
		10'b00_1000_0000: begin
			mode = 1'b0;
			EXU_data = a & b;
		end
		10'b01_0000_0000: begin
			mode = 1'b0;
			EXU_data = a | b;
		end
		default: begin 
			mode = 1'b0;
			EXU_data = 32'b0;
		end
	endcase
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		out <= 32'b0;
	end else if(exu_state == IDLE && idu_valid) begin
		out <= adder_out;
	end
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
	.out(adder_out),
	.carry(carry),
	.overflow(overflow)
);

endmodule

