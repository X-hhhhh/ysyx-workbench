module universal_adder
#(
	parameter	DATAWIDTH = 32
)
(
	input	wire	[DATAWIDTH - 1:0] a,
	input	wire	[DATAWIDTH - 1:0] b,
	
	output	wire	[DATAWIDTH - 1:0] out,
	output	wire			  carry
);

assign {carry, out} = a + b;

endmodule

