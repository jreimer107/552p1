module HazardDetection(intr_IF, instr_ID, MemOp_ID, MemWrite_ID, 
	bubble, NOP_or_instr_IF);
	input [15:0] instr_IF, instr_ID;
	input MemOp_ID, MemWrite_ID;
	output bubble, NOP_or_instr_IF;

	// feels bad, basically duplicated half the ID phase here  
   	wire op, op7to0, op7to4, op11to4, op11to8;
   	
   	assign op = instr_IF[15:12];

	//Karnaugh Maps! <3
	wire A, B, C, D;
	assign {A,B,C,D} = op;
	assign op7to0 = (~A & ~B) | (~A & C & D);
	assign op7to4 = (~A & B & ~D) | (B & ~C & D);
	assign op11to4 = A & ~B & C;
	assign op11to8 = A & B & ~C;
	
	assign bubble = MemOp_ID && ~MemWrite_ID && 
		op7to0 ? (instr_ID[11:8] == instr_IF[7:4] || instr_ID[11:8] == instr_IF[3:0]) :
		op7to4 ? (instr_ID[11:8] == instr_IF[7:4]) : 
		op11to4 ? (instr_ID[11:8] == instr_IF[11:8] || instr_ID[11:8] == instr_IF[7:4]) : 
		op11to8 ? (instr_ID[11:8] == instr_IF[11:8]) : 
		1'b0;
	
	assign NOP_or_instr_IF = bubble ? 16'h0000 : instr_IF;

endmodule