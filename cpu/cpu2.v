module cpu(clk, rst_n, pc, hlt);

    input clk, rst_n;
    output [15:0] pc;
    output hlt;

    // GLOBAL SIGNALS
    wire rst;
    assign rst = ~rst_n;

    // IF SIGNALS
	wire [15:0] instr_IF, pc_next_IF;

    // ID SIGNALS
	wire [15:0] instr_ID, pc_next_ID;
	wire [15:0] RegData1_ID, RegData2_ID;

	// control signals
	wire RegSrc_ID, RegWrite_ID, MemOp_ID, MemWrite_ID, ALUSrc_ID;
	wire [1:0] ImmSize_ID, BranchSrc_ID, DataSrc_ID;
	wire [15:0] imm_ID;

    // EX SIGNALS
	wire cond_true;
	wire [15:0] pc_next_EX, alu_out_EX;

	// control signals
	wire MemOp_EX, MemWrite_EX;
	wire[1:0] DataSrc_EX;

    // MEM SIGNALS
	wire [15:0] pc_next_MEM, alu_out_MEM, RegData2_MEM, mem_out_MEM;

	// control signals
	wire MemOp_MEM, MemWrite_MEM;
	wire[1:0] DataSrc_MEM;

    // WB SIGNALS
	wire [15:0] pc_next_WB, mem_out_WB, WriteData;

	// control signals
	wire[1:0] DataSrc_WB;



///////////////////////////////////////IF///////////////////////////////////////
	fetch IF(.clk(clk), .rst(rst), .pc_next(pc_next_IF), .pc(pc), .instr(instr_IF));

	PC_control PCC(.cond_true(cond_true), .imm(imm), .RegData1(RegData1),
		.BranchSrc(BranchSrc), .hlt(hlt), .pc(pc), .pc_next(pc_next)); // TODO FIX THIS
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_IF_ID(.clk(clk), .rst(rst) .enable(/*TODO: hazard unit*/)
		.signals_in({instr_IF, pc_next_IF})
		.signals_out({instr_ID, pc_next_ID})
	);

///////////////////////////////////////ID///////////////////////////////////////
	Control ctrl(.op(instr_ID[15:12]), .RegSrc(RegSrc_ID), .MemOp(MemOp_ID),
		.MemWrite(MemWrite_ID), .ALUSrc(ALUSrc_ID), .RegWrite(RegWrite_ID), .hlt(hlt_ID),
		.ImmSize(ImmSize_ID), .BranchSrc(BranchSrc_ID), .DataSrc(DataSrc_ID));

	decode ID(.clk(clk), .rst(rst), .instr(instr_ID), .ImmSize(ImmSize_ID),
		.RegSrc(RegSrc_ID), .RegWrite(RegWrite_ID), .MemOp(MemOp_ID), .WriteData(WriteData),
		.imm(imm_ID), .RegData1(RegData1_ID), .RegData2(RegData2_ID));
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_ID_EX(.clk(clk), .rst(rst) .enable(/*TODO: hazard unit*/)
		.signals_in({instr_ID, pc_next_ID, RegData1_ID, RegData2_ID, ALUSrc_ID, imm_ID, MemOp_ID, MemWrite_ID})
		.signals_out({instr_EX, pc_next_EX, RegData1_EX, Regdata2_EX, ALUSrc_EX, imm_EX, MemOp_EX, MemWrite_EX})
	);

///////////////////////////////////////EX///////////////////////////////////////

	execute EX(.clk(clk), .rst(rst), .instr(instr_EX), .ALUSrc(ALUSrc_EX), .imm(imm_EX),
		.RegData1(RegData1_EX), .RegData2(RegData2_EX), .alu_out(alu_out_EX),
		.cond_true(cond_true));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_EX_MEM(.clk(clk), .rst(rst) .enable(/*TODO: hazard unit*/)
		.signals_in({pc_next_EX, alu_out_EX, RegData2_EX, MemOp_MEM, MemWrite_MEM})
		.signals_out({pc_next_MEM, alu_out_MEM, RegData2_MEM, MemOp_MEM, MemWrite_MEM})
	);


///////////////////////////////////////MEM//////////////////////////////////////

	memory MEM(.clk(clk), .rst(rst), .alu_out(alu_out_MEM), .RegData2(RegData2_MEM),
	 .MemOp(MemOp_MEM), .MemWrite(MemWrite_MEM), .mem_out(mem_out_MEM));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_MEM_WB(.clk(clk), .rst(rst) .enable(/*TODO: hazard unit*/)
		.signals_in({pc_next_MEM, mem_out_MEM, DataSrc_MEM})
		.signals_out({pc_next_WB, mem_out_WB, DataSrc_WB})
	);

///////////////////////////////////////WB///////////////////////////////////////

	writeback WB(.alu_out(alu_out), .mem_out(mem_out), .imm(imm),
		.pc_next(pc_next_WB), .DataSrc(DataSrc_WB), .WriteData(WriteData));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

endmodule


module PipelineReg(clk, rst, enable, signals_in, signals_out);

	input clk;
	input rst;
	input enable;
	input [69:0] signals_in;
	output [69:0] signals_out;

	dff ff00(signals_out[00], signals_in[00], enable, clk, rst);
	dff ff01(signals_out[01], signals_in[01], enable, clk, rst);
	dff ff02(signals_out[02], signals_in[02], enable, clk, rst);
	dff ff03(signals_out[03], signals_in[03], enable, clk, rst);
	dff ff04(signals_out[04], signals_in[04], enable, clk, rst);
	dff ff05(signals_out[05], signals_in[05], enable, clk, rst);
	dff ff06(signals_out[06], signals_in[06], enable, clk, rst);
	dff ff07(signals_out[07], signals_in[07], enable, clk, rst);
	dff ff08(signals_out[08], signals_in[08], enable, clk, rst);
	dff ff19(signals_out[09], signals_in[09], enable, clk, rst);
	dff ff10(signals_out[10], signals_in[10], enable, clk, rst);
	dff ff11(signals_out[11], signals_in[11], enable, clk, rst);
	dff ff12(signals_out[12], signals_in[12], enable, clk, rst);
	dff ff13(signals_out[13], signals_in[13], enable, clk, rst);
	dff ff14(signals_out[14], signals_in[14], enable, clk, rst);
	dff ff15(signals_out[15], signals_in[15], enable, clk, rst);
	dff ff16(signals_out[16], signals_in[16], enable, clk, rst);
	dff ff17(signals_out[17], signals_in[17], enable, clk, rst);
	dff ff18(signals_out[18], signals_in[18], enable, clk, rst);
	dff ff19(signals_out[19], signals_in[19], enable, clk, rst);
	dff ff20(signals_out[20], signals_in[20], enable, clk, rst);
	dff ff21(signals_out[21], signals_in[21], enable, clk, rst);
	dff ff22(signals_out[22], signals_in[22], enable, clk, rst);
	dff ff23(signals_out[23], signals_in[23], enable, clk, rst);
	dff ff24(signals_out[24], signals_in[24], enable, clk, rst);
	dff ff25(signals_out[25], signals_in[25], enable, clk, rst);
	dff ff26(signals_out[26], signals_in[26], enable, clk, rst);
	dff ff27(signals_out[27], signals_in[27], enable, clk, rst);
	dff ff28(signals_out[28], signals_in[28], enable, clk, rst);
	dff ff29(signals_out[29], signals_in[29], enable, clk, rst);
	dff ff30(signals_out[30], signals_in[30], enable, clk, rst);
	dff ff31(signals_out[31], signals_in[31], enable, clk, rst);
	dff ff32(signals_out[32], signals_in[32], enable, clk, rst);
	dff ff33(signals_out[33], signals_in[33], enable, clk, rst);
	dff ff34(signals_out[34], signals_in[34], enable, clk, rst);
	dff ff35(signals_out[35], signals_in[35], enable, clk, rst);
	dff ff36(signals_out[36], signals_in[36], enable, clk, rst);
	dff ff37(signals_out[37], signals_in[37], enable, clk, rst);
	dff ff38(signals_out[38], signals_in[38], enable, clk, rst);
	dff ff39(signals_out[39], signals_in[39], enable, clk, rst);
	dff ff40(signals_out[40], signals_in[40], enable, clk, rst);
	dff ff41(signals_out[41], signals_in[41], enable, clk, rst);
	dff ff42(signals_out[42], signals_in[42], enable, clk, rst);
	dff ff43(signals_out[43], signals_in[43], enable, clk, rst);
	dff ff44(signals_out[44], signals_in[44], enable, clk, rst);
	dff ff45(signals_out[45], signals_in[45], enable, clk, rst);
	dff ff46(signals_out[46], signals_in[46], enable, clk, rst);
	dff ff47(signals_out[47], signals_in[47], enable, clk, rst);
	dff ff48(signals_out[48], signals_in[48], enable, clk, rst);
	dff ff49(signals_out[49], signals_in[49], enable, clk, rst);
	dff ff50(signals_out[50], signals_in[50], enable, clk, rst);
	dff ff51(signals_out[51], signals_in[51], enable, clk, rst);
	dff ff52(signals_out[52], signals_in[52], enable, clk, rst);
	dff ff53(signals_out[53], signals_in[53], enable, clk, rst);
	dff ff54(signals_out[54], signals_in[54], enable, clk, rst);
	dff ff55(signals_out[55], signals_in[55], enable, clk, rst);
	dff ff56(signals_out[56], signals_in[56], enable, clk, rst);
	dff ff57(signals_out[57], signals_in[57], enable, clk, rst);
	dff ff58(signals_out[58], signals_in[58], enable, clk, rst);
	dff ff59(signals_out[59], signals_in[59], enable, clk, rst);
	dff ff60(signals_out[60], signals_in[60], enable, clk, rst);
	dff ff61(signals_out[61], signals_in[61], enable, clk, rst);
	dff ff62(signals_out[62], signals_in[62], enable, clk, rst);
	dff ff63(signals_out[63], signals_in[63], enable, clk, rst);
	dff ff64(signals_out[64], signals_in[64], enable, clk, rst);
	dff ff65(signals_out[65], signals_in[65], enable, clk, rst);
	dff ff66(signals_out[66], signals_in[66], enable, clk, rst);
	dff ff67(signals_out[67], signals_in[67], enable, clk, rst);
	dff ff68(signals_out[68], signals_in[68], enable, clk, rst);
	dff ff69(signals_out[69], signals_in[69], enable, clk, rst);
	// coulda did this way more easily and with fewer errors with a generate statement





endmodule
