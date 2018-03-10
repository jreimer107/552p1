module Wallace(in, out);
  input [6:0] in;
  output [2:0] out;

  wire s00, s01, s10, s11, s20, s21, s30, s31;

  FA adder0(.A(in[2]), .B(in[1]), .cin(in[0]), .cout(s01), .S(s00));
  FA adder1(.A(in[5]), .B(in[4]), .cin(in[3]), .cout(s11), .S(s10));
  FA adder2(.A(in[6]), .B(s10), .cin(s00), .cout(s21), .S(s20));
  FA adder3(.A(s21), .B(s11), .cin(s01), .cout(s31), .S(s30));

  assign out = {s31, s30, s20};
endmodule
