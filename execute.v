module execute(instr, ALUSrc, imm, RegData1, RegData2, match, alu_out,
	.branch_dest);
	input [15:0] instr, imm, RegData1, RegData2;
	input ALUSrc;
	output [15:0] alu_out, branch_dest;
	output match;

	wire [15:0] alu_in;
	wire alu_ovfl, match;

	assign alu_in = ALUSrc ? imm : RegData2;

	ALU alu(.A(RegData1), .B(alu_in), .op(instr[15:12]), .out(alu_out), .ovfl(alu_ovfl));

	CLA_16bit branch_adder(.A(pc_inc), .B(immSE << 1), .sub(1'b0), .ovfl(),
		.S(branch_dest), .sat(1'b0), .red(1'b0));

	CCodeEval FLAG(.clk(clk), .rst(rst), .instr(instr), .alu_out(alu_out),
		.alu_ovfl(alu_ovfl), .match(match));

endmodule
