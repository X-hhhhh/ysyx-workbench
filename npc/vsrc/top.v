module top(
	input clk, 
	input rst,

	output reg [15:0] led
);

reg [31:0] count;

always@(posedge clk) begin
	if(rst == 1'b1) begin
		led <= 16'b1;
		count <= 32'd0;
	end
	else begin
		if(count == 32'd0) led <= {led[14:0], led[15]};
		count <= (count >= 32'd5000000) ? 32'b0 : count + 1;
	end
end

endmodule

