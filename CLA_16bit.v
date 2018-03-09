module CLA_16bit(A, B, cin, cout, S);
  input [15:0] A, B;
  input cin;
  output cout;
  output [15:0] S;

  wire c1, c2, c3;
  wire [3:0] g, p;
  wire G, P;

  CLA_4bit adder3(.A(A[15:12]), .B(B[15:12]), .Cin(c3), .S(S[15:12]), .G(g[3]), .P(p[3]));
  CLA_4bit adder2(.A(A[11:8]), .B(B[11:8]), .Cin(c2), .S(S[11:8]), .G(g[2]), .P(p[2]));
  CLA_4bit adder1(.A(A[7:4]), .B(B[7:4]), .Cin(c1), .S(S[7:4]), .G(g[1]), .P(p[1]));
  CLA_4bit adder0(.A(A[4:0]), .B(B[3:0]), .Cin(cin), .S(S[3:0]), .G(g[0]), .P(p[0]));

  CLA_bloc logic(.g_in(g), .p_in(p), .c0(cin),
    .G_out(G), .P_out(P), .c1(c1), .c2(c2), .c3(c3));

  assign cout = G | (P & cin);
endmodule

module CLA_4bit(A, B, c0, S, G, P);
  input [3:0] A, B;
  input c0;
  output [3:0] S;
  output G, P;

  wire [3:0] g, p;
  wire c1, c2, c3;

  CLA_1bit adder3(.a(A[3]), .b(B[3]), .cin(c3), .s(S[3]), .g(g[3]), .p(p[3]));
  CLA_1bit adder2(.a(A[2]), .b(B[2]), .cin(c2), .s(S[2]), .g(g[2]), .p(p[2]));
  CLA_1bit adder1(.a(A[1]), .b(B[1]), .cin(c1), .s(S[1]), .g(g[1]), .p(p[1]));
  CLA_1bit adder0(.a(A[0]), .b(B[0]), .cin(c0), .s(S[0]), .g(g[0]), .p(p[0]));

  //CLA logic
  CLA_block logic(.g_in(g), .p_in(p), .c0(c0),
    .G_out(G), .P_out(P), .c1(c1), .c2(c2), .c3(c3));
endmodule

//Returns g and p for the given bit, calculates s.
module CLA_1bit(a, b, cin, s, g, p);
  input a, b, cin;
  output s, g, p;

  assign g = a & b;
  assign p = a | b;
  assign s = a ^ b ^ c;
endmodule

//Actual CLA logic
module CLA_block(g_in, p_in, c0, G_out, P_out, c1, c2, c3);
  input [3:0] g_in, p_in;
  output G_out, P_out;
  output c1, c2, c3;

  //Can be simplified? Does it matter? Synthesis would take care of it.
  assign G_out = g_in[3] |
                (p_in[3] & g_in[2]) |
                (p_in[3] & p_in[2] & g_in[1]) |
                (p_in[3] & p_in[2] & p_in[1] & g_in[0]);
  assign P = p_in[3] & p_in[2] & p_in[1] & p_in[0];

  assign c1[0] = g_in[0] | (p_in[0] & c0); //c1
  assign c2[1] = g_in[1] | (p_in[1] & c1);   //c2
  assign c3[2] = g_in[2] | (p_in[2] & c2);   //c3

endmodule;
