module	ram
#(
	parameter	ADDR_SIZE = 12,
			DATA_SIZE = 32
)
(
	input	wire				sys_clk,
	input	wire	[ADDR_SIZE - 1:0]	raddr,
	input	wire	[ADDR_SIZE - 1:0]	waddr,
	input	wire	[DATA_SIZE - 1:0]	wdata,
	input	wire				wen,

	output	wire	[DATA_SIZE - 1:0]	rdata
);

reg	[DATA_SIZE - 1:0] 	mem	[(1 << ADDR_SIZE - 1):0];

assign rdata = mem[raddr];

always@(posedge sys_clk) begin
	if(wen == 1'b1)
		mem[waddr]  <= wdata;
end

endmodule

