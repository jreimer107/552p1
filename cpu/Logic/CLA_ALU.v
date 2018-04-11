// RECOMMEND CHANGING sat SIGNAL TO paddsb


/* CLA_ALU16
* The second-level hierarchical CLA structure. Has 4 4bit adders and one CLA
* logic block to compute carries for the 4bit level and overall generates and
* propagates at the 16bit level. Also contains the reduction unit necessary for
* the RED instruction. Non PADDSB or RED outputs are saturated.
* @input A and B are the word (16 bit) addends.
* @input sub signifies wether a addition or subtraction operation; essentially
*   a carry-in.
* @input sat signifies a PADDSB isntruction, which prevents carry propagation
*   and saturates 4bit outputs.
* @input reg signifies a RED instruction, which uses the reduction unit to
*   reduction add both addends.
* @output S is the sum calculated by adding A, B, and sub.
* @output ovfl signifies if overflow occurred.
*/
//TODO: update TB to include reduction. Reduction is confirmed working by itself.
module CLA_ALU16(A, B, sub, S, sat, red, ovfl);
	input [15:0] A, B;
  	input sub, red, sat;
  	output ovfl;
  	output [15:0] S;

  	wire signed [15:0] S_raw, S_red, S_sat;
  	wire c1, c2, c3;
  	wire [3:0] g, p;
  	wire G, P;
  	wire pos_ovfl, neg_ovfl;

  	CLA_ALU4 adder0(.A(A[3:0]), .B(B[3:0]), .c0(sub), .S(S_raw[3:0]), .G(g[0]),
		.P(p[0]), .sat(sat), .red(red));
  	CLA_ALU4 adder1(.A(A[7:4]), .B(B[7:4]), .c0(c1), .S(S_raw[7:4]), .G(g[1]),
		.P(p[1]), .sat(sat), .red(red));
  	CLA_ALU4 adder2(.A(A[11:8]), .B(B[11:8]), .c0(c2), .S(S_raw[11:8]),
		.G(g[2]), .P(p[2]), .sat(sat), .red(red));
  	CLA_ALU4 adder3(.A(A[15:12]), .B(B[15:12]), .c0(c3), .S(S_raw[15:12]),
		.G(g[3]), .P(p[3]), .sat(sat), .red(red));

	//16bit logic block
  	CLA_block logic(.g_in(g), .p_in(p), .c0(sub),
    	.G_out(G), .P_out(P), .c1(c1), .c2(c2), .c3(c3));

  	//Reduction block
  	Reduction reduct(.s0(S_raw[3:0]), .s1(S_raw[7:4]), .s2(S_raw[11:8]),
		.s3(S_raw[15:12]), .g0(g[0]), .g1(g[1]), .g2(g[2]), .g3(g[3]),
		.S_red(S_red));

  	//This calculation is only needed for the highest level block.
  	//assign cout = G | (P & sub);


	//Saturation logic. Only for add/sub.
	assign pos_ovfl = (S_raw[15] & ~A[15] & ~B[15]);
	assign neg_ovfl = (~S_raw[15] & A[15] & B[15]);
	assign ovfl = pos_ovfl | neg_ovfl;
	assign S_sat = pos_ovfl ? 16'h7FFF :
   				   neg_ovfl ? 16'h8000 :
				 			  S_raw;

	/* If PADDSB (sat) is issued,  we don't want ot mess with the output. If RED
	* is issued, we need to set the output to the reduction output
	* (S_red). If neither are issued, we need to saturate the output to 16bits.
	*/
  	assign S = red ? S_red :
  			   sat ? S_raw :
			 		 S_sat;

endmodule

/* CLA_ALU4
* First_level hierarchical CLA structure. Has 4 1bit adders and one CLA logic
* block to compute carries for the 1bit level and generate and propagate signals
* the 4bit level.
* @input A and B are the 4bit addends.
* @input c0 is the carry in value given by the 16bit level logic block.
* @input sat is 1 when a PADDSB instruction has been issued. Causes S to
*   saturate to 1111 or 0111, and turns off outputs P and G.
* @input red is 1 when a RED instruction has been issued. Stops carry
*   propagation by turning off output P.
* @output S is the sum calculated by adding A, B, and c0.
* @output G determines whether A and B will generate a carry regardless of c0.
* @output p determines if B and A will propagate a carry if c0 is 1.
*/
module CLA_ALU4(A, B, c0, S, G, P, sat, red);
	input [3:0] A, B;
  	input c0;       //Delivered to block 0 and to logic to compute other carries.
  	input sat, red;
  	output [3:0] S;
  	output G, P;

  	wire [3:0] g, p, S_raw;
  	wire G_raw, P_raw;
  	wire c1, c2, c3; //Carries to be delivered to blocks 1, 2, and 3 from logic.
  	wire pos_ovfl, neg_ovfl;

  	CLA_1bit adder0(.a(A[0]), .b(B[0]), .cin(c0), .s(S_raw[0]), .g(g[0]), .p(p[0]));
  	CLA_1bit adder1(.a(A[1]), .b(B[1]), .cin(c1), .s(S_raw[1]), .g(g[1]), .p(p[1]));
  	CLA_1bit adder2(.a(A[2]), .b(B[2]), .cin(c2), .s(S_raw[2]), .g(g[2]), .p(p[2]));
  	CLA_1bit adder3(.a(A[3]), .b(B[3]), .cin(c3), .s(S_raw[3]), .g(g[3]), .p(p[3]));

  	//CLA logic
  	CLA_block logic(.g_in(g), .p_in(p), .c0(c0),
    	.G_out(G_raw), .P_out(P_raw), .c1(c1), .c2(c2), .c3(c3));

	//Saturation for PADDSB
  	assign pos_ovfl = (S_raw[3] & ~A[3] & ~B[3]);
  	assign neg_ovfl = (~S_raw[3] & A[3] & B[3]);

  	assign S = ~sat ? S_raw :
  			 	pos_ovfl ? 4'b0111 :
			 	neg_ovfl ? 4'b1000 :
				S_raw;

  	assign P = (sat | red) ? 1'b0 : P_raw;
  	assign G = sat ? 1'b0 : G_raw;

endmodule
