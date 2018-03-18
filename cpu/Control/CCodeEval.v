/* CCodeEval
* This module both stores the condition codes set by the previous instructions
* and evaluates the code requested by the current instruction.
* @input instr is the current instruction in full. Based on which instruction
* type it is, this module will either update its condition codes or use them to
* output a value which can be used for control functions. No instruction will
* ever write and read from the condition codes, so this is not a concern.
* @alu_out is the output of the ALU due to the current instructon.
* @alu_ovfl signifies if the current instruction caused overflow.
* @out is a 1 bit signal which is 1 when the requested condition matches the
*   current codes and 0 otherwise.
*/
module CCodeEval(clk, rst, opcc, alu_out, alu_ovfl, cond_true);
  input clk, rst;
  input alu_ovfl;
  input [6:0] opcc;
  input [15:0] alu_out;
  output cond_true;

  localparam  ADD = 4'b0000;
  localparam  SUB = 4'b0001;
  localparam  XOR = 4'b0011;
  localparam  SLL = 4'b0100;
  localparam  SRA = 4'b0101;
  localparam  ROR = 4'b0110;

  localparam  ne = 3'b000;
  localparam  eq = 3'b001;
  localparam  gt = 3'b010;
  localparam  lt = 3'b011;
  localparam  ge = 3'b100;
  localparam  le = 3'b101;
  localparam  ov = 3'b110;
  localparam  un = 3'b111;

  wire [3:0] opcode;  //Determines wether to write or read codes
  wire [2:0] C;     //Requested code
  assign opcode = opcc[6:3];
  assign C = opcc[2:0];

  //Write Enables to FLAG register
  wire [2:0] ccWrEn; //NVZ order
  assign ccWrEn = (opcode === ADD || opcode === SUB) ? 3'b111 :
	(opcode === XOR || opcode === SLL || opcode === SRA || opcode === ROR) ? 3'b001 :
	  3'b000;

  //Input/output data to/from FLAG register
  wire [2:0] flag_in, F;
  assign flag_in = {alu_out[15], alu_ovfl, ~|alu_out};
  flag_reg FLAG(.clk(clk), .rst(rst), .D(flag_in), .WriteEn(ccWrEn), .F(F));
  assign {N, V, Z} = F;


  //Evaluate condition
  assign cond_true = (C == ne && ~Z			     ||
					 C == eq && Z                ||
					 C == gt && (~Z & ~N)        ||
					 C == lt && N                ||
					 C == ge && (Z | (~N & ~Z))  ||
					 C == le && (N | Z)          ||
					 C == ov && V                ||
					 C == un)  ?
					  1'b1 : 1'b0;

endmodule

module flag_reg(clk, rst, D, WriteEn, F);
	input clk, rst;
	input [2:0] D, WriteEn;
	output [2:0] F;

	dff negative(.q(F[2]), .d(D[2]), .wen(WriteEn[2]), .clk(clk), .rst(rst));
	dff overflow(.q(F[1]), .d(D[1]), .wen(WriteEn[1]), .clk(clk), .rst(rst));
	dff zero(.q(F[0]), .d(D[0]), .wen(WriteEn[0]), .clk(clk), .rst(rst));

endmodule
