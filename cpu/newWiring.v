    //Globals, phase-hopping
	wire bubble, Branch, cond_true;
	wire [2:0] NVZ;
	wire [15:0] WriteData;
	
	//ID Specific//
	wire [15:0] pc_branch;
	wire RegSrc, BranchSrc;
	wire [1:0] ImmSize;
	
	//EX Specific//
	wire [1:0] ForwardA, ForwardB;


	//Data
	wire [15:0] instr_IF,	instr_ID, 		instr_EX;
	wire [15:0] pcs_IF, 	pcs_ID, 		pcs_EX, 		pcs_MEM, 		pcs_WB;
	wire [15:0] 			RegData1_ID,	RegData1_EX;
	wire [15:0] 			RegData2_ID, 	RegData2_EX, 	RegData2_MEM;
	wire [15:0] 			imm_ID, 		imm_EX, 		imm_MEM, 		imm_WB;
	wire [15:0] 							alu_out_EX, 	alu_out_MEM, 	alu_out_WB;
	wire [3:0] 												Rd_MEM, 		Rd_WB;
	
	//Control Signals
	wire RegWrite_ID, 	RegWrite_EX, 	RegWrite_MEM, 	RegWrite_WB;
	wire MemOp_ID, 		MemOp_EX,		MemOp_MEM;
	wire MemWrite_ID, 	MemWrite_EX, 	MemWrite_MEM;
	wire ALUSrc_ID, 	ALUSrc_EX;
	wire [1:0] DataSrc_ID, DataSrc_EX, DataSrc_MEM, DataSrc_WB;
