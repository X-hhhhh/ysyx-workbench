module LSU
(
	input	wire				sys_clk,
	input	wire				sys_rst,
	input	wire	[31:0]		raddr,
	input	wire	[31:0]		waddr,
	input	wire	[31:0]		wdata,
	input	wire	[3:0]		wmask,
	input	wire				valid,
	input	wire				wen,
	input	wire	[1:0]		rbyte_num,

	output	reg		[31:0]		rdata
);

import "DPI-C" function int pmem_read(int paddr);
import "DPI-C" function void pmem_write(int paddr, int wdata, byte wmask);

reg	[31:0]	pmem_read_data0;
reg	[31:0]	pmem_read_data1;

//Descending edge sampling, otherwise there may be issues with the DPI interface
always@(negedge sys_clk) begin
	pmem_read_data0 <= (valid == 1'b1) ? pmem_read(raddr) : 32'b0;
	pmem_read_data1 <= (valid == 1'b1) ? pmem_read(raddr + 4) : 32'b0;
end

always@(*) begin
	if(valid == 1'b1) begin 	//if valid is 1, read memory
		case(rbyte_num)			//00: 1byte, 01: 2bytes, 10: 4bytes, 11: 8bytes
			2'b00: rdata = (pmem_read_data0 >> ((raddr & 32'h3) << 3)) & 32'hFF;
			2'b01: 
				if(raddr[1:0] == 2'b11) begin
					//Need to read across bytes
					rdata = {16'b0, pmem_read_data1[7:0], pmem_read_data0[31:24]};
				end else begin
					rdata = (pmem_read_data0 >> ((raddr & 32'h3) << 3)) & 32'hFFFF;
				end
			2'b10: rdata = pmem_read_data0;
			default: rdata = 32'b0;
		endcase
	end else begin
		rdata = 32'b0;
	end
end

always@(posedge sys_clk) begin
	if(wen == 1'b1) begin
		if(wmask == 4'b1001) begin
			pmem_write(waddr, wdata, 8'h08);
			pmem_write(waddr + 4, wdata, 8'h01);
		end else begin
			pmem_write(waddr, wdata, {4'b0, wmask}); //if wen is 1, write memory	
		end
	end
end

endmodule

