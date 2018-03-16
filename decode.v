module decode(instr, immSize, RegDest, imm, RegData1, RegData2);
	input [15:0] instr;
	output [15:0] imm, RegData1, RegData2;

	wire [3:0] ReadReg2;

	assign imm = (ImmSize == 2'b00) ? {{12{instr[3]}}, instr[3:0]} :
				 (ImmSize == 2'b01) ? {{8{instr[7]}}, instr[7:0]} :
							  		  {{7{instr[8]}}, instr[8:0]};

	assign ReadReg2 = RegDest ? instr[11:8] : instr[3:0];

	RegisterFile Regs(.clk(clk), .rst(rst), .SrcReg1(instr[7:4]),
		.SrcReg2(instr[3:0]), .DstReg(instr[11:8]), .WriteReg(RegWrite),
		.DstData(WriteData), .SrcData1(RegData1), .SrcData2(RegData2));

endmodule
