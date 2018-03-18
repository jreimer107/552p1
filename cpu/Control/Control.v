/* Control.v
* This module determines the statuses of control signals throughout the cpu.
* @input op is the opcode (bits 15:12) of the current instruction.
* @output RegSrc determines whether the ReadReg 2 input of the Register file
*	in the ID stage gets instr[11:8] (only for SW) or instr[3:0] (normal).
* @output RegWrite is a binary signal that determines if the Register specified
*	by the WriteReg input (instr[11:8]) to the register file should be written
*	to or not.
* @output MemRead signifies if data should be read from DMemory.
* @output MemWrite signifies if data should be written to DMemory.
* @output ALUSrc determines if the output RegData2 from the register file or
*	the supplied immediate should be forwarded to input B of the ALU.
* @output ImmSize specifies whether the given immediate should be sign extended
*	from 4, 8, or 9 bits.
* @output DataSrc specifies where the WriteData input to the register file comes
*	from: mem_out, alu_out, or pc_out.
* @output BranchSrc determines whether the next instruction address is taken
*	from pc_out, RegData2, or the supplied immediate.
*/
module Control(op, RegSrc, RegWrite, MemOp, MemWrite, ALUSrc, ImmSize,
	BranchSrc, DataSrc, hlt);
  input [3:0] op;
  output RegSrc, RegWrite, MemOp, MemWrite, ALUSrc, hlt;
  output [1:0] ImmSize, DataSrc, BranchSrc;

  wire ADD, SUB, RED, XOR, SLL, SRA, ROR, PADDSB, LW, SW, LHB, SHB, B, BR, PCS,
    HLT;

  wire shift, memory;

  assign ADD = 		(op == 4'b0000);
  assign SUB = 		(op == 4'b0001);
  assign RED = 		(op == 4'b0010);
  assign XOR = 		(op == 4'b0011);
  assign SLL = 		(op == 4'b0100);
  assign SRA = 		(op == 4'b0101);
  assign ROR = 		(op == 4'b0110);
  assign PADDSB = 	(op == 4'b0111);
  assign LW = 		(op == 4'b1000);
  assign SW = 		(op == 4'b1001);
  assign LHB = 		(op == 4'b1010);
  assign LLB = 		(op == 4'b1011);
  assign B = 		(op == 4'b1100);
  assign BR = 		(op == 4'b1101);
  assign PCS = 		(op == 4'b1110);
  assign HLT = 		(op == 4'b1111);

  assign shift = SLL || SRA || ROR;
  assign memory = (op[3] && ~op[2]);


  //HB/SLOT     0       1       2      3

  //ARITH:      opcode  rd,     rs,		rt
  //            0aaa    dddd    ssss	tttt
  //                    wr      rd1		rd2

  //SHIFT:      opcode  rd,     rs,     imm
  //            0aaa    dddd    ssss    iiii
  //                    wr      rd1     imm

  //LW/SW:      opcode  rt,     rs,     offset
  //            10aa    tttt    ssss    oooo
  //LW:                 wr      rd1     imm
  //SW:					rd2		rd1		imm

  //LHB/SHB:    opcode  rd,     imm
  //            101a    dddd    uuuu   uuuu
  //LHB:				wr		imm
  //LLB:				wr		imm

  //B:          B,      cond,   label
  //            opcode  ccci    iiii   iiii

  //BR          BR,     cond,   rs
  //            opcode  cccx    ssss   xxxx

  //PCS:        PCS     rd
  //            opcode  dddd    xxxx   xxxx

  //HLT:        opcode  xxxx    xxxx   xxxx

  //rd is WriteReg (instr[11:8])
  //rs is ReadReg1 (instr[7:4])
  //rt bounces around - need to mux between ReadReg1 and WriteReg.
  //slot
  //ccc always slot 1

  //REGDEST//
  //If SW, RdReg2 gets instr[11:8], else gets instr[3:0]
  //Sometimes slot 1 is destination reg, sometimes is rt.
  //0 if ReadReg2 gets slot 3, 1 if ReadReg2 gets slot 1
  //LLB and LHB read the current reg value and insert their immediate, so
  //they need access to the register they will be writing to.
  assign RegSrc = SW || LLB || LHB;

  //MEMREAD//
  assign MemOp = LW | SW;
  assign MemWrite = SW;

  //ALUSrc//
  //Do we need the immediate?
  assign ALUSrc = (shift || memory);

  //REGWRITE//
  //ARITH, SHIFT, LW, LHB, LLB, and PCS write to register.
  //all 0xxx, 1000 and 1010.
  assign RegWrite = (!op[3] || LW || LHB || LLB || PCS);

  //IMMSIZE//
  //immediate of size 4 for shift and LW/SW, SE to 16 (00)
  //size 9 for B, SE to 16 (01)
  //size 8 for LLB, arrange to be lower byte. (10)
  //size 8 for LHB, arrange to be higher byte (11)
  assign ImmSize = (shift || LW || SW) ? 2'b00 :
    B ? 2'b01 :
	LLB ? 2'b10 :
	LHB	? 2'b11 : 2'bxx;

  //BRANCHSRC//
  //If B, immediate used.
  //If BR, slot 2 data used.
  //Else pc_inc used.
  //0 for use pc_inc
  //1 for use immediate
  //2 for use RegData2.
  assign BranchSrc = B ? 2'b01 :
  					 BR ? 2'b1x :
					  	  2'b00;

  //DATASRC//
  //00 if data from MEMORY
  //01 if data from PC
  //10 if data from immediate
  //11 if data from ALU
  assign DataSrc = LW ? 2'b00 :
  				   PCS ? 2'b01 :
				   (LLB || LHB) ? 2'b10 :
				   		 2'b11;
  assign hlt = HLT;

endmodule
