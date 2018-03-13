  
module cpu(clk, rst, pc, hlt);
  input clk, rst;
  output [15:0] pc;
  output hlt;

  //Control wires
  //TODO: write and tests control unit
  wire RegDest, Jump, Branch, MemRead, MemtoReg, ALUOP, MemWrite, ALUSrc, RegWrite;
  wire [15:0] WriteData;
  /////////////////////////IF//////////////////////////////////////////////////
  wire [15:0] pc_in, pc, pc_inc;
  Register PC(.clk(clk), .rst(rst), .D(pc_in), .WriteReg(1'b1),
    .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc), .Bitline2());

  CLA_16bit pc_incrementor(.A(pc), .B(16'h0004), .cin(1'b0), .cout(),
    .S(pc_inc), .sat(1'b0), .red(1'b0));

  wire [15:0] instr;
  memory Imem(.data_out(instr), .data_in(), .addr(pc), .enable(1'b1),
    .wr(1'b0), .clk(clk), .rst(rst));
  ////////////////////////////////ID///////////////////////////////////////////
  wire [3:0] DstReg;
  wire [15:0] RegData1, RegData2;
  wire [15:0] immSE; //Unnecessary? Immediate logic
  assign immSE = {{7{instr[8]}}, instr[8:0]};
  assign DstReg = RegDst ? instr[3:0] : instr[7:4];
  RegisterFile Regs(.clk(clk), .rst(rst), .SrcReg1(instr[11:8]),
    .SrcReg2(instr[7:4]), .DstReg(DstReg), .WriteReg(RegWrite),
    .DstData(WriteData), .SrcData1(RegData1), .SrcReg2(RegData2));
  /////////////////////////////////EX////////////////////////////////////////////
  wire [15:0] alu_in, alu_out;
  wire alu_ovfl;
  assign alu_in = ALUSrc ? immSE : RegData2;
  ALU alu(.A(SrcData1), .B(alu_in), .op(ALUOP), .out(alu_out), .ovfl(alu_ovfl));

  wire [15:0] branch_dest;
  CLA_16bit branch_adder(.A(pc_inc), .B(immSE << 1), .cin(1'b0), .cout(),
    .S(branch_dest), .sat(1'b0), .red(1'b0));

  wire conditionCode;
  CCodeEval ccc(.clk(clk), .rst(rst), .instr(instr), .alu_out(alu_out),
    .alu_ovfl(alu_ovfl), .out(conditionCode));
  ///////////////////////////////////MEM/////////////////////////////////////////
  wire [15:0] mem_out;
  memory DMem(.data_out(mem_out), .data_in(RegData2), .addr(alu_out),
    .enable(MemRead), .wr(MemWrite), .clk(clk), .rst(rst));
  ///////////////////////////////////WB//////////////////////////////////////////
  assign WriteData = MemtoReg ? mem_out : alu_out;

  wire [15:0] pc_branch;
  wire conditionCode; //TODO: implement condition codes
  assign pc_branch = (Branch & conditionCode) ? branch_dest : pc_inc;

  assign pc_in = Jump ? {pc_inc[15:14], (instr[8:0] << 1)};

endmodule
