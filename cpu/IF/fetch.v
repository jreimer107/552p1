module fetch(pc_in, pc_out, instr, clk, rst);
	input clk, rst;
	input [15:0] pc_in;
	output [15:0] pc_out, instr;

	wire [15:0] pc;

	Register PC(.clk(clk), .rst(rst), .D(pc_in), .WriteReg(1'b1),
		.ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc), .Bitline2());

	CLA_16bit pc_incrementor(.A(pc), .B(16'h0002), .sub(1'b0), .ovfl(),
		.S(pc_out), .sat(1'b0), .red(1'b0));

	wire [15:0] instr;
	memory1c Imem(.data_out(instr), .data_in(), .addr(pc), .enable(1'b1),
		.wr(1'b0), .clk(clk), .rst(rst));

endmodule
