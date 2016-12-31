`timescale 1ns / 1ps
`default_nettype none //helps catch typo-related bugs
//////////////////////////////////////////////////////////////////////////////////
// 
// CS 141 - Fall 2016
// Module Name:    mips_multicycle 
// Author(s): 
// Description: 
//
//
//////////////////////////////////////////////////////////////////////////////////
`include "alu_defines.v"
`include "mips_op_defines.v"
`include "mips_r_fun_defines.v"
`include "mips_memory_space_defines.v"
module mips_multicycle(mem_rd_data0,mem_rd_data1,mem_wr_ena0,mem_addr0,mem_wr_data0,mem_wr_ena1,mem_addr1,mem_wr_data1,clk,rstb);

	//parameter definitions
	parameter N = 32;
	parameter TODO = 0;
	//port definitions - customize for different bit widths
	input  wire [N-1:0] mem_rd_data0;
	input  wire [N-1:0] mem_rd_data1;
	output wire mem_wr_ena0;
	output wire [N-1:0] mem_addr0;
	output wire [N-1:0] mem_wr_data0;
	output wire mem_wr_ena1;
	output wire [N-1:0] mem_addr1;
	output wire [N-1:0] mem_wr_data1;
	input  wire clk;
	input  wire rstb;
	
	wire clk_late1;
	buf #(1) (clk_late1, clk);

	reg [N-1:0] PC, IR, MDR, A, B, ALUout;
	initial PC = {`I_START_ADDRESS, {20{1'b0}}};
	initial IR = {`MIPS_R_SLL, {26{1'b0}}};
	
	wire [5:0] op, funct;
	wire [4:0] rs, rt, rd, shamt;
	wire [15:0] imm;
	wire [25:0] addr;
	
	assign op = IR[31:26];
	assign rs = IR[25:21];
	assign rt = IR[20:16];
	assign rd = IR[15:11];
	assign shamt = IR[10:6];
	assign funct = IR[5:0];
	assign imm = IR[15:0];
	assign addr = IR[25:0];
	// need a mux here later
	assign mem_addr0 = PC;
	
	reg PCWriteCond, PCWrite, IorD, MemRead, MemWrite,
		IRWrite, RegWrite, EQ;
	reg [1:0] MemtoReg, PCSource, ALUOp, ALUSrcA, RegDst;
	reg [2:0] ALUSrcB;
	
	initial PCWrite = 1;
	initial IRWrite = 1;
	
	reg [4:0] state = 0;
	wire [4:0] reg_rd_addr0, reg_rd_addr1, reg_wr_addr;
	wire [N-1:0] reg_rd_data0,
		reg_rd_data1, reg_wr_data,
		ALUin0, ALUin1, ALUoutwire,
		sgnex, sgnex_sh2, sgnex_shamt,
		eqcond;
	reg [`ALU_OP_WIDTH-1:0] ALUop_code;
	wire ALUequal, ALUzero, ALUoverflow;
	wire [N-1:0] PCin;
	wire [N-1:0] jtarget;
	
	assign eqcond = EQ ^ ALUzero;
	assign jtarget[31:20] = `I_START_ADDRESS;
	assign jtarget[19:2] = addr[17:0];
	assign jtarget[1:0] = 0;
	assign PCin =
		PCSource[1]?
			(PCSource[0]? A: jtarget):
			(PCSource[0]? ALUout: ALUoutwire);
			
	
	register_file #(.N(32)) regf (
		.clk(clk_late1),
		.rst(rstb),
		.rd_addr0(reg_rd_addr0),
		.rd_addr1(reg_rd_addr1),
		.wr_addr(reg_wr_addr),
		.rd_data0(reg_rd_data0),
		.rd_data1(reg_rd_data1),
		.wr_data(reg_wr_data),
		.wr_ena(RegWrite)
	);
	
	
	assign reg_rd_addr0 = rs;
	assign reg_rd_addr1 = rt;
	assign reg_wr_addr = RegDst[1]? 31 : (RegDst[0]? rd: rt);
	assign reg_wr_data = 
		MemtoReg[1]?
			PC:
			MemtoReg[0]? MDR: ALUout;

	assign sgnex = {{16{IR[15]}}, imm};
	assign sgnex_sh2 = sgnex << 2;
	assign sgnex_shamt = {{26{1'b0}}, shamt};
	assign ALUin0 = 
		ALUSrcA[1]? 
			B:
			(ALUSrcA[0]?
				A: PC);
	assign ALUin1 =
		ALUSrcB[2]?
			sgnex_shamt:
			ALUSrcB[1]?
				(ALUSrcB[0]? sgnex_sh2 : sgnex ):
				(ALUSrcB[0]? 4: B);
				
	assign mem_wr_data1 = B;
	assign mem_addr1 = ALUout;
	assign mem_wr_ena1 = MemWrite;
	
	alu #(.N(32)) ALU (
		.x(ALUin0), .y(ALUin1),
		.op_code(ALUop_code), .z(ALUoutwire),
		.equal(ALUequal), .zero(ALUzero), .overflow(ALUoverflow)
	);
	always @(*) begin
		// ALU
		case (ALUOp)
			2'b00: begin
				ALUop_code <= `ALU_OP_ADD;
				end
			2'b01: begin
				ALUop_code <= `ALU_OP_SUB;
				end
			2'b10: begin
				case (funct)
					`MIPS_R_AND: begin
						ALUop_code <= `ALU_OP_AND;
						end
					`MIPS_R_OR: begin
						ALUop_code <= `ALU_OP_OR;
						end
					`MIPS_R_XOR: begin
						ALUop_code <= `ALU_OP_XOR;
						end
					`MIPS_R_NOR: begin
						ALUop_code <= `ALU_OP_NOR;
						end
					`MIPS_R_SLL: begin
						ALUop_code <= `ALU_OP_SLL;
						end
					`MIPS_R_SRL: begin
						ALUop_code <= `ALU_OP_SRL;
						end
					`MIPS_R_SRA: begin
						ALUop_code <= `ALU_OP_SRA;
						end
					`MIPS_R_SLT: begin
						ALUop_code <= `ALU_OP_SLT;
						end
					`MIPS_R_ADD: begin
						ALUop_code <= `ALU_OP_ADD;
						end
					`MIPS_R_SUB: begin
						ALUop_code <= `ALU_OP_SUB;
						end
				endcase
				end
			2'b11: begin
				case (op)
					`MIPS_OP_ADDI: begin
						ALUop_code <= `ALU_OP_ADD;
					end
					`MIPS_OP_SLTI: begin
						ALUop_code <= `ALU_OP_SLT;
					end
					`MIPS_OP_ANDI: begin
						ALUop_code <= `ALU_OP_AND;
					end
					`MIPS_OP_ORI: begin
						ALUop_code <= `ALU_OP_OR;
					end
					`MIPS_OP_XORI: begin
						ALUop_code <= `ALU_OP_XOR;
					end
				endcase
				end
		endcase
	end
	always @(posedge clk_late1) begin
		A <= reg_rd_data0;
		B = reg_rd_data1;
		if (IRWrite)
			IR <= mem_rd_data0;
		MDR <= mem_rd_data1;
		ALUout <= ALUoutwire;
		if (PCWrite || PCWriteCond && eqcond)
			PC <= PCin;
	end
//	always @(posedge rstb) begin
//		if (rstb) begin
//			state <= 0;
//		end
//	end
	
	
	always @(posedge clk) begin
		if (rstb) begin
			PC <= {`I_START_ADDRESS, {20{1'b0}}};
			{IR, MDR, A, B, ALUout} <= 0;
			{PCWriteCond, PCWrite, IorD, MemRead, MemWrite,
			MemtoReg, IRWrite, RegDst, RegWrite, ALUSrcA,
			ALUSrcB, PCSource, ALUOp, ALUop_code} <= 0;
			state <= 0;
		end
		case (state)
			0: begin // default
				{MemWrite, RegWrite} <= 0;
				IorD <= 0;
				MemRead <= 1;
				PCWrite <= 1;
				ALUSrcA <= 0;
				ALUSrcB <= 3'b001;
				PCSource <= 0;
				ALUOp <= 0;
				PCWriteCond <= 0;
				state <= 10; // 10 in decimal
			end
			10: begin // wait for read after 0
				{PCWrite, MemWrite, RegWrite} <= 0;
				//PCSource <= 0;
				IRWrite <= 1;
				state <= 1;
			end
			1: begin
				{PCWrite, IRWrite, MemWrite, RegWrite} <= 0;
				ALUSrcA <= 0;
				ALUSrcB <= 3'b011;
				ALUOp <= 0;
				PCWriteCond <= 0;
				if (op == `MIPS_OP_R)
					if ((funct == `MIPS_R_SLL) ||
						(funct == `MIPS_R_SRL) ||
						(funct == `MIPS_R_SRA))
						state <= 11;
					else if (funct == `MIPS_R_JR)
						state <= 15;
					else
						state <= 6;
				else if ((op == `MIPS_OP_ADDI) ||
							(op == `MIPS_OP_ANDI) ||
							(op == `MIPS_OP_ORI) ||
							(op == `MIPS_OP_XORI) ||
							(op == `MIPS_OP_SLTI))
					state <= 12;
				else if (op == `MIPS_OP_LW ||
							op == `MIPS_OP_SW)
					state <= 2;
				else if (op == `MIPS_OP_J)
					state <= 9;
				else if (op == `MIPS_OP_JAL)
					state <= 16;
				else if (op == `MIPS_OP_BEQ)
					state <= 8;
				else if (op == `MIPS_OP_BNE)
					state <= 17;
			end
			8: begin
				{PCWrite, IRWrite, MemWrite, RegWrite} <= 0;
				ALUSrcA <= 1;
				ALUSrcB <= 0;
				ALUOp <= 1;
				PCSource <= 1;
				PCWriteCond <= 1;
				EQ <= 0;
				state <= 0;
			end
			17: begin
				{PCWrite, IRWrite, MemWrite, RegWrite} <= 0;
				ALUSrcA <= 1;
				ALUSrcB <= 0;
				ALUOp <= 1;
				PCSource <= 1;
				PCWriteCond <= 1;
				EQ <= 1;
				state <= 0;
			end
			16: begin
				{IRWrite, MemWrite, RegWrite} <= 0;
				PCSource <= 2;
				PCWrite <= 1;
				RegDst <= 2;
				RegWrite <= 1;
				MemtoReg <= 2;
				ALUSrcA <= 0;
				ALUSrcB <= 1;
				state <= 0;
			end
			15: begin
				{IRWrite, MemWrite, RegWrite} <= 0;
				PCSource <= 3;
				PCWrite <= 1;
				state <= 0;
			end
			9: begin
				{IRWrite, MemWrite, RegWrite} <= 0;
				PCSource <= 2;
				PCWrite <= 1;
				state <= 0;
			end
			2: begin
				{PCWrite, IRWrite, MemWrite, RegWrite} <= 0;
				ALUSrcA <= 1;
				ALUSrcB <= 2;
				ALUOp <= 0;
				PCWriteCond <= 0;
				if (op == `MIPS_OP_LW)
					state <= 3;
				else if (op == `MIPS_OP_SW)
					state <= 5;
			end
			3: begin
				{PCWrite, IRWrite, MemWrite, RegWrite} <= 0;
				MemRead <= 1;
				IorD <= 1;
				PCWriteCond <= 0;
				state <= 14;
			end
			5: begin
				{PCWrite, IRWrite, RegWrite} <= 0;
				MemWrite <= 1;
				IorD <= 1;
				PCWriteCond <= 0;
				state <= 0;
			end
			14: begin
				{PCWrite, IRWrite, MemWrite, RegWrite} <= 0;
				MemRead <= 1;
				state <= 4;
			end
			4: begin
				{PCWrite, IRWrite, MemWrite} <= 0;
				RegDst <= 0;
				RegWrite <= 1;
				MemtoReg <= 1;
				PCWriteCond <= 0;
				state <= 0;
			end
			6: begin
				{PCWrite, IRWrite, MemWrite, RegWrite} <= 0;
				ALUSrcA <= 1;
				ALUSrcB <= 0;
				ALUOp <= 2'b10;
				PCWriteCond <= 0;
				state <= 7;
			end
			12: begin
				{PCWrite, IRWrite, MemWrite, RegWrite} <= 0;
				ALUSrcA <= 1;
				ALUSrcB <= 2;
				ALUOp <= 2'b11;
				PCWriteCond <= 0;
				state <= 13;
			end
			13: begin
				{PCWrite, IRWrite, MemWrite} <= 0;
				RegDst <= 0;
				RegWrite <= 1;
				MemtoReg <= 0;
				PCWriteCond <= 0;
				state <= 0;
			end
			11: begin
				{PCWrite, IRWrite, MemWrite, RegWrite} <= 0;
				ALUSrcA <= 2;
				ALUSrcB <= 3'b100;
				ALUOp <= 2'b10;
				PCWriteCond <= 0;
				state <= 7;
			end
			7: begin
				{PCWrite, IRWrite, MemWrite} <= 0;
				RegDst <= 1;
				RegWrite <= 1;
				MemtoReg <= 0;
				PCWriteCond <= 0;
				state <= 0;
			end
		endcase
	end
endmodule
`default_nettype wire //some Xilinx IP requires that the default_nettype be set to wire
