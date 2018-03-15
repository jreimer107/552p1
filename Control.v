module Control(op, RegDest, MemRead, MemWrite, ALUSrc, RegWrite, ImmSize,
	BranchSrc, DataSrc);
  input [3:0] op;
  output RegDest, MemRead, MemWrite, ALUSrc, RegWrite;
  output [1:0] ImmSize, DataSrc, BranchSrc;

  /*
  localparam  ADD = 4'b0000;  //CLA
  localparam  SUB = 4'b0001;  //CLA
  localparam  RED = 4'b0010;  //CLA
  localparam  XOR = 4'b0011;
  localparam  SLL = 4'b0100;
  localparam  SRA = 4'b0101;
  localparam  ROR = 4'b0110;
  localparam  PADDSB = 4'b0111; //CLA
  localparam  LW = 4'b1000;
  localparam  SW = 4'b1001;
  localparam  LHB = 4'b1010;
  localparam  SHB = 4'b1011;
  localparam  B = 4'b1100;
  localparam  BR = 4'b1101;
  localparam  PCS = 4'b1110;
  localparam  HLT = 4'b1111;
  */

  //TODO:
  	//RegDest X
	//MemRead X
	//MemWrite X
	//ALUSrc X
	//RegWrite X
	//ImmSize X
	//DataSrc X
	//BranchSrc X


  wire ADD, SUB, RED, XOR, SLL, SRA, ROR, PADDSB, LW, SW, LHB, SHB, B, BR, PCS,
    HLT;
  assign ADD = (op == 4'b0000);
  assign SUB = (op == 4'b0001);
  assign RED = (op == 4'b0010);
  assign XOR = (op == 4'b0011);
  assign SLL = (op == 4'b0100);
  assign SRA = (op == 4'b0101);
  assign ROR = (op == 4'b0110);
  assign PADDSB = (op == 4'b0111);
  assign LW = (op == 4'b1000);
  assign SW = (op == 4'b1001);
  assign LHB = (op == 4'b1010);
  assign LLB = (op == 4'b1011);
  assign B = (op == 4'b1100);
  assign BR = (op == 4'b1101);
  assign PCS = (op == 4'b1110);
  assign HLT = (op == 4'b1111);


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
  assign RegDest = SW;

  //MEMREAD//
  assign MemRead = LW;
  assign MemWrite = SW;

  //ALUSrc//
  //Do we need the immediate?
  assign ALUSrc = (SLL || SRA || ROR || (op[3] && ~op[2]));

  //REGWRITE//
  //ARITH, SHIFT, LW, LHB, LLB, and PCS write to register.
  //all 0xxx, 1000 and 1010.
  assign RegWrite = (!op[3] || LW || LHB || LLB || PCS);

  //IMMSIZE//
  //immediate of size 4 for shift and LW/SW
  //size 8 for LHB/SHB
  //size 9 for B (not thru alu)
  //ImmSize 00 for 4, 01 for 8, 1x for 9.
  //Used to sign extend immediate to 16bit value.
  assign ImmSize = (SRA || SLL || ROR || LW || SW) ? 2'b00 :
    (LHB || LLB) ? 2'b01 : 2'b1x;

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
  //01 if data from ALU
  //1x if data from PC
  assign DataSrc = (op[3] && ~op[2]) ? 2'b00 :
  				   PCS ? 2'b1x :
				   		 2'b01;
endmodule
