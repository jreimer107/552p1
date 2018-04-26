module cpu(clk, rst_n, pc, hlt);
    input clk, rst_n;
    output [15:0] pc;
    output hlt;

    // GLOBAL SIGNALS
    wire rst;
    assign rst = ~rst_n;

    /////////////////////////// IF SIGNALS/////////////////////////////
	wire [15:0] instr_IF, pcs_IF;
	wire [15:0] NOP_or_instr_IF;

    ///////////////////////// ID SIGNALS/////////////////////////////
	wire [15:0] instr_ID, pc_branch, pcs_ID;
	wire [15:0] RegData1_ID, RegData2_ID;
	wire [3:0] SrcReg1_ID, SrcReg2_ID;		//Inputs for forwarding unit

	// control signals
	wire RegSrc, RegWrite_ID, MemOp_ID, MemWrite_ID, LdByte_ID,
		Branch, BranchSrc, hlt_ID, DataSrc_ID;

    ///////////////// EX SIGNALS////////////////////////////////////
	wire cond_true;
	wire [15:0] instr_EX, pcs_EX, alu_out_EX, RegData1_EX, RegData2_EX;
	wire [2:0] NVZ;
	wire [3:0] SrcReg1_EX, SrcReg2_EX;	//Inputs for forwarding unit

	//Forwarding Signals
	wire [1:0] ForwardA, ForwardB;

	// control signals
	wire LdByte_EX, MemOp_EX, MemWrite_EX, RegWrite_EX, hlt_EX, DataSrc_EX;

    ///////////////// MEM SIGNALS//////////////////////////////////////
	wire [15:0] alu_out_MEM, RegData2_MEM, mem_out_MEM;
	wire [3:0] Rd_MEM; //Forwarding


	// control signals
	wire MemOp_MEM, MemWrite_MEM, RegWrite_MEM, hlt_MEM, DataSrc_MEM;

    //////////////////////////// WB SIGNALS///////////////////////////
	wire [15:0] alu_out_WB, mem_out_WB, WriteData;
	wire [3:0] Rd_WB; //Forwarding

	// control signals
	wire DataSrc_WB, RegWrite_WB, hlt_WB;
	assign hlt = hlt_WB;


///////////////////////////////////////IF///////////////////////////////////////
	fetch IF(.clk(clk), .rst(rst), .pc_branch(pc_branch),
		.branch(cond_true & Branch), .stop(hlt_WB | bubble), .instr(instr_IF),
		.pc(pc), .pcs(pcs_IF));

	HazardDetection HZD(.instr_IF(instr_IF), .instr_ID(instr_ID),
		.MemOp_ID(MemOp_ID), .MemWrite_ID(MemWrite_ID), .bubble(bubble),
		.NOP_or_instr_IF(NOP_or_instr_IF));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/


	PLR_IFID plr_IF_ID(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({NOP_or_instr_IF, pcs_IF}),
		.signals_out({instr_ID, pcs_ID})
	);


///////////////////////////////////////ID///////////////////////////////////////
	Control ctrl(.op(instr_ID[15:12]), .RegSrc(RegSrc), .MemOp(MemOp_ID),
		.MemWrite(MemWrite_ID), .RegWrite(RegWrite_ID), .hlt(hlt_ID),
		.BranchSrc(BranchSrc), .Branch(Branch), .DataSrc(DataSrc_ID),
		.LdByte(LdByte_ID));

	CCodeEval ccc(.C(instr_ID[11:9]), .NVZ(NVZ), .cond_true(cond_true));

	decode ID(.clk(clk), .rst(rst), .instr(instr_ID), .pcs(pcs_ID),
		.RegSrc(RegSrc), .RegWrite(RegWrite_WB), .DstReg(Rd_WB),
		.WriteData(WriteData), .BranchSrc(BranchSrc), .SrcReg1(SrcReg1_ID), 
		.SrcReg2(SrcReg2_ID), .RegData1(RegData1_ID), .RegData2(RegData2_ID), 
		.pc_branch(pc_branch), .LdByte(LdByte_ID));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PLR_IDEX plr_ID_EX(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({instr_ID, pcs_ID, SrcReg1_ID, SrcReg2_ID, DataSrc_ID, 
			RegWrite_ID, RegData1_ID, RegData2_ID, MemOp_ID, MemWrite_ID, 
			LdByte_ID, hlt_ID}),
		.signals_out({instr_EX, pcs_EX, SrcReg1_EX, SrcReg2_EX, DataSrc_EX, 
			RegWrite_EX, RegData1_EX, RegData2_EX, MemOp_EX, MemWrite_EX, 
			LdByte_EX, hlt_EX})
	);

///////////////////////////////////////EX///////////////////////////////////////

	execute EX(.clk(clk), .rst(rst), .instr(instr_EX), .pcs(pcs_EX),
		.RegData1(RegData1_EX), .RegData2(RegData2_EX), .alu_out(alu_out_EX),
		.LdByte(LdByte_EX), .MemOp(MemOp_EX), .ForwardA(ForwardA),
		.ForwardB(ForwardB), .alu_out_MEM(alu_out_MEM), .WriteData(WriteData), .NVZ(NVZ));

		//might need to change to fit ldbyte
	ForwardingUnit fwu(.exmemWR(Rd_MEM), .memwbWR(Rd_WB), .idexRs(SrcReg1_EX),
		.idexRt(SrcReg2_EX), .RegWrite_MEM(RegWrite_MEM), .RegWrite_WB(RegWrite_WB),
		.ForwardA(ForwardA), .ForwardB(ForwardB));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PLR_EXMEM plr_EX_MEM(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({DataSrc_EX, alu_out_EX, RegData2_EX, MemOp_EX, MemWrite_EX,
			RegWrite_EX, instr_EX[11:8], hlt_EX}),
		.signals_out({DataSrc_MEM, alu_out_MEM, RegData2_MEM, MemOp_MEM,
			MemWrite_MEM, RegWrite_MEM, Rd_MEM, hlt_MEM})
	);


///////////////////////////////////////MEM//////////////////////////////////////

	memory MEM(.clk(clk), .rst(rst), .alu_out(alu_out_MEM), .RegData2(RegData2_MEM),
	 .MemOp(MemOp_MEM), .MemWrite(MemWrite_MEM), .mem_out(mem_out_MEM));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	PLR_MEMWB plr_MEM_WB(.clk(clk), .rst(rst), .enable(1'b1),
		.signals_in({alu_out_MEM, mem_out_MEM, DataSrc_MEM, RegWrite_MEM,
			Rd_MEM, hlt_MEM}),
		.signals_out({alu_out_WB, mem_out_WB, DataSrc_WB, RegWrite_WB, Rd_WB,
			hlt_WB})
	);

///////////////////////////////////////WB///////////////////////////////////////

	writeback WB(.alu_out(alu_out_WB), .mem_out(mem_out_WB),
		.DataSrc(DataSrc_WB), .WriteData(WriteData));

/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

endmodule
