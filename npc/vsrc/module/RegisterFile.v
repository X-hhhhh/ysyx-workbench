module RegisterFile
#(
	parameter	ADDR_WIDTH = 1,
				DATA_WIDTH = 1
)(
	input	wire						clk,
	input	wire	[ADDR_WIDTH - 1:0] 	raddr,
	input	wire	[DATA_WIDTH - 1:0] 	wdata,
	input	wire	[ADDR_WIDTH - 1:0] 	waddr,
	input	wire						wen,

	output	wire	[DATA_WIDTH - 1:0]	rdata			
);

reg		[DATA_WIDTH - 1:0]	rf [2 ** ADDR_WIDTH - 1:0];

always@(posedge clk) begin
	if(wen)
		rf[waddr] <= wdata;
end

endmodule

