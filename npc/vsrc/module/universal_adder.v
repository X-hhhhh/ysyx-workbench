module universal_adder
#(
	parameter	DATAWIDTH = 32
)
(
	input	wire	[DATAWIDTH - 1:0] 	a,
	input	wire	[DATAWIDTH - 1:0] 	b,
	input	wire				mode,	//0:add, 1:sub
						
	output	wire	[DATAWIDTH - 1:0] 	out,
	output	wire			  	carry,
	output	wire				overflow
);

wire	[DATAWIDTH - 1:0]	b_1comp;

assign 	b_1comp = {DATAWIDTH{mode}} ^ b;	//complement of 1
assign {carry, out} = a + b + mode;
assign overflow = (a[DATAWIDTH-1] == b_1comp[DATAWIDTH-1]) && (out[DATAWIDTH-1] != a[DATAWIDTH-1]);

endmodule

