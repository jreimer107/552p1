module decode(clk, rst,  instr, ImmSize, RegSrc, RegWrite, WriteData, imm, RegData1, RegData2);
	input clk, rst;
	input [15:0] instr, WriteData;
	input [1:0] ImmSize;
	input RegSrc, RegWrite;
	output [15:0] imm, RegData1, RegData2;

	wire [3:0] SrcReg1, SrcReg2, DstReg;

	assign SrcReg1 = instr[7:4];
	assign SrcReg2 = RegSrc ? instr[11:8] : instr[3:0];
	assign DstReg = instr[11:8];

	/* ImmSize
	* ImmSize is 00 for 4 bit immedates, sign extend to 16b
	* 01 for 9 bit immediates, sign extend to 16b
	* 10 for LLB, arrange to be lower byte
	* 11 for LHB, arrange to be higher byte.
	*/
	assign imm = (ImmSize == 2'b00) ? {{12{instr[3]}}, instr[3:0]} :
				 (ImmSize == 2'b01) ? {{7{instr[8]}}, instr[8:0]} :
				 (ImmSize == 2'b10)	? {RegData2[15:8], instr[7:0]} :
				  					  {instr[7:0], RegData2[7:0]};



	RegisterFile Regs(.clk(clk), .rst(rst), .SrcReg1(SrcReg1),
		.SrcReg2(SrcReg2), .DstReg(DstReg), .WriteReg(RegWrite),
		.DstData(WriteData), .SrcData1(RegData1), .SrcData2(RegData2));

endmodule
