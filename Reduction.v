/* Reduction Unit
* This module takes the sums from the lower level CLA4s and creates a reducted
* sum (aaaabbbbccccdddd + eeeeffffgggghhhh = (aaaa+eeee) + (bbbb+ffff) +
*    (cccc+gggg) + (dddd+hhhh)), essentially summing 8 4bit numbers.
* This can create 3 bits of carry out, so a wallace tree is used to sum these.
* The whole sum is then sign extended for the remaining 9 bits.
* In order to properly work, lower level Propegate signals must be zeroed.
* TODO: Verify design via tb.
*/
module Reduction(s0, s1, s2, s3, g0, g1, g2, g3, S_red);
  input [3:0] s0, s1, s2, s3;
  input g0, g1, g2, g3;
  output [15:0] S_red;

  wire [3:0] s4, s5;  //Intermediates for final sum
  wire [6:0] G;       //Input for Wallace tree

  assign G[3:0] = {g3, g2, g1, g0}; //Organize inputs for wallace tree

  //Medium level two CLAs
  CLA_4bit cla4(.A(s0), .B(s1), .cin(1'b0), .S(s4), .G(G[4]), .P());
  CLA_4bit cla5(.A(s3), .B(s2), .cin(1'b0), .S(s5), .G(G[5]), .P());

  //High level CLA, gets lower 4 bits of S_red
  CLA_4bit cla6(.A(s5), .B(s4), .cin(1'b0), .S(S_red[3:0]), .G(G[6]), .P());

  //Gets bits 6:4 of S_red
  Wallace tree(.in(G), .out(S_red[6:4]));

  assign S_red[15:7] = {9{S_red[6]}}; //Sign extends S_red

endmodule
