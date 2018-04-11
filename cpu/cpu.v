module cpu(clk, rst_n, pc, hlt);

    input clk, rst_n;
    output [15:0] pc;
    output hlt;

    // GLOBAL SIGNALS
    wire rst;
    assign rst = ~rst_n;

    /////////////////////////// IF SIGNALS/////////////////////////////
	wire [15:0] instr_IF, pc_next_IF;

    ///////////////////////// ID SIGNALS/////////////////////////////
	wire [15:0] instr_ID, pc_next_ID;
	wire [15:0] RegData1_ID, RegData2_ID;

	// control signals
	wire RegSrc_ID, RegWrite_ID, MemOp_ID, MemWrite_ID, ALUSrc_ID;
	wire [1:0] ImmSize_ID, BranchSrc_ID, DataSrc_ID;
	wire [15:0] imm_ID;

    ///////////////// EX SIGNALS////////////////////////////////////
	wire cond_true;
	wire [15:0] instr_EX, pc_next_EX, alu_out_EX;
	wire [2:0] NVZ;

	//Forwarding Signals
	wire [3:0] Rd_EX;
	wire [1:0] ForwardA, ForwardB;

	// control signals
	wire MemOp_EX, MemWrite_EX, RegWrite_EX;
	wire[1:0] DataSrc_EX;

    ///////////////// MEM SIGNALS//////////////////////////////////////
	wire [15:0] pc_next_MEM, alu_out_MEM, RegData2_MEM, mem_out_MEM;
	wire [3:0] Rd_MEM; //Forwarding

	// control signals
	wire MemOp_MEM, MemWrite_MEM, RegWrite_MEM;
	wire[1:0] DataSrc_MEM;

    //////////////////////////// WB SIGNALS///////////////////////////
	wire [15:0] pc_next_WB, mem_out_WB, WriteData;
	wire [3:0] Rd_WB; //Forwarding

	// control signals
	wire[1:0] DataSrc_WB;
	wire RegWrite_WB;



///////////////////////////////////////IF///////////////////////////////////////
	fetch IF(.clk(clk), .rst(rst), .pc_next(pc_next_IF), .pc(pc), .instr(instr_IF));

	PC_control PCC(.cond_true(cond_true), .imm(imm), .RegData1(RegData1),
		.BranchSrc(BranchSrc), .hlt(hlt), .pc(pc), .pc_next(pc_next)); // TODO FIX THIS
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_IF_ID(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({instr_IF, pc_next_IF}),
		.signals_out({instr_ID, pc_next_ID})
	);

///////////////////////////////////////ID///////////////////////////////////////
	Control ctrl(.op(instr_ID[15:12]), .RegSrc(RegSrc_ID), .MemOp(MemOp_ID),
		.MemWrite(MemWrite_ID), .ALUSrc(ALUSrc_ID), .RegWrite(RegWrite_ID), .hlt(hlt_ID),
		.ImmSize(ImmSize_ID), .BranchSrc(BranchSrc_ID), .DataSrc(DataSrc_ID));

	CCodeEval ccc(.C(instr_ID[11:8], .NVZ(NVZ), .cond_true(cond_true)));

	decode ID(.clk(clk), .rst(rst), .instr(instr_ID), .ImmSize(ImmSize_ID),
		.RegSrc(RegSrc_ID), .RegWrite(RegWrite_ID), .MemOp(MemOp_ID), .WriteData(WriteData),
		.imm(imm_ID), .RegData1(RegData1_ID), .RegData2(RegData2_ID));
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_ID_EX(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({instr_ID, pc_next_ID, DataSrc_ID, RegWrite_ID, RegData1_ID, RegData2_ID, ALUSrc_ID, 
			imm_ID, MemOp_ID, MemWrite_ID}),
		.signals_out({instr_EX, pc_next_EX, DataSrc_EX, RegWrite_EX, RegData1_EX, Regdata2_EX, ALUSrc_EX, 
			imm_EX, MemOp_EX, MemWrite_EX})
	);

///////////////////////////////////////EX///////////////////////////////////////

	execute EX(.clk(clk), .rst(rst), .instr(instr_EX), .ALUSrc(ALUSrc_EX), .imm(imm_EX),
		.RegData1(RegData1_EX), .RegData2(RegData2_EX), .alu_out(alu_out_EX),
		.cond_true(cond_true), .ForwardA(ForwardA), .ForwardB(ForwardB), 
		.alu_out_MEM(alu_out_MEM), .WriteData(WriteData));

	ForwardingUnit fwu(.exmemWR(Rd_MEM), .memwbWR(Rd_WB), .idexRs(instr_EX[7:4]), 
		.idexRt(instr_EX[3:0]), .RegWrite_MEM(RegWrite_MEM), .RegWrite_WB(RegWrite_WB),
		.ForwardA(ForwardA), .ForwardB(ForwardB));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_EX_MEM(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({pc_next_EX, DataSrc_EX, alu_out_EX, RegData2_EX, MemOp_EX, MemWrite_EX, 
			RegWrite_EX, instr_EX[11:8]}),
		.signals_out({pc_next_MEM, DataSrc_MEM, alu_out_MEM, RegData2_MEM, MemOp_MEM, MemWrite_MEM, 
			RegWrite_MEM, Rd_MEM})
	);


///////////////////////////////////////MEM//////////////////////////////////////

	memory MEM(.clk(clk), .rst(rst), .alu_out(alu_out_MEM), .RegData2(RegData2_MEM),
	 .MemOp(MemOp_MEM), .MemWrite(MemWrite_MEM), .mem_out(mem_out_MEM));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_MEM_WB(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({alu_out_MEM, pc_next_MEM, mem_out_MEM, DataSrc_MEM, RegWrite_MEM, Rd_MEM}),
		.signals_out({alu_out_WB, pc_next_WB, mem_out_WB, DataSrc_WB, RegWrite_WB, Rd_WB})
	);

///////////////////////////////////////WB///////////////////////////////////////

	writeback WB(.alu_out(alu_out_WB), .mem_out(mem_out), .imm(imm),
		.pc_next(pc_next_WB), .DataSrc(DataSrc_WB), .WriteData(WriteData));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

endmodule
