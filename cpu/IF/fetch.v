module fetch(clk, rst, pc_branch, branch, stop, instr, pcs);
	input clk, rst;
	input cond_true, stop;
	input [15:0] pc_branch;
	output [15:0] pcs, instr;

	wire [15:0] pc, pc_inc, pc_next, increment;

	//Selects next pc based on branch coditions.
	assign pc_next = branch ? pc_branch : pc_inc;
	//Pauses/stops pc based on HLT instrs or control hazard bubbles.
	assign increment = stop ? 16'h0000 : 16'h0002;

	//Makes pc_next current pc.
	Register PC(.clk(clk), .rst(rst), .D(pc_next), .WriteReg(1'b1),
		.ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc), .Bitline2());

	//Makes pc_inc out of pc.
	CLA_16bit incrementor(.A(increment), .B(pc), .sub(1'b0), .S(pc_inc),
		.sat(1'b0), .red(1'b0), .ovfl());

	//Gets instruction stored at pc.
	memory1c Imem(.data_out(instr), .data_in(), .addr(pc), .enable(1'b1),
		.wr(1'b0), .clk(clk), .rst(rst));

	assign pcs = pc_inc; //Redirect pc_inc to better name for externals.
endmodule
