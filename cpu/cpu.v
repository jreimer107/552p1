module cpu(clk, rst_n, pc, hlt);

    input clk, rst_n;
    output [15:0] pc;
    output hlt;

    // GLOBAL SIGNALS
    wire rst;
    assign rst = ~rst_n;

    /////////////////////////// IF SIGNALS/////////////////////////////
	wire [15:0] instr_IF, pcs_IF;

    ///////////////////////// ID SIGNALS/////////////////////////////
	wire [15:0] instr_ID, pc_branch, pcs_ID;
	wire [15:0] RegData1_ID, RegData2_ID, imm_ID;

	// control signals
	wire RegSrc_ID, RegWrite_ID, MemOp_ID, MemWrite_ID, ALUSrc_ID,
		Branch, BranchSrc;
	wire [1:0] ImmSize, DataSrc_ID;

    ///////////////// EX SIGNALS////////////////////////////////////
	wire cond_true;
	wire [15:0] instr_EX, pcs_EX, alu_out_EX, imm_EX, RegData1_EX, RegData2_EX;
	wire [2:0] NVZ;

	//Forwarding Signals
	wire [1:0] ForwardA, ForwardB;

	// control signals
	wire MemOp_EX, MemWrite_EX, RegWrite_EX;
	wire[1:0] DataSrc_EX;

    ///////////////// MEM SIGNALS//////////////////////////////////////
	wire [15:0] pcs_MEM, alu_out_MEM, RegData2_MEM, mem_out_MEM, imm_MEM;
	wire [3:0] Rd_MEM; //Forwarding

	// control signals
	wire MemOp_MEM, MemWrite_MEM, RegWrite_MEM;
	wire[1:0] DataSrc_MEM;

    //////////////////////////// WB SIGNALS///////////////////////////
	wire [15:0] pcs_WB, alu_out_WB, mem_out_WB, imm_WB, WriteData;
	wire [3:0] Rd_WB; //Forwarding

	// control signals
	wire[1:0] DataSrc_WB;
	wire RegWrite_WB;



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
	
	wire bubble;
	
	assign bubble = MemOp_ID && ~MemWrite_ID && 
		op7to0 ? (instr_ID[11:8] == instr_IF[7:4] || instr_ID[11:8] == instr_IF[3:0]) :
		op7to4 ? (instr_ID[11:8] == instr_IF[7:4]) : 
		op11to4 ? (instr_ID[11:8] == instr_IF[11:8] || instr_ID[11:8] == instr_IF[7:4]) : 
		op11to8 ? (instr_ID[11:8] == instr_IF[11:8]) : 
		1'b0;
	
		
	wire NOP_or_instr_IF;
	assign NOP_or_instr_IF = bubble ? 16'h0000 : instr_IF;


///////////////////////////////////////IF///////////////////////////////////////
	fetch IF(.clk(clk), .rst(rst), .pc_branch(pc_branch),
		.branch(cond_true & Branch), .stop(hlt | bubble), .instr(instr_IF),
		.pcs(pcs_IF));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/


	PLR_IFID plr_IF_ID(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({NOP_or_instr_IF, pcs_IF}),
		.signals_out({instr_ID, pcs_ID})


///////////////////////////////////////ID///////////////////////////////////////
	Control ctrl(.op(instr_ID[15:12]), .RegSrc(RegSrc_ID), .MemOp(MemOp_ID),
		.MemWrite(MemWrite_ID), .ALUSrc(ALUSrc_ID), .RegWrite(RegWrite_ID),
		.hlt(hlt_ID), .ImmSize(ImmSize), .BranchSrc(BranchSrc),
		.Branch(Branch), .DataSrc(DataSrc_ID));

	CCodeEval ccc(.C(instr_ID[11:9]), .NVZ(NVZ), .cond_true(cond_true));

	decode ID(.clk(clk), .rst(rst), .instr(instr_ID), .pc(pcs_ID),
		.ImmSize(ImmSize), .RegSrc(RegSrc_ID), .RegWrite(RegWrite_WB),
		.DstReg(Rd_WB), .WriteData(WriteData), .imm(imm_ID),
		.BranchSrc(BranchSrc), .RegData1(RegData1_ID), .RegData2(RegData2_ID),
		.pc_branch(pc_branch));
/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PLR_IDEX plr_ID_EX(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({instr_ID, pcs_ID, DataSrc_ID, RegWrite_ID, RegData1_ID,
			RegData2_ID, ALUSrc_ID, imm_ID, MemOp_ID, MemWrite_ID}),
		.signals_out({instr_EX, pcs_EX, DataSrc_EX, RegWrite_EX, RegData1_EX,
			RegData2_EX, ALUSrc_EX, imm_EX, MemOp_EX, MemWrite_EX})
	);

///////////////////////////////////////EX///////////////////////////////////////

	execute EX(.clk(clk), .rst(rst), .instr(instr_EX), .ALUSrc(ALUSrc_EX), .imm(imm_EX),
		.RegData1(RegData1_EX), .RegData2(RegData2_EX), .alu_out(alu_out_EX),
		.ForwardA(ForwardA), .ForwardB(ForwardB),
		.alu_out_MEM(alu_out_MEM), .WriteData(WriteData), .NVZ(NVZ));

	ForwardingUnit fwu(.exmemWR(Rd_MEM), .memwbWR(Rd_WB), .idexRs(instr_EX[7:4]),
		.idexRt(instr_EX[3:0]), .RegWrite_MEM(RegWrite_MEM), .RegWrite_WB(RegWrite_WB),
		.ForwardA(ForwardA), .ForwardB(ForwardB));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_EX_MEM(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({pcs_EX, DataSrc_EX, alu_out_EX, RegData2_EX, MemOp_EX, MemWrite_EX,
			RegWrite_EX, instr_EX[11:8], imm_EX}),
		.signals_out({pcs_MEM, DataSrc_MEM, alu_out_MEM, RegData2_MEM, MemOp_MEM, MemWrite_MEM,
			RegWrite_MEM, Rd_MEM, imm_MEM})
	);


///////////////////////////////////////MEM//////////////////////////////////////

	memory MEM(.clk(clk), .rst(rst), .alu_out(alu_out_MEM), .RegData2(RegData2_MEM),
	 .MemOp(MemOp_MEM), .MemWrite(MemWrite_MEM), .mem_out(mem_out_MEM));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PipelineReg plr_MEM_WB(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({alu_out_MEM, pcs_MEM, mem_out_MEM, DataSrc_MEM,
			RegWrite_MEM, Rd_MEM, imm_MEM}),
		.signals_out({alu_out_WB, pcs_WB, mem_out_WB, DataSrc_WB, RegWrite_WB,
			Rd_WB, imm_WB})
	);

///////////////////////////////////////WB///////////////////////////////////////

	writeback WB(.alu_out(alu_out_WB), .mem_out(mem_out_WB), .imm(imm_WB),
		.pcs(pcs_WB), .DataSrc(DataSrc_WB), .WriteData(WriteData));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

endmodule
