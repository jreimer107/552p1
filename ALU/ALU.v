module ALU(A, B, op, out, zero);
  input [15:0] A, B;
  input [3:0] op;
  output [15:0] out;
  output zero;

  wire [15:0] out_and, out_or, out_op, B_op;
  wire cin, cout;
  wire invert;

  localparam  op_or = 2'b00;
  localparam  op_and = 2'b01;
  localparam  op_op = 2'b1x;

  /* ALUOP
  * The op signal sent to the alu determines what it does.
  * TODO: edit these as necessary.
  * Memory instructions (opcode 10xx) should use ADD.
  * Control instructions (opcode 11xx) should use SUBTRACT.
  * Arithmetic instructions (opcode 0xxx) use whatever is necessary.
  * ADD (0000) uses ADD.
  * SUB (0001) uses SUBTRACT.
  * RED (0010) uses ?
  * XOR (0011) uses XOR.
  * SLL (0100) uses SHIFT LOGICAL.
  * SRA (0101) uses SHIFT ARITHMETIC.
  * ROR (0110) uses ROTATE.
  * PADDSB (0111) uses ?
  */

  //TODO: I think we're going to have to spread this out; we need to attach
  //  a CSA tree in here and attach muxes for reduction and saturation. I
  // think that the reduction problem from the hell exam was a hint.
  CLA_16bit adder(.A(A), .B(B_op), .cin(cin), .cout(cout), .S(out_op));

  assign out_or = A | B;
  assign out_and = A & B;
  assign B_op = invert ? ~B : B;
  assign out_op = A + B_op;

  //This is going to want an actual adder but thats for another time

  assign out = (op == op_or) ? out_or :
               (op == op_and) ? out_and :
                                out_op;
  assign zero = (op_out == 16'h0000);
endmodule
