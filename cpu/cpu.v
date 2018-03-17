//TODO: Remove testing inputs and wiring once testing is completed.
module cpu(clk, rst_n, pc_out, hlt, instr_in, mode);
	input clk, rst_n;
	output [15:0] pc_out;
	output hlt;

	//Testing inputs//
	input [15:0] instr_in;
	input mode;
	////////////////

	wire rst;
	assign rst = ~rst_n;
	wire [15:0] WriteData;

///////////////////////////IF//////////////////////////////////////////////////
	wire [15:0] pc_in, instr_fetch, instr;
	fetch IF(.clk(clk), .rst(rst), .pc_in(pc_in), .pc_out(pc_out), .instr(instr_fetch));

	//Testing wiring//
	assign instr = mode ? instr_in : instr_fetch;
	//////////////

	wire RegSrc, RegWrite, MemRead, MemWrite, ALUSrc;
	wire [1:0] ImmSize, BranchSrc, DataSrc;
 	Control ctrl(.op(instr[15:12]), .RegSrc(RegSrc), .MemRead(MemRead),
  		.MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .hlt(hlt),
		.ImmSize(ImmSize), .BranchSrc(BranchSrc), .DataSrc(DataSrc));
//////////////////////////////////ID///////////////////////////////////////////
	wire [15:0] imm, RegData1, RegData2;
  	decode ID(.clk(clk), .rst(rst), .instr(instr), .ImmSize(ImmSize),
		.RegSrc(RegSrc), .RegWrite(RegWrite), .WriteData(WriteData), .imm(imm),
		.RegData1(RegData1), .RegData2(RegData2));
/////////////////////////////////EX////////////////////////////////////////////
	wire match;
	wire [15:0] alu_out, branch_dest;
	execute EX(.instr(instr), .ALUSrc(ALUSrc), .imm(imm), .RegData1(RegData1),
		.RegData2(RegData2), .pc_out(pc_out), .match(match), .alu_out(alu_out),
		.branch_dest(branch_dest));
//////////////////////////////////////MEM///////////////////////////////////////
  	wire [15:0] mem_out;
  	memory MEM(.clk(clk), .rst(rst), .alu_out(alu_out), .RegData2(RegData2),
	 .MemRead(MemRead), .MemWrite(MemWrite), .mem_out(mem_out));
/////////////////////////////////////WB/////////////////////////////////////////
	writeback WB(.pc_out(pc_out), .alu_out(alu_out), .mem_out(mem_out), .imm(imm),
		.branch_dest(branch_dest), .RegData2(RegData2), .DataSrc(DataSrc),
		.BranchSrc(BranchSrc), .match(match), .WriteData(WriteData),
		.pc_in(pc_in));
endmodule
