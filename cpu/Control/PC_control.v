/* PC_control
* This module controls the incrementation of the pc.
* @input cond_true is the output of CCodeEval stating whether the condition
*	specified by the current instruction matches the status of the FLAG register.
* @input imm is the left shifted immediate used for branch instructions.
* @input RegData2 is the output of the RegisterFile used in BR instructions.
* @input BranchSrc specifies which kind the current instruction is; 00 is a non-
*	branch instr, 01 is B, and 1x is BR.
* @input hlt permanently ceases the incrementation of the pc.
* @input pc is the current pc.
* @output pc_next is the next pc, calculated based on Branch instructions and
*	NVZ conditions.
*/
module PC_control(cond_true, imm, RegData1, BranchSrc, hlt, pc, pc_next);
	input [1:0] BranchSrc;
	input cond_true, hlt;
	input [15:0] imm, RegData1;
	input [15:0] pc;
	output [15:0] pc_next;

	wire N, V, Z;
	wire [15:0] inc_amount, intermediate, addend, pc_noBR;


	//If HLT, do not want to increment PC.
	assign inc_amount = hlt ? 16'h0000 : 16'h0002;

	//If B, check for condition true and add immediate to incremented PC.
	assign addend = (BranchSrc[0] & cond_true) ? (imm << 1) : 16'h0000;

	//Increment and add immediate if necessary.
	CLA_16bit inc(.A(pc), .B(inc_amount), .sub(1'b0), .S(intermediate), .red(1'b0), .sat(1'b0), .ovfl());
	CLA_16bit imadder(.A(intermediate), .B(addend), .sub(1'b0), .S(pc_noBR), .red(1'b0), .sat(1'b0), .ovfl());

	//Finally if BR, check for condition true and set pc to RegData1 if so.
	assign pc_next = (BranchSrc[1] & cond_true) ? RegData1 : pc_noBR;

endmodule
