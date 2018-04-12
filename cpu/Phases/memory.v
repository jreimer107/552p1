module memory(clk, rst, op, alu_out, RegData2, MemOp, MemWrite, mem_out,
	ForwardImm, LdByte, imm_MEM, imm_WB, alu_imm, imm_out);
	input clk, rst;
	input MemOp, MemWrite, ForwardImm, LdByte;
	input [4:0] op;
	input [15:0] alu_out, RegData2, imm_MEM, imm_WB;
	output [15:0] mem_out, imm_out, alu_imm;
	

	memory1c DMem(.data_out(mem_out), .data_in(RegData2), .addr(alu_out), 
	.enable(MemOp), .wr(MemWrite), .clk(clk), .rst(rst));

	/* 
	if need imm forwarding 
		if curr instr is LLB
			imm_out = {Imm_WB[15:8], Imm_MEM[7:0]};
		else (LHB)
			imm_out = {Imm_MEM[15:8], Imm_WB[7:0]};
	else (don't need forwarding)
		imm = instr_MEM; 
	*/
	//LdByte is 0 for high byte, 1 for low
	assign imm_out = ForwardImm ?
		(LdByte ? {imm_WB[15:8], imm_MEM[7:0]} : {imm_MEM[7:0], imm_WB[7:0]}) : 
		(LdByte ? {RegData2[15:8], imm_MEM[7:0]} : {imm_MEM[7:0], RegData2[7:0]});

	wire LB;
	assign LB = op[3] & ~op[2] & op[1];
	assign alu_imm = LB ? imm_out : alu_out;

endmodule
