module ALU(A, B, op, out, zero);
  input [15:0] A, B;
  input [3:0] op;
  output [15:0] out;
  output zero;

  wire [15:0] out_and, out_or, out_op, B_op;
  wire cin, cout;

  localparam  op_or = 2'b00;
  localparam  op_and = 2'b01;
  localparam  op_op = 2'b1x;

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
