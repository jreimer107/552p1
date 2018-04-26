module memory(clk, rst, alu_out, RegData2, MemOp, MemWrite, mem_out, stall);
	input clk, rst;
	input MemOp, MemWrite;
	input [15:0] alu_out, RegData2;
	output [15:0] mem_out;
	output stall;

	// memory1c DMem(.data_out(mem_out), .data_in(RegData2), .addr(alu_out),
	// .enable(MemOp), .wr(MemWrite), .clk(clk), .rst(rst));

	CacheController Imem(.clk(clk), .rst(rst), .write(MemWrite), .op(MemOp),
		.address_in(alu_out), .data_out(mem_out), .data_in(RegData2), .stall(stall));	


endmodule
