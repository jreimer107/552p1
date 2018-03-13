module cpu(clk, rst, pc, hlt);
  input clk, rst;
  output [15:0] pc;
  output hlt;

  wire [15:0] pc_in, pc;

  /////////////////////////IF//////////////////////////////////////////////////
  Register PC(.clk(clk), .rst(rst), .D(pc_in), .WriteReg(1'b1),
    .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc), .Bitline2());


  /////////////////////////////////////////////////////////////////////////////

  wire [15:0] instruction;
  memory Imem(.data_out(instruction), .data_in(), .addr(pc), .enable(1'b1),
    .wr(1'b0), .clk(clk), .rst(rst));
