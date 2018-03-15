/* CCodeEval
* This module both stores the condition codes set by the previous instructions
* and evaluates the code requested by the current instruction.
* @input instr is the current instruction in full. Based on which instruction
* type it is, this module will either update its condition codes or use them to
* output a value which can be used for control functions. No instruction will
* ever write and read from the condition codes, so this is not a concern.
* @alu_out is the output of the ALU due to the current instructon.
* @alu_ovfl signifies if the current instruction caused overflow.
* @out is a 1 bit signal which is 1 when the requested condition matches the
*   current codes and 0 otherwise.
*/
//TODO: Write a tb and test lol.
module CCodeEval(clk, rst, instr, alu_out, alu_ovfl, match);
  input clk, rst;
  input alu_ovfl;
  input [15:0] instr;
  input [15:0] alu_out;
  output match;

  localparam  ADD = 4'b0000;
  localparam  SUB = 4'b0001;
  localparam  XOR = 4'b0011;
  localparam  SLL = 4'b0100;
  localparam  SRA = 4'b0101;
  localparam  ROR = 4'b0110;

  wire [3:0] opcode;  //Determines wether to write or read codes
  wire [2:0] cc_Req;     //Requested code
  assign opcode = instr[15:12];
  assign cc_Req = instr[11:9];

  wire [2:0] regWrite; //NVZ order (write enables)
  assign regWrite = (opcode === ADD || opcode === SUB) ? 3'b111 :
    (opcode === XOR || opcode === SLL || opcode === SRA || opcode === ROR) ? 3'b001 :
      3'b000;

  //regWrite will be 3'b000 if instruction relies on condition code
  wire n, v, z; //dff inputs
  wire [2:0] cc_Curr;
  assign n = alu_out[15];
  assign v = alu_ovfl;
  assign z = ~|alu_out;
  dff negative(.q(cc_Curr[2]), .d(n), .wen(regWrite[2]), .clk(clk), .rst(rst));
  dff overflow(.q(cc_Curr[1]), .d(v), .wen(regWrite[1]), .clk(clk), .rst(rst));
  dff zero(.q(cc_Curr[0]), .d(z), .wen(regWrite[0]), .clk(clk), .rst(rst));

  assign match = (cc_Req === cc_Curr);

endmodule
