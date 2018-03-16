module writeback(pc_out, alu_out, mem_out, branch_dest, DataSrc, BranchSrc,
	match, WriteData, pc_in);
	input [15:0] pc_out, alu_out, mem_out, branch_dest;
	input [1:0] DataSrc, BranchSrc;
	input match;
	output [15:0] WriteData, pc_in;

	assign WriteData = (DataSrc == 2'b00) ? mem_out :
					   (DataSrc == 2'b1x) ? alu_out :
											pc_out; //May need to be current pc

	assign pc_in = (~match || BranchSrc == 2'b00) ? pc_out :
					   (BranchSrc == 2'b01) ? branch_dest :
											RegData2;
