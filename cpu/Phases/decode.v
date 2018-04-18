module decode(clk, rst, pcs, DstReg, LdByte, RegSrc, RegWrite, BranchSrc,
	WriteData, imm, RegData1, RegData2, pc_branch);
	input clk, rst;
	input [3:0] DstReg;
	input [15:0] instr, pcs, WriteData;
	input RegSrc, LdByte, RegWrite, BranchSrc;
	output [15:0] RegData1, RegData2, pc_branch;

	wire [3:0] SrcReg1, SrcReg2, DstReg;
	wire [15:0] branch_imm;

	assign SrcReg1 = LdByte ? instr[11:8] : instr[7:4];
	assign SrcReg2 = RegSrc ? instr[11:8] : instr[3:0];

	//Decides between branch targets for B vs BR instrs
	assign pc_branch = BranchSrc ? RegData1 : branch_imm;

	//Adds shifted imm and pc for Branch instructions.
	CLA_16bit branchaddr(.A(pcs), .B(imm << 1), .S(branch_imm));

	RegisterFile Regs(.clk(clk), .rst(rst), .SrcReg1(SrcReg1),
		.SrcReg2(SrcReg2), .DstReg(DstReg), .WriteReg(RegWrite),
		.DstData(WriteData), .SrcData1(RegData1), .SrcData2(RegData2));

endmodule
