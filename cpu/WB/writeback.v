module writeback(pc_out, alu_out, mem_out, imm, branch_dest, RegData2, DataSrc,
	BranchSrc, match, WriteData, pc_in);
	input [15:0] pc_out, alu_out, mem_out, imm, branch_dest, RegData2;
	input [1:0] DataSrc, BranchSrc;
	input match;
	output [15:0] WriteData, pc_in;

	assign WriteData = (DataSrc == 2'b00) ? mem_out :
					   (DataSrc == 2'b01) ? pc_out :
					   (DataSrc == 2'b10) ? imm :
											alu_out; //May need to be current pc

	assign pc_in = (~match || BranchSrc == 2'b00) ? pc_out :
					   (BranchSrc == 2'b01) ? branch_dest :
											RegData2;
endmodule
