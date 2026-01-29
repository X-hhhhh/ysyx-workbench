module LFSR_adv
#(
	parameter	MAX_DELAY 	= 10,
				WIDTH_12  	= 1,
				WIDTH_13  	= 1,
				WIDTH_21  	= 1
)(
	input	wire						sys_clk,
	input	wire						sys_rst,
	input	wire						signal1_1,
	input	wire	[WIDTH_12 - 1:0]	signal1_2,
	input	wire	[WIDTH_13 - 1:0]	signal1_3,
	input	wire						signal2_1,

	output	reg							signal1_1_d,
	output	wire	[WIDTH_12 - 1:0]	signal1_2_d,
	output	wire	[WIDTH_13 - 1:0]	signal1_3_d,
	output	reg		[WIDTH_21 - 1:0]	signal2_1_d
);

import "DPI-C" function int dpi_gettime();

int random_delay1;
int random_delay2;

initial begin
	int cur_time;
	cur_time = dpi_gettime();
	$urandom(cur_time);
	random_delay1 = $urandom_range(0, MAX_DELAY - 1);
	random_delay2 = $urandom_range(0, MAX_DELAY - 1);
end

reg		[MAX_DELAY - 1:0]	 	shift_reg_1;
reg		[WIDTH_12 - 1:0]		signal1_2_reg;
reg		[WIDTH_13 - 1:0]		signal1_3_reg;

reg		[MAX_DELAY - 1:0] 	shift_reg_2;

assign signal1_2_d = signal1_1_d ? signal1_2_reg : 'b0;
assign signal1_3_d = signal1_1_d ? signal1_3_reg : 'b0;

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		signal1_2_reg <= 'b0;
		signal1_3_reg <= 'b0;
	end else if(signal1_1) begin
		signal1_2_reg <= signal1_2;
		signal1_3_reg <= signal1_3;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		signal1_1_d <= 1'b0;
		shift_reg_1 <= 'b0;
	end else begin
		shift_reg_1 <= {shift_reg_1[MAX_DELAY - 2:0], signal1_1};
		signal1_1_d <= shift_reg_1[random_delay1];
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		signal2_1_d <= 1'b0;
		shift_reg_2 <= 'b0;
	end else begin
		shift_reg_2 <= {shift_reg_2[MAX_DELAY - 2:0], signal2_1};
		signal2_1_d <= shift_reg_2[random_delay2];
	end
end

endmodule

