/* execute.v
* This module takes the data outputs from the decode stage and computes the
* arithmetic output based on the current opcode. It also evaluates the current
* condition based on the current codes in the FLAG register.
* @input instr is the current instruction.
* @input ALUSrc determines whether to use the second Register data or the
*	immediate in calculations.
* @input imm is the immediate generated by the Decode stage.
* @input RegData1 and RegData2 are the Register Data.
* @output alu_out is the result of the calculation.
* @output cond_true is 1 when the condition given in the instruction matches the
* 	values in the flag register.
*/
module execute(clk, rst, instr, RegData1, RegData2, pcs, alu_out, LdByte, MemOp,
		ForwardA, ForwardB, alu_out_MEM, WriteData, NVZ);
	input clk, rst;
	input LdByte, MemOp;
	input [15:0] instr, RegData1, RegData2, pcs;
	//Forwarding inputs
	input [1:0] ForwardA, ForwardB;
	input [15:0] alu_out_MEM, WriteData;

	output [15:0] alu_out;
	output [2:0] NVZ;

	wire [15:0] ALUA, ALUB;
	wire [6:0] ALUop;

	wire dis;
	
	assign dis = ~|instr[11:8] ? 1'b1 : 1'b0;

	ALU_Control ACTL(.instr(instr), .RegData1(RegData1), .RegData2(RegData2),
		.pcs(pcs), .LdByte(LdByte), .MemOp(MemOp), .alu_out_MEM(alu_out_MEM),
		.WriteData(WriteData), .ForwardA(ForwardA), .ForwardB(ForwardB),
		.ALUA(ALUA), .ALUB(ALUB), .ALUop(ALUop));

	ALU alu(.A(ALUA), .B(ALUB), .ALUop(ALUop), .out(alu_out),
		.ovfl(alu_ovfl));

	flag_reg FLAG(.clk(clk), .rst(rst), .opcode(instr[15:12]),
		.alu_ovfl(alu_ovfl), .alu_out(alu_out), .dis(dis), .NVZ(NVZ));

endmodule
