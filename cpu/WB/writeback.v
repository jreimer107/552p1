module writeback(alu_out, mem_out, imm, pc_next, DataSrc, WriteData);
	input [15:0] alu_out, mem_out, imm, pc_next;
	input [1:0] DataSrc;
	output [15:0] WriteData;

	assign WriteData = (DataSrc == 2'b00) ? mem_out :
					   (DataSrc == 2'b01) ? pc_next :
					   (DataSrc == 2'b10) ? imm :
											alu_out; //May need to be current pc

endmodule
