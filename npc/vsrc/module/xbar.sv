module xbar(
	input	wire			sys_clk,
	input	wire			sys_rst,
	//ifu
	input	wire			ifu_axi_arvalid,
	input	wire	[31:0]	ifu_axi_araddr,
	output	reg				ifu_axi_arready,

	input	wire			ifu_axi_rready,
	output	reg		[31:0]	ifu_axi_rdata,
	output	reg		[2:0]	ifu_axi_rresp,
	output	reg				ifu_axi_rvalid,

	input	wire			ifu_axi_awvalid,
	input	wire	[31:0]	ifu_axi_awaddr,
	output	reg				ifu_axi_awready,

	input	wire	[31:0]	ifu_axi_wdata,
	input	wire	[3:0]	ifu_axi_wstrb,
	input	wire			ifu_axi_wvalid,
	output	reg				ifu_axi_wready,

	input	wire			ifu_axi_bready,
	output	reg		[2:0]	ifu_axi_bresp,
	output	reg				ifu_axi_bvalid,
	//lsu
	input	wire			lsu_axi_arvalid,
	input	wire	[31:0]	lsu_axi_araddr,
	output	reg				lsu_axi_arready,

	input	wire			lsu_axi_rready,
	output	reg		[31:0]	lsu_axi_rdata,
	output	reg		[2:0]	lsu_axi_rresp,
	output	reg				lsu_axi_rvalid,

	input	wire			lsu_axi_awvalid,
	input	wire	[31:0]	lsu_axi_awaddr,
	output	reg				lsu_axi_awready,

	input	wire	[31:0]	lsu_axi_wdata,
	input	wire	[3:0]	lsu_axi_wstrb,
	input	wire			lsu_axi_wvalid,
	output	reg				lsu_axi_wready,

	input	wire			lsu_axi_bready,
	output	reg		[2:0]	lsu_axi_bresp,
	output	reg				lsu_axi_bvalid,
	//sram
	input	wire			mem_axi_arready,
	output	reg				mem_axi_arvalid,
	output	reg		[31:0]	mem_axi_araddr,

	input	wire	[31:0]	mem_axi_rdata,
	input	wire	[2:0]	mem_axi_rresp,
	input	wire			mem_axi_rvalid,
	output	reg				mem_axi_rready,

	input	wire			mem_axi_awready,
	output	reg				mem_axi_awvalid,
	output	reg		[31:0]	mem_axi_awaddr,

	input	wire			mem_axi_wready,
	output	reg		[31:0]	mem_axi_wdata,
	output	reg		[3:0]	mem_axi_wstrb,
	output	reg				mem_axi_wvalid,

	input	wire	[2:0]	mem_axi_bresp,
	input	wire			mem_axi_bvalid,
	output	reg				mem_axi_bready,
	//uart
	input	wire			uart_axi_arready,
	output	reg				uart_axi_arvalid,
	output	reg		[31:0]	uart_axi_araddr,

	input	wire	[31:0]	uart_axi_rdata,
	input	wire	[2:0]	uart_axi_rresp,
	input	wire			uart_axi_rvalid,
	output	reg				uart_axi_rready,

	input	wire			uart_axi_awready,
	output	reg				uart_axi_awvalid,
	output	reg		[31:0]	uart_axi_awaddr,

	input	wire			uart_axi_wready,
	output	reg		[31:0]	uart_axi_wdata,
	output	reg		[3:0]	uart_axi_wstrb,
	output	reg				uart_axi_wvalid,

	input	wire	[2:0]	uart_axi_bresp,
	input	wire			uart_axi_bvalid,
	output	reg				uart_axi_bready,
	//clint
	input	wire			clint_axi_arready,
	output	reg				clint_axi_arvalid,
	output	reg		[31:0]	clint_axi_araddr,

	input	wire	[31:0]	clint_axi_rdata,
	input	wire	[2:0]	clint_axi_rresp,
	input	wire			clint_axi_rvalid,
	output	reg				clint_axi_rready,

	input	wire			clint_axi_awready,
	output	reg				clint_axi_awvalid,
	output	reg		[31:0]	clint_axi_awaddr,

	input	wire			clint_axi_wready,
	output	reg		[31:0]	clint_axi_wdata,
	output	reg		[3:0]	clint_axi_wstrb,
	output	reg				clint_axi_wvalid,

	input	wire	[2:0]	clint_axi_bresp,
	input	wire			clint_axi_bvalid,
	output	reg				clint_axi_bready
);

//also define in macro.c
parameter	SRAM_ADDR	= 32'h80000000,
			SRAM_SIZE	= 32'h8000000,
			SERIAL_ADDR	= 32'h10000000,
			SERIAL_SIZE = 32'h40,
			TIMER_ADDR	= 32'h10000000,
			TIMER_SIZE	= 32'h8;

parameter	IFU_ACC 		= 5'b00001,
			LSU_ACC_SRAM 	= 5'b00010,
			LSU_ACC_UART	= 5'b00100,
			LSU_ACC_CLINT	= 5'b01000,
			ADDR_ERROR		= 5'b01000;	

reg		[4:0]	state;

always@(posedge sys_clk or posedge sys_rst) begin
	if(sys_rst) begin
		state <= IFU_ACC;
	end else if(lsu_axi_arvalid || lsu_axi_awvalid || lsu_axi_wvalid) begin
		if((lsu_axi_araddr >= SRAM_ADDR) && (lsu_axi_araddr < SRAM_ADDR + SRAM_SIZE) ||
				(lsu_axi_awaddr >= SRAM_ADDR) && (lsu_axi_awaddr < SRAM_ADDR + SRAM_SIZE)) begin
			state <= LSU_ACC_SRAM;
		end else if((lsu_axi_araddr >= SERIAL_ADDR) && (lsu_axi_araddr < SERIAL_ADDR + SERIAL_SIZE) ||
				(lsu_axi_awaddr >= SERIAL_ADDR) && (lsu_axi_awaddr < SERIAL_ADDR + SERIAL_SIZE)) begin
			state <= LSU_ACC_UART;
		end else if((lsu_axi_araddr >= TIMER_ADDR) && (lsu_axi_araddr < TIMER_ADDR + TIMER_SIZE) ||
				(lsu_axi_awaddr >= TIMER_ADDR) && (lsu_axi_awaddr < TIMER_ADDR + TIMER_SIZE)) begin
			state <= LSU_ACC_CLINT;
		end else begin
			state <= ADDR_ERROR;
		end
	end else if(ifu_axi_arvalid || ifu_axi_awvalid || ifu_axi_wvalid) begin
		if((ifu_axi_araddr >= SRAM_ADDR) && (ifu_axi_araddr < SRAM_ADDR + SRAM_SIZE)) begin
			state <= IFU_ACC;
		end else begin
			state <= ADDR_ERROR;
		end
	end
end

always@(*) begin
	if(state == LSU_ACC_UART) begin
        uart_axi_arvalid 	= lsu_axi_arvalid;
        uart_axi_araddr		= lsu_axi_araddr;
                       
        uart_axi_rready		= lsu_axi_rready;
                       
       	uart_axi_awvalid	= lsu_axi_awvalid;
        uart_axi_awaddr		= lsu_axi_awaddr;
               
        uart_axi_wdata		= lsu_axi_wdata;
        uart_axi_wstrb		= lsu_axi_wstrb;
        uart_axi_wvalid		= lsu_axi_wvalid;

        uart_axi_bready		= lsu_axi_bready;
	end else begin
        uart_axi_arvalid 	= 1'b0;
        uart_axi_araddr		= 32'b0;
                       
        uart_axi_rready		= 1'b0;
                       
       	uart_axi_awvalid	= 1'b0;
        uart_axi_awaddr		= 32'b0;
               
        uart_axi_wdata		= 32'b0;
        uart_axi_wstrb		= 4'b0;
        uart_axi_wvalid		= 1'b0;

        uart_axi_bready		= 1'b0;
	end
end

always@(*) begin
	if(state == LSU_ACC_CLINT) begin
        clint_axi_arvalid 	= lsu_axi_arvalid;
        clint_axi_araddr	= lsu_axi_araddr;
                   
        clint_axi_rready	= lsu_axi_rready;
                   
       	clint_axi_awvalid	= lsu_axi_awvalid;
        clint_axi_awaddr	= lsu_axi_awaddr;
           
        clint_axi_wdata		= lsu_axi_wdata;
        clint_axi_wstrb		= lsu_axi_wstrb;
        clint_axi_wvalid	= lsu_axi_wvalid;

        clint_axi_bready	= lsu_axi_bready;
	end else begin
        clint_axi_arvalid 	= 1'b0;
        clint_axi_araddr	= 32'b0;
                   
        clint_axi_rready	= 1'b0;
                   
       	clint_axi_awvalid	= 1'b0;
        clint_axi_awaddr	= 32'b0;
           
        clint_axi_wdata		= 32'b0;
        clint_axi_wstrb		= 4'b0;
        clint_axi_wvalid	= 1'b0;

        clint_axi_bready	= 1'b0;
	end
end

always@(*) begin
	if(state == IFU_ACC) begin
        mem_axi_arvalid = ifu_axi_arvalid;
        mem_axi_araddr	= ifu_axi_araddr;
                       
        mem_axi_rready	= ifu_axi_rready;
                       
        mem_axi_awvalid	= ifu_axi_awvalid;
        mem_axi_awaddr	= ifu_axi_awaddr;
               
        mem_axi_wdata	= ifu_axi_wdata;
        mem_axi_wstrb	= ifu_axi_wstrb;
        mem_axi_wvalid	= ifu_axi_wvalid;

        mem_axi_bready	= ifu_axi_bready;
	end else if(state == LSU_ACC_SRAM) begin
        mem_axi_arvalid = lsu_axi_arvalid;
        mem_axi_araddr	= lsu_axi_araddr;
                       
        mem_axi_rready	= lsu_axi_rready;
                       
        mem_axi_awvalid	= lsu_axi_awvalid;
        mem_axi_awaddr	= lsu_axi_awaddr;
               
        mem_axi_wdata	= lsu_axi_wdata;
        mem_axi_wstrb	= lsu_axi_wstrb;
        mem_axi_wvalid	= lsu_axi_wvalid;

        mem_axi_bready	= lsu_axi_bready;
	end else begin
        mem_axi_arvalid = 1'b0;
        mem_axi_araddr	= 32'b0;
        mem_axi_rready	= 1'b0;
        mem_axi_awvalid	= 1'b0;
        mem_axi_awaddr	= 32'b0;
        mem_axi_wdata	= 32'b0;
        mem_axi_wstrb	= 4'b0;
        mem_axi_wvalid	= 1'b0;
        mem_axi_bready	= 1'b0;
	end
end

always@(*) begin
	if(state == IFU_ACC) begin						//ifu accesses sram
		ifu_axi_arready	= mem_axi_arready;

        ifu_axi_rdata	= mem_axi_rdata;
        ifu_axi_rresp	= mem_axi_rresp;	
        ifu_axi_rvalid	= mem_axi_rvalid;
                       
        ifu_axi_awready	= mem_axi_awready;
               
        ifu_axi_wready	= mem_axi_wready;

        ifu_axi_bresp	= mem_axi_bresp;
        ifu_axi_bvalid	= mem_axi_bvalid;
	end else if(state == ADDR_ERROR) begin
		ifu_axi_arready	= 1'b0;

        ifu_axi_rdata	= 32'b0;
        ifu_axi_rresp	= 3'b011;		//DECERR
        ifu_axi_rvalid	= 1'b0;
                       
        ifu_axi_awready	= 1'b0;
               
        ifu_axi_wready	= 1'b0;

        ifu_axi_bresp	= 3'b0;
        ifu_axi_bvalid	= 1'b0;
	end else begin
		ifu_axi_arready	= 1'b0;

        ifu_axi_rdata	= 32'b0;
        ifu_axi_rresp	= 3'b0;
        ifu_axi_rvalid	= 1'b0;
                       
        ifu_axi_awready	= 1'b0;
               
        ifu_axi_wready	= 1'b0;

        ifu_axi_bresp	= 3'b0;
        ifu_axi_bvalid	= 1'b0;
	end
end

always@(*) begin
	if(state == LSU_ACC_SRAM) begin					//lsu accesses sram
		lsu_axi_arready	= mem_axi_arready;
                       
        lsu_axi_rdata	= mem_axi_rdata;
        lsu_axi_rresp	= mem_axi_rresp;	
        lsu_axi_rvalid	= mem_axi_rvalid;
                       
        lsu_axi_awready	= mem_axi_awready;
               
        lsu_axi_wready	= mem_axi_wready;

        lsu_axi_bresp	= mem_axi_bresp;
        lsu_axi_bvalid	= mem_axi_bvalid;
	end else if(state == LSU_ACC_UART) begin		//lsu accesses uart
		lsu_axi_arready	= uart_axi_arready;
                       
        lsu_axi_rdata	= uart_axi_rdata;
        lsu_axi_rresp	= uart_axi_rresp;	
        lsu_axi_rvalid	= uart_axi_rvalid;
                       
        lsu_axi_awready	= uart_axi_awready;
               
        lsu_axi_wready	= uart_axi_wready;

        lsu_axi_bresp	= uart_axi_bresp;
        lsu_axi_bvalid	= uart_axi_bvalid;
	end else if(state == LSU_ACC_CLINT) begin		//lsu accesses clint
		lsu_axi_arready	= clint_axi_arready;
                       
        lsu_axi_rdata	= clint_axi_rdata;
        lsu_axi_rresp	= clint_axi_rresp;	
        lsu_axi_rvalid	= clint_axi_rvalid;
                       
        lsu_axi_awready	= clint_axi_awready;
               
        lsu_axi_wready	= clint_axi_wready;

        lsu_axi_bresp	= clint_axi_bresp;
        lsu_axi_bvalid	= clint_axi_bvalid;
	end else if(state == ADDR_ERROR) begin
		lsu_axi_arready = 1'b0;
        lsu_axi_rdata	= 32'b0;
        lsu_axi_rresp	= 3'b011;	//DECERR
		lsu_axi_rvalid  = 1'b0;	
        lsu_axi_awready	= 1'b0;
        lsu_axi_wready	= 1'b0;
        lsu_axi_bresp	= 3'b011;	//DECERR
        lsu_axi_bvalid	= 1'b0;
	end else begin
		lsu_axi_arready = 1'b0;
        lsu_axi_rdata	= 32'b0;
        lsu_axi_rresp	= 3'b0;
		lsu_axi_rvalid  = 1'b0;	
        lsu_axi_awready	= 1'b0;
        lsu_axi_wready	= 1'b0;
        lsu_axi_bresp	= 3'b0;
        lsu_axi_bvalid	= 1'b0;
	end
end

endmodule

