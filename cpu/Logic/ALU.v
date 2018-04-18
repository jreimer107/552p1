/* ALU
* This module computes all arithmetic functions needed by the cpu.
* @input A, B are the two operands to use.
* @input op is the instruction issued.
* @output out is the result of the arithmetic function.
* @output zero signifies if the output is 0.
* @output ovfl signifies if a CLA operation caused overflow.
*/
module ALU(A, B, ALUop, ovfl, out);
	input [15:0] A, B;
	input [4:0] op;
 	output [15:0] out;
	output ovfl;

	//Aluop controls
	wire red, sub, sat;
	wire [1:0] outputSelect, shiftop;
	wire [15:0] out_cla, out_xor, out_shift; //Output mux inputs

	//Decode ALUOp
	assign {outputSelect, sat, red, sub, shiftop} = ALUOp;

  	//Computes ADD, SUB, RED, PADDSB, and MEM and CTRL arithmetic operations.
  	CLA_ALU16 CLA(.A(A), .B(B_cla), .sub(sub), .red(red), .sat(sat),
		.ovfl(ovfl), .S(out_cla));

  	//Computes SLL, SRA, and ROR calculations
  	Shifter shift(.Shift_In(A), .Shift_Val(B[3:0]), .Mode(op[1:0]), .Shift_Out(out_shift));

  	//XOR
  	assign out_xor = A ^ B;

  	//output mux
  	assign out = outputSelect[1] ? out_shift :
				 outputSelect[0] ? out_xor :
				 				   out_cla;
endmodule
