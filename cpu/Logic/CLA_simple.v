/* CLA_16bit
* The second-level hierarchical CLA structure. Has 4 4bit adders and one CLA
* logic block to compute carries for the 4bit level and overall generates and
* propagates at the 16bit level. Also contains the reduction unit necessary for
* the RED instruction. Non PADDSB or RED outputs are saturated.
* @input A and B are the word (16 bit) addends.
* @output S is the sum calculated by adding A, B, and sub.
*/
module CLA_16bit(A, B, S);
	input [15:0] A, B;
  	output [15:0] S;

  	wire c1, c2, c3;
  	wire [3:0] g, p;
  	wire G, P;

  	CLA_4bit adder0(.A(A[3:0]), .B(B[3:0]), .c0(1'b0), .S(S[3:0]), .G(g[0]),
		.P(p[0]));
  	CLA_4bit adder1(.A(A[7:4]), .B(B[7:4]), .c0(c1), .S(S[7:4]), .G(g[1]),
		.P(p[1]));
  	CLA_4bit adder2(.A(A[11:8]), .B(B[11:8]), .c0(c2), .S(S[11:8]),
		.G(g[2]), .P(p[2]));
  	CLA_4bit adder3(.A(A[15:12]), .B(B[15:12]), .c0(c3), .S(S[15:12]),
		.G(g[3]), .P(p[3]));

	//16bit logic block
  	CLA_block logic(.g_in(g), .p_in(p), .c0(sub),
    	.G_out(G), .P_out(P), .c1(c1), .c2(c2), .c3(c3));
endmodule

/* CLA_4bit
* First_level hierarchical CLA structure. Has 4 1bit adders and one CLA logic
* block to compute carries for the 1bit level and generate and propagate signals
* the 4bit level.
* @input A and B are the 4bit addends.
* @input c0 is the carry in value given by the 16bit level logic block.
* @input sat is 1 when a PADDSB instruction has been issued. Causes S to
*   saturate to 1111 or 0111, and turns off outputs P and G.
* @output S is the sum calculated by adding A, B, and c0.
* @output G determines whether A and B will generate a carry regardless of c0.
* @output p determines if B and A will propagate a carry if c0 is 1.
*/
module CLA_4bit(A, B, c0, S, G, P);
	input [3:0] A, B;
  	input c0;      //Delivered to block 0 and to logic to compute other carries.
  	output [3:0] S;
  	output G, P;

  	wire [3:0] g, p;
  	wire c1, c2, c3; //Carries to be delivered to blocks 1, 2, and 3 from logic.

  	CLA_1bit adder0(.a(A[0]), .b(B[0]), .cin(c0), .s(S[0]), .g(g[0]), .p(p[0]));
  	CLA_1bit adder1(.a(A[1]), .b(B[1]), .cin(c1), .s(S[1]), .g(g[1]), .p(p[1]));
  	CLA_1bit adder2(.a(A[2]), .b(B[2]), .cin(c2), .s(S[2]), .g(g[2]), .p(p[2]));
  	CLA_1bit adder3(.a(A[3]), .b(B[3]), .cin(c3), .s(S[3]), .g(g[3]), .p(p[3]));

  	//CLA logic
  	CLA_block logic(.g_in(g), .p_in(p), .c0(c0),
    	.G_out(G), .P_out(P), .c1(c1), .c2(c2), .c3(c3));
endmodule

/* CLA_1bit
* Ground level hierarchical CLA structure. Basically a modified full adder to
* return generate and propagate rather than a carry, which is computed with
* other carries in a higher logic block.
* @input a and b are the single bit addends.
* @input cin is the carry in value given by the 4bit level logic block.
* @output s is the sum calculated by adding a, b, and cin.
* @output g determines whether a and b will generate a carry regardless of cin.
* @output p determines if a and b will propagate a carry if cin is 1.
*/
module CLA_1bit(a, b, cin, s, g, p);
  	input a, b, cin;
  	output s, g, p;

  	assign g = a & b;
  	assign p = a | b;
  	assign s = a ^ b ^ cin;
endmodule

/* CLA_block
* Takes the generates and propagates of the lower logic level and calculates
* carries to return there based on the given c0 (cin). Also calculates the
* generate and propagate signals needed for higher logic levels.
* @input g_in is a vector of generate signals from the lower level.
* @input p_in is a vector of propagate signals from the lower level.
* @input c0 is the input carry which will determine the carries to be delivered
*   back to lower levels. Given by the higher level logic block.
* @output G_out is a single bit signifiying if the lower level generates a
*   carry. Used by the higher level block.
* @output P_out is a single bit signifying if the lower level propagates a
*   carry. Used by the higher level block.
* @output c1 is the carry in value to be delivered to the lower block in
*   position 1. Similar for c2 and c3.
*/
module CLA_block(g_in, p_in, c0, G_out, P_out, c1, c2, c3);
  	input [3:0] g_in, p_in;
  	input c0;
  	output G_out, P_out;
  	output c1, c2, c3;

  //Can be simplified? Does it matter? Synthesis would take care of it.

  //Generate and propagate to be delivered to higher blocks.
  	assign G_out = g_in[3] |
                   (p_in[3] & g_in[2]) |
                   (p_in[3] & p_in[2] & g_in[1]) |
                   (p_in[3] & p_in[2] & p_in[1] & g_in[0]);

  	assign P_out = p_in[3] & p_in[2] & p_in[1] & p_in[0];

  	//Carries to be delivered to lower blocks.
  	assign c1 = g_in[0] | (p_in[0] & c0);
  	assign c2 = g_in[1] | (p_in[1] & c1);
  	assign c3 = g_in[2] | (p_in[2] & c2);
endmodule
