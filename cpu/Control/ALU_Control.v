module ALU_Control(instr, RegData1, RegData2, pcs, LdByte, MemOp,
	alu_out_MEM, WriteData, ForwardA, ForwardB, ALUA, ALUB, ALUop);
	input [15:0] instr, RegData1, RegData2, pcs; 	//ID data inputs
	input LdByte, MemOp;							//Control inputs
	input [15:0] alu_out_MEM, WriteData;			//Forwarded inputs
	input [1:0] ForwardA, ForwardB;					//forward control inputs
	output [15:0] ALUA, ALUB;
	output [6:0] ALUop;

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
	assign shiftop = instr[13:12];

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
	//Intermediate signals for ALUA and ALUB
	wire [15:0] RegDataA_raw, RegDataA_mem, RegDataA, loadedByteA;
	wire [15:0] RegDataB, loadedByteB, imm_mem, imm, imm_or_RegB;

	//A mux tree
	//Get right register data from forwarding unit
	assign RegDataA_raw = ForwardA[1] ? alu_out_MEM :
						  ForwardA[0] ? WriteData :
										RegData1;
	assign RegDataA_mem = MemOp ? (RegDataA_raw & 0xFFFE : RegDataA_raw);


	//Zero proper byte of RegData for LLB/LHB (opposite byte of B)
	assign loadedByteA = ByteSelect ? {RegDataA_raw[15:8], 8'h00} :
									  {8'h00, RegDataA_raw[7:0]};
	//Ignore lsb for memory operations
	assign RegDataA_mem = MemOp ? (RegDataA_raw & 0xFFFE) : RegDataA_raw;
	//Choose loaded byte if LLB/LHB, else choose unformatted reg data
	assign RegDataA = LdByte ? loadedByteA : RegDataA_mem;
	//Have to force data to 0 for pcs due to x's in pcs ISA
	assign ALUA = pcs_select ? 16'h0000 : RegDataA;



	//B Mux tree
	//Decide which byte to load to, format data
	assign loadedByteB = ByteSelect ? {8'h00, instr[7:0]} : {instr[7:0], 8'h00};
	//shift immedate if memory operation, sign extend either way
	assign imm_mem = MemOp ? {{11{instr[3]}}, instr[3:0], 1'b0} :
							 {{12{instr[3]}}, instr[3:0]};
	//Choose loaded byte if llb or lhb, else choose the memory formatted imm
	assign imm = LdByte ? loadedByteB : imm_mem;
	//Get the right register data from forwarding unit
	assign RegDataB = ForwardB[1] ? alu_out_MEM :
					  ForwardB[0] ? WriteData :
									RegData2;
	//Choose between immediate and register data
	assign imm_or_RegB = UseImm ? imm : RegDataB;

	//Replace all that crap with pcs if its a pcs instruction
	assign ALUB = pcs_select ? pcs : imm_or_RegB;

endmodule
