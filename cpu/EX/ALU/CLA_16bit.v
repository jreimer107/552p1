// RECOMMEND CHANGING sat SIGNAL TO paddsb


/* CLA_16bit
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
module CLA_16bit(A, B, sub, S, sat, red, ovfl);
	input [15:0] A, B;
  	input sub, red, sat;
  	output ovfl;
  	output [15:0] S;

  	wire signed [15:0] S_raw, S_red, S_sat;
  	wire c1, c2, c3;
  	wire [3:0] g, p;
  	wire G, P;
  	wire pos_ovfl, neg_ovfl;

  	CLA_4bit adder0(.A(A[3:0]), .B(B[3:0]), .c0(sub), .S(S_raw[3:0]), .G(g[0]),
		.P(p[0]), .sat(sat), .red(red));
  	CLA_4bit adder1(.A(A[7:4]), .B(B[7:4]), .c0(c1), .S(S_raw[7:4]), .G(g[1]),
		.P(p[1]), .sat(sat), .red(red));
  	CLA_4bit adder2(.A(A[11:8]), .B(B[11:8]), .c0(c2), .S(S_raw[11:8]),
		.G(g[2]), .P(p[2]), .sat(sat), .red(red));
  	CLA_4bit adder3(.A(A[15:12]), .B(B[15:12]), .c0(c3), .S(S_raw[15:12]),
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
