module ALU
#(
	parameter	DATA_WIDTH = 32
)
(
	input	wire	[DATA_WIDTH - 1:0]	a,
	input	wire	[DATA_WIDTH - 1:0]	b,
	input	wire				mode,	//0:add, 1:sub
	
	output	reg	[DATA_WIDTH - 1:0]	res,
	output	reg				carry,
	output	reg
)
