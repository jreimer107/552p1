module ALU_Control(instr, RegData1, RegData2, pcs, LdByte, MemOp,
	alu_out_MEM, WriteData, ForwardA, ForwardB, ALUA, ALUB, ALUop);
	input [15:0] instr, RegData1, RegData2, pcs; 	//ID data inputs
	input LdByte, MemOp;							//Control inputs
	input [15:0] alu_out_MEM, WriteData;			//Forwarded inputs
	input [2:0] ForwardA, ForwardB;					//forward control inputs
	output [15:0] ALUA, ALUB;
	output [4:0] ALUop;

	wire A, B, C, D;
	assign {A, B, C, D} = instr[15:12];

	/* usage chart
	add		CLA
	SUB		cla
	red		cla
	xor		xor
	sll		shifter
	sra		shifter
	ror		shifter
	paddsb	cla
	lw		cla
	sw		cla
	lhb		cla
	llb		cla
	b		x
	br		x
	pcs		cla
	hlt		x
	*/

	////////////////////////////////////////////////////////////////////////////

	////Internal control signals, used for formatting data for alu to use///////
	//do we need the immediate?
	//1 for shift fns, lw, sw, llb, Lhb
	//0 for arith fns, pcs
	//x for b, br, hlt
	wire UseImm, ByteSelect, pcs_select;
	assign UseImm = (A & ~B) | (B & ~C) | (~A & B & ~D);

	//Whether to format for LLB or LHB
	//1 for llb, 0 for lhb
	assign ByteSelect = D;

	// is it a pcs instr?
	assign pcs_select = A & B;

	///////////////////////////////////////////////////////////////////////////

	/////External control signals, used by alu for knowing which arithmetic
	//function to perform///////
	wire sat, red, sub;
	wire [1:0] shiftop, outputSelect;
	//sat is for PADDSB
	//needs to be 1 for paddsb, 0 for other cla functions, x for shifter/xor/xs
	assign sat = ~A & B;
	//red is for RED
	//needs to be 1 for red, 0 for other cla functions, x for shifter/xor/xs
	assign red = ~A & ~B & C;
	//sub is for SUB
	//needs to be 1 for sub, 0 for other cla fns, x for shifter/xor/xs
	assign sub = ~A & ~B & D;

	//shift op is last two bits of instruction
	assign shiftop = instr[1:0];

	//aluSelect : tell alu which result to output
	//00 for cla
	//01 for xor
	//10 for shifter
	assign outputSelect[1] = ~A & B & (~C | ~D);
	assign outputSelect[0] = ~A & ~B & C & D;

	//coalesce
	assign ALUop = {outputSelect, sat, red, sub, shiftop};

	///////////////////////////////////////////////////////////////////////////

	/////Data outputs, directly go to alu inputs/////
	wire [15:0] RegDataA, RegDataB_raw, RegDataB, loadedByte, imm_mem, imm;

	//A mux nice tree
	assign RegDataA = ForwardA[1] ? alu_out_MEM :
					  ForwardA[0] ? WriteData :
									RegData1;
	//Have to force data to 0 for pcs due to x's in pcs ISA
	assign ALUA = pcs_select ? 16'h0000 : RegDataA;



	//B Mux hell tree
	//Decide which byte we would load to, format data
	assign loadedByte = ByteSelect ? {8'h00, instr[7:0]} : {instr[7:0], 8'h00};
	//shift immedate if memory operation, sign extend either way
	assign imm_mem = MemOp ? {{11{instr[3]}}, instr[3:0], 1'b0} :
							 {{12{instr[3]}}, instr[3:0]};
	//Choose loaded byte if llb or lhb, else choose the memory formatted imm
	assign imm = LdByte ? loadedByte : imm_mem;
	//Get the right register data from forwarding unit
	assign RegDataB_raw = ForwardB[1] ? alu_out_MEM :
						  ForwardB[0] ? WriteData :
										RegData1;
	//Invert register data if sub operation
	assign RegDataB = sub ?  ~RegDataB_raw : RegDataB_raw;
	//Replace all that crap with pcs if its a pcs instruction
	assign ALUB = pcs_select ? pcs : RegDataB;

endmodule
