module fetch(pc_next, pc, instr, clk, rst);
	input clk, rst;
	input [15:0] pc_next;
	output [15:0] pc, instr;

	//Makes pc_next current pc.
	Register PC(.clk(clk), .rst(rst), .D(pc_next), .WriteReg(1'b1),
		.ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc), .Bitline2());

	wire [15:0] instr;
	memory1c Imem(.data_out(instr), .data_in(), .addr(pc), .enable(1'b1),
		.wr(1'b0), .clk(clk), .rst(rst));

endmodule
