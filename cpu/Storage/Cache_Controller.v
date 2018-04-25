module CacheController(clk, rst, address_in, data_in, data_out, stall);
	input clk, rst;
	input [15:0] address_in, data_in;
	output stall;

	wire [15:0] data_bus;
	wire Data_Write;

	//16b address
	//16B data -> 4b offset
	//128 lines -> 7b index
	//16b-4b-7b -> 5b tag

	//7:128 decoder
	

	DataArray data(.clk(clk), .rst(rst), .DataIn(data_bus), .Write(Data_Write), .BlockEnable)

endmodule

module 7_128Decoder(in, out);
	input [6:0] in;
	output [127:0] out;