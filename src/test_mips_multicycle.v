`default_nettype none
`timescale 1ns/1ps

module test_mips_multicycle;

//module cli args
integer NUM_CYCLES = 100;
integer DATA_MEM_START;
integer DATA_MEM_STOP;
integer i;
reg [8*100:0] WAVE_FILE;

//declare any parameters for your mips core module


//declare any additional IO for your mips core module
reg  clk, rst;
wire clk_late1;
buf #(1) (clk_late1, clk);
wire rstb;
//assign rstb = ~rst;


//memory
wire [31:0] mem_wr_data0, mem_wr_data1;
wire [31:0] mem_rd_data0, mem_rd_data1, mem_addr0, mem_addr1;
wire mem_wr_ena0, mem_wr_ena1;
wire mem_invalid;

synth_dual_port_memory #(
	.N(32),
	.I_LENGTH(1024),
	.D_LENGTH(1024)
) MEMORY(
	.clk(clk_late1),
	.rstb(rst),
	.wr_ena0(mem_wr_ena0),
	.addr0(mem_addr0),
	.din0(mem_wr_data0),
	.dout0(mem_rd_data0),
	.wr_ena1(mem_wr_ena1),
	.addr1(mem_addr1),
	.din1(mem_wr_data1),
	.dout1(mem_rd_data1)
);

//instantiate your mips core module here

mips_multicycle cpu(
	.mem_rd_data0(mem_rd_data0),
	.mem_rd_data1(mem_rd_data1),
	.mem_wr_ena0(mem_wr_ena0),
	.mem_addr0(mem_addr0),
	.mem_wr_data0(mem_wr_data0),
	.mem_wr_ena1(mem_wr_ena1),
	.mem_addr1(mem_addr1),
	.mem_wr_data1(mem_wr_data1),
	.clk(clk),
	.rstb(rst));

initial begin
	clk = 0;
	rst = 1;
	$display(4'h4);
	if(!$value$plusargs("NUM_CYCLES=%d", NUM_CYCLES)) begin
		$display("defaulting to 1000 cycles");
		NUM_CYCLES = 4000;
	end
	
	repeat (2) @(posedge clk); rst = 0;
	
	repeat (NUM_CYCLES) @(negedge clk); //run the CPU
	$display("simulated %d cycles", NUM_CYCLES);
	
	DATA_MEM_START = 0;
	DATA_MEM_STOP = 256;  //change this to a larger number if you wish to dump the data memory at the end of the program
	if (DATA_MEM_STOP > DATA_MEM_START) begin
		$display("Dumping data memory from address %d -> %d:", DATA_MEM_START, DATA_MEM_STOP);
		
		for (i = DATA_MEM_START; i < DATA_MEM_STOP; i = i + 1) begin
			$display("\tDMEM[%d]=%h", i, MEMORY.DMEM[i]);
		end
	end
	#100;
	$display("	REG[%d] = %b", 0, cpu.regf.r00);
	$display("	REG[%d] = %b", 1, cpu.regf.r01);
	$display("	REG[%d] = %b", 2, cpu.regf.r02);
	$display("	REG[%d] = %b", 3, cpu.regf.r03);
	$display("	REG[%d] = %b", 4, cpu.regf.r04);
	$display("	REG[%d] = %b", 5, cpu.regf.r05);
	$display("	REG[%d] = %b", 6, cpu.regf.r06);
	$display("	REG[%d] = %b", 7, cpu.regf.r07);
	$display("	REG[%d] = %b", 8, cpu.regf.r08);
	$display("	REG[%d] = %b", 9, cpu.regf.r09);
	$display("	REG[%d] = %b", 10, cpu.regf.r10);
	$display("	REG[%d] = %b", 11, cpu.regf.r11);
	$display("	REG[%d] = %b", 12, cpu.regf.r12);
	$display("	REG[%d] = %b", 13, cpu.regf.r13);
	$display("	REG[%d] = %b", 14, cpu.regf.r14);
	$display("	REG[%d] = %b", 15, cpu.regf.r15);
	$display("	REG[%d] = %b", 16, cpu.regf.r16);
	$display("	REG[%d] = %b", 17, cpu.regf.r17);
	$display("	REG[%d] = %b", 18, cpu.regf.r18);
	$display("	REG[%d] = %b", 19, cpu.regf.r19);
	$display("	REG[%d] = %b", 20, cpu.regf.r20);
	$display("	REG[%d] = %b", 21, cpu.regf.r21);
	$display("	REG[%d] = %b", 22, cpu.regf.r22);
	$display("	REG[%d] = %b", 23, cpu.regf.r23);
	$display("	REG[%d] = %b", 24, cpu.regf.r24);
	$display("	REG[%d] = %b", 25, cpu.regf.r25);
	$display("	REG[%d] = %b", 26, cpu.regf.r26);
	$display("	REG[%d] = %b", 27, cpu.regf.r27);
	$display("	REG[%d] = %b", 28, cpu.regf.r28);
	$display("	REG[%d] = %b", 29, cpu.regf.r29);
	$display("	REG[%d] = %b", 30, cpu.regf.r30);
	$display("	REG[%d] = %b", 31, cpu.regf.r31);
	
	
	$finish;
end

always #5 clk = ~clk;
endmodule

`default_nettype wire
