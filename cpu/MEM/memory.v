module memory(clk, rst, alu_out, RegData2, MemOp, MemWrite, mem_out);
	input clk, rst;
	input MemOp, MemWrite;
	input [15:0] alu_out, RegData2;
	output [15:0] mem_out;

	wire addrwire;
	
	assign addrwire = {alu_out[15:1],1'b0};


	memory1c DMem(.data_out(mem_out), .data_in(RegData2), .addr(alu_out),
		.enable(MemOp), .wr(MemWrite), .clk(clk), .rst(rst));
endmodule
