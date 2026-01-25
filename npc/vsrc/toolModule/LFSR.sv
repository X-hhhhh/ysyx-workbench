module LFSR(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input	wire			signal1,
	input	wire	[31:0]	signal2,

	output	reg				signal1_delay,
	output	reg		[31:0]	signal2_delay
);

reg				signal1_reg;
reg		[31:0]	signal2_reg;
reg		[31:0]	delay;
reg		[31:0]	cnt;

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		delay <= 32'b0;
	end else if(signal1) begin
		delay <= $urandom_range(1, 10);
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		cnt <= 32'hF;
	end else if(signal1) begin
		cnt <= 32'b0;
	end else begin
		cnt <= cnt + 1'b1;
	end	
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		signal1_reg <= 1'b0;
		signal2_reg <= 32'b0;
	end else if(signal1) begin
		signal1_reg <= signal1;
		signal2_reg <= signal2;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		signal1_delay <= 1'b0;
		signal2_delay <= 32'b0;
	end else if(cnt == delay) begin
		signal1_delay <= signal1_reg;
		signal2_delay <= signal2_reg;
	end else begin
		signal1_delay <= 1'b0;
		signal2_delay <= 32'b0;
	end
end 

endmodule

