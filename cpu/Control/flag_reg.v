module flag_reg(clk, rst, opcode, alu_ovfl, alu_out, NVZ);
    input clk, rst;
    input [3:0] opcode;
    input alu_ovfl;
    input [15:0] alu_out;
	output [2:0] NVZ;

    localparam  ADD = 4'b0000;
    localparam  SUB = 4'b0001;
    localparam  XOR = 4'b0011;
    localparam  SLL = 4'b0100;
    localparam  SRA = 4'b0101;
    localparam  ROR = 4'b0110;

    //Write Enables to FLAG register
    wire [2:0] WriteEn; //NVZ order
    assign WriteEn = (opcode === ADD || opcode === SUB) ? 3'b111 :
	    (opcode === XOR || opcode === SLL || opcode === SRA || opcode === ROR) ? 3'b001 : 
            3'b000;

    //FLAG inputs
    wire [2:0] NVZ_in;
    assign NVZ_in = {alu_out[15], alu_ovfl, ~|alu_out};
    dff negative(.q(NVZ[2]), .d(NVZ_in[2]), .wen(WriteEn[2]), .clk(clk), .rst(rst));
	dff overflow(.q(NVZ[1]), .d(NVZ_in[1]), .wen(WriteEn[1]), .clk(clk), .rst(rst));
	dff zero(.q(NVZ[0]), .d(NVZ_in[0]), .wen(WriteEn[0]), .clk(clk), .rst(rst));
endmodule