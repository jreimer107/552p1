module decode(instr, ImmSize, RegSrc, WriteData, imm, RegData1, RegData2);
	input [15:0] instr, WriteData;
	input [1:0] ImmSize;
	input RegSrc;
	output [15:0] imm, RegData1, RegData2;

	wire [3:0] SrcReg1, SrcReg2, DstReg;

	assign SrcReg1 = instr[7:4];
	assign ReadReg2 = RegSrc ? instr[11:8] : instr[3:0];
	assign DstReg = instr[11:8];

	assign imm = (ImmSize == 2'b00) ? {{12{instr[3]}}, instr[3:0]} :
				 (ImmSize == 2'b01) ? {{8{instr[7]}}, instr[7:0]} :
							  		  {{7{instr[8]}}, instr[8:0]};



	RegisterFile Regs(.clk(clk), .rst(rst), .SrcReg1(SrcReg1),
		.SrcReg2(SrcReg2), .DstReg(DstReg), .WriteReg(RegWrite),
		.DstData(WriteData), .SrcData1(RegData1), .SrcData2(RegData2));

endmodule
