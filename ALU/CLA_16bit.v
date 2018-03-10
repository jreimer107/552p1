/* CLA_16bit
* The second-level hierarchical CLA structure. Has 4 4bit adders and one CLA
* logic block to compute carries for the 4bit level
* and overall generates and propagates at the 16bit level.
* @input A and B are the word (16 bit) addends.
* @input cin is the carry in value given by ALU or other higher structure.
* @output S is the sum calculated by adding A, B, and cin.
* @output cout is the carry out value from the calculation.
*/
module CLA_16bit(A, B, cin, cout, S);
  input [15:0] A, B;
  input cin;
  output cout;
  output [15:0] S;

  wire c1, c2, c3;
  wire [3:0] g, p;
  wire G, P;

  CLA_4bit adder0(.A(A[3:0]), .B(B[3:0]), .c0(cin), .S(S[3:0]), .G(g[0]), .P(p[0]));
  CLA_4bit adder1(.A(A[7:4]), .B(B[7:4]), .c0(c1), .S(S[7:4]), .G(g[1]), .P(p[1]));
  CLA_4bit adder2(.A(A[11:8]), .B(B[11:8]), .c0(c2), .S(S[11:8]), .G(g[2]), .P(p[2]));
  CLA_4bit adder3(.A(A[15:12]), .B(B[15:12]), .c0(c3), .S(S[15:12]), .G(g[3]), .P(p[3]));

  CLA_block logic(.g_in(g), .p_in(p), .c0(cin),
    .G_out(G), .P_out(P), .c1(c1), .c2(c2), .c3(c3));

  //This calculation is only needed for the highest level block.
  assign cout = G | (P & cin);
endmodule
