module IFU(
	input	wire			sys_clk,
	input	wire			sys_rst,
	input 	wire	[31:0]	pc,
	input	wire			idu_ready,
	input	wire			wbu_inst_end,

	output	reg				ifu_valid,
	output	reg		[31:0]	inst,
	//signals between cpu and rom
	input	wire	[31:0]	ifu_rdata,
	input	wire			ifu_respValid,
	input	wire			ifu_reqReady,

	output	reg		[31:0] 	ifu_raddr,
	output	reg				ifu_reqValid,
	output	wire			ifu_respReady
);

parameter 	IDLE			= 3'b001,		//set raddr status
			WAIT_REQREADY	= 3'b010,		//wait for reqready
			WAIT_READY		= 3'b100;		//wait until idu is ready

export "DPI-C" function dpi_inst_get;
export "DPI-C" function dpi_ifu_state_get;

function int dpi_inst_get();
	return inst;
endfunction

function int dpi_ifu_state_get();
	return {29'b0, ifu_state};
endfunction

reg		[2:0]	ifu_state;
reg				startup;
reg				startup_reg;
wire			startup_rise;

assign startup_rise = startup && ~startup_reg;

assign ifu_respReady = (ifu_state == WAIT_READY);

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		startup <= 1'b0;
		startup_reg <= 1'b0;
	end else begin
		startup <= 1'b1;
		startup_reg <= startup;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst == 1'b1) begin
		ifu_state <= IDLE;
	end else begin
		case(ifu_state)
			IDLE:
				if(wbu_inst_end || startup_rise) begin
					ifu_state <= WAIT_REQREADY;
				end
			WAIT_REQREADY:
				if(ifu_reqReady) begin
					ifu_state <= WAIT_READY;
				end
			WAIT_READY: 
				if(idu_ready && ifu_respValid) begin
					ifu_state <= IDLE;
				end
			default: ifu_state <= IDLE;
		endcase
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		ifu_raddr <= 32'b0;
	end else if(ifu_state == IDLE && (wbu_inst_end || startup_rise)) begin
		ifu_raddr <= pc;
	end else if(ifu_state == WAIT_REQREADY && ifu_reqReady) begin
		//while reqReady is valid, rom has received data, set data invalid
		ifu_raddr <= 32'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		ifu_reqValid <= 1'b0;
	end else if(ifu_state == IDLE && wbu_inst_end || startup_rise) begin
		ifu_reqValid <= 1'b1;
	end else if(ifu_reqReady) begin
		ifu_reqValid <= 1'b0;
	end
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		inst <= 32'h80000000;
	end	else if(ifu_respValid) begin
		inst <= ifu_rdata;
	end 
end

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		ifu_valid <= 1'b0;
	end else if(ifu_state == WAIT_READY && ifu_respValid && idu_ready) begin
		ifu_valid <= 1'b1;
	end else begin
		ifu_valid <= 1'b0;
	end
end

endmodule

