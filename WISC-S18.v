module WISC_S18(clk, rst);
  input clk, rst;

  Register PC(.clk(clk), .rst(rst), .)
