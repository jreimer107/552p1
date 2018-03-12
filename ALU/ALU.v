/* ALU
* This module computes all arithmetic functions needed by the cpu.
* @input A, B are the two operands to use.
* @input op is the instruction issued.
* @output out is the result of the arithmetic function.
*/

//TODO: write a tb and test.

//TODO: I have the first 8 functions figured out. No idea how the memory or
// control functions are supposed to interact with the ALU, so I'm assuming they
// all need ADD. This is probably shortsighted and needs to change later.
module ALU(A, B, op, out);
  input [15:0] A, B;
  input [3:0] op;
  output [15:0] out;
  output zero;

  wire [15:0] out_cla, out_xor, out_shift; //Output mux inputs

  localparam  ADD = 4'b0000;  //CLA
  localparam  SUB = 4'b0001;  //CLA
  localparam  RED = 4'b0010;  //CLA
  localparam  XOR = 4'b0011;
  localparam  SLL = 4'b0100;
  localparam  SRA = 4'b0101;
  localparam  ROR = 4'b0110;
  localparam  PADDSB = 4'b0111; //CLA
  localparam  MEM = 4'b10xx;
  localparam  CTRL = 4'b11xx;

  ///////////////////////CLA_16bit//////////////////////////////////////////////
  //Computes ADD, SUB, RED, PADDSB, and MEM and CTRL arithmetic operations.
  wire [15:0] B_cla;
  wire cin, cout, sat, red;
  assign B_cla = (op == SUB) ? ~B : B;
  assign cin = (op == SUB);
  assign sat = (op == PADDSB);
  assign red = (op == RED);
  CLA_16bit CLA(.A(A), .B(B_cla), .cin(cin), .cout(cout), .S(out_cla), .red(red), .sat(sat));
  //////////////////////////////////////////////////////////////////////////////

  //Shifter
  Shifter shift(.Shift_In(A), .Shift_Val(B), .Mode(op[2:1]), .Shift_Out(out_shift));

  //XOR
  assign out_xor = A ^ B;

  //output mux
  assign out = (op == XOR) ? out_xor :
               (op == PADDSB) ? out_cla :    //THIS FUCKER IS IN THE WRONG PLACE
               (op[3:2] == 2'b01) ? out_shift :
                  out_cla;

endmodule
