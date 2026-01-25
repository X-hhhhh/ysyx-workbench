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
	input	wire				exu_valid,
	input	wire				wbu_ready,

	output	reg		[31:0]		rdata,
	//signals between cpu modules
	output	reg					lsu_valid,
	output	reg					lsu_ready,
	//signals bwtween cpu and memory
	input	wire	[31:0]		lsu_rdata,
	input	wire				lsu_respValid,
	input	wire				lsu_reqReady,

	output	reg		[31:0]		lsu_addr,
	output	reg		[31:0]		lsu_wdata,
	output	reg					lsu_wen,
	output	reg		[3:0]		lsu_wmask,
	output	reg					lsu_reqValid,
	output	reg					lsu_respReady
);

parameter 	IDLE 			= 3'b001,
			WAIT_REQREADY	= 3'b010,
			WAIT_READY		= 3'b100;

reg	[2:0]	lsu_state;
reg	[31:0]	pmem_read_data0;
reg	[31:0]	pmem_read_data1;

reg			rw_across;			//this means to read or write memory 2 times(across words)

assign lsu_ready = (lsu_state == IDLE);

assign lsu_respReady = (lsu_state == WAIT_READY);

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		lsu_valid <= 1'b0;
	end else if(lsu_state == WAIT_READY && lsu_respValid && wbu_ready) begin
		lsu_valid <= 1'b1;
	end else begin
		lsu_valid <= 1'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		rw_across <= 1'b0;
	end else begin
		case(lsu_state)
			IDLE:
				if(exu_valid) begin
					//below 2 situations need to access memory 2 times
					if(rbyte_num == 2'b01 && raddr[1:0] == 2'b11 || wmask == 4'b1001) begin
						rw_across <= 1'b1;
					end
				end
			WAIT_READY:
				if(lsu_respValid) begin
					if(rw_across == 1'b1) begin
						rw_across <= 1'b0;
					end
				end
			default: rw_across <= rw_across;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		lsu_state <= IDLE;
	end else begin
		case(lsu_state)
			IDLE: 
				if(exu_valid) begin
					lsu_state <= WAIT_REQREADY;
				end
			WAIT_REQREADY:
				if(lsu_reqReady) begin
					lsu_state <= WAIT_READY;
				end
			WAIT_READY:
				if(lsu_respValid) begin
					if(rw_across) begin
						// r/w the second time, switch to WAIT_REQREADY and wait
						// for reqready signal
						lsu_state <= WAIT_REQREADY;
					end else if(wbu_ready) begin
						lsu_state <= IDLE;
					end
				end
			default: lsu_state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		pmem_read_data0 <= 32'b0;
		pmem_read_data1 <= 32'b0;
	end	else if(lsu_state == WAIT_READY && lsu_respValid) begin
		if(!rw_across) begin
			pmem_read_data0 <= lsu_rdata;
		end else begin
			pmem_read_data1 <= lsu_rdata;
		end
	end
end

always@(*) begin
	if(valid == 1'b1) begin 	//if valid is 1, output the read data
		case(rbyte_num)			//00: 1byte, 01: 2bytes, 10: 4bytes, 11: 8bytes
			2'b00: rdata = (pmem_read_data0 >> ((raddr & 32'h3) << 3)) & 32'hFF;
			2'b01: 
				if(raddr[1:0] == 2'b11) begin
					//Need to read across bytes
					rdata = {16'b0, pmem_read_data0[7:0], pmem_read_data1[31:24]};
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

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		lsu_addr 	<= 32'h80000000;
		lsu_wdata 	<= 32'b0;
		lsu_wen		<= 1'b0;
		lsu_reqValid <= 1'b0;
		lsu_wmask	<= 4'b0;
	end else if(lsu_state == IDLE && exu_valid) begin
		lsu_reqValid <= 1'b1;
		if(wen) begin		//write memory
			lsu_addr 	<= waddr;
			lsu_wdata 	<= wdata;
			lsu_wen		<= 1'b1;
			lsu_wmask	<= (wmask == 4'b1001) ? 4'b1000 : wmask;
		end else begin		//read memory
			lsu_addr 	<= raddr;
			lsu_wdata 	<= 32'b0;
			lsu_wen		<= 1'b0;
			lsu_wmask	<= 4'b0;
		end
	end else if(lsu_reqValid && rw_across) begin	//set reqvalid to r/w the second time(across word)
		lsu_reqValid <= 1'b1;
		if(wen) begin		//write memory
			lsu_addr 	<= waddr + 4;
			lsu_wdata 	<= wdata;
			lsu_wen		<= 1'b1;
			lsu_wmask	<= 4'b0001;
		end else begin		//read memory
			lsu_addr 	<= raddr + 4;
			lsu_wdata 	<= 32'b0;
			lsu_wen		<= 1'b0;
			lsu_wmask	<= 4'b0;
		end
	end else if(lsu_state == WAIT_REQREADY && lsu_reqReady) begin		//while reqReady is true, ram has received data, set signals invalid
		lsu_reqValid <= 1'b0;
		lsu_addr 	<= 32'h80000000;
		lsu_wdata 	<= 32'b0;
		lsu_wen		<= 1'b0;
		lsu_wmask	<= 4'b0;
	end
end

endmodule

