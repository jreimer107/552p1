
module cpu(clk, rst, pc, hlt);
	input clk, rst;
	output [15:0] pc;
	output hlt;


	wire [15:0] WriteData;

///////////////////////////IF//////////////////////////////////////////////////
	wire [15:0] pc_in, pc_inc;
	Register PC(.clk(clk), .rst(rst), .D(pc_in), .WriteReg(1'b1),
    	.ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc), .Bitline2());

  	CLA_16bit pc_incrementor(.A(pc), .B(16'h0002), .cin(1'b0), .cout(),
    	.S(pc_inc), .sat(1'b0), .red(1'b0));

  	wire [15:0] instr;
  	memory Imem(.data_out(instr), .data_in(), .addr(pc), .enable(1'b1),
    	.wr(1'b0), .clk(clk), .rst(rst));

	//Control wires
	wire RegDest, MemRead, MemWrite, ALUSrc, RegWrite;
 	wire [1:0] ImmSize, BranchSrc, DataSrc;
 	Control ctrl(.op(instr[15:12]), .RegDest(RegDest), .MemRead(MemRead),
  		.MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite),
		.ImmSize(ImmSize), .BranchSrc(BranchSrc), .DataSrc(DataSrc));
//////////////////////////////////ID///////////////////////////////////////////
  	wire [3:0] ReadReg2;
  	wire [15:0] RegData1, RegData2;
  	wire [15:0] immSE;
  	assign immSE = (ImmSize == 2'b00) ? {{12{instr[3]}}, instr[3:0]} :
  				   (ImmSize == 2'b01) ? {{8{instr[7]}}, instr[7:0]} :
				 					  {{7{instr[8]}}, instr[8:0]};

  	assign ReadReg2 = RegDest ? instr[11:8] : instr[3:0];
  	RegisterFile Regs(.clk(clk), .rst(rst), .SrcReg1(instr[7:4]),
    	.SrcReg2(instr[3:0]), .DstReg(instr[11:8]), .WriteReg(RegWrite),
    	.DstData(WriteData), .SrcData1(RegData1), .SrcData2(RegData2));
/////////////////////////////////EX////////////////////////////////////////////
  	wire [15:0] alu_in, alu_out;
  	wire alu_ovfl;
  	assign alu_in = ALUSrc ? immSE : RegData2;
  	ALU alu(.A(SrcData1), .B(alu_in), .op(ALUOP), .out(alu_out), .ovfl(alu_ovfl));

  	wire [15:0] branch_dest;
  	CLA_16bit branch_adder(.A(pc_inc), .B(immSE << 1), .cin(1'b0), .cout(),
    	.S(branch_dest), .sat(1'b0), .red(1'b0));

  	wire match;
  	CCodeEval ccc(.clk(clk), .rst(rst), .instr(instr), .alu_out(alu_out),
    	.alu_ovfl(alu_ovfl), .match(match));
//////////////////////////////////////MEM///////////////////////////////////////
  	wire [15:0] mem_out;
  	memory DMem(.data_out(mem_out), .data_in(RegData2), .addr(alu_out),
    	.enable(MemRead), .wr(MemWrite), .clk(clk), .rst(rst));
/////////////////////////////////////WB/////////////////////////////////////////
  	assign WriteData = (DataSrc == 2'b00) ? mem_out :
  					   (DataSrc == 2'b1x) ? alu_out :
					 					  	pc;

	assign pc_branch = (~match || BranchSrc == 2'b00) ? pc_inc :
  	 				   (BranchSrc == 2'b01) ? branch_dest :
					 						RegData2;

endmodule
