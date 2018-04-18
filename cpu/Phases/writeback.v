module writeback(alu_out, mem_out, DataSrc, WriteData);
	input [15:0] alu_out, mem_out;
	input DataSrc;
	output [15:0] WriteData;

	assign WriteData = DataSrc ? mem_out : alu_out;
endmodule
