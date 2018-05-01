module 	mem_arbitrator(
	clk,
	rst,
	data_out,
	data_in, // only one, as icache never writes to mem
	iaddr,
	daddr,
	irequest,
	drequest,
	iservice,
	dservice,
	data_valid,
	enable,
	write
);

	input clk, rst;
	input [15:0] data_out, data_in;
	input [15:0] iaddr, daddr;
	output [15:0] addr_out;
	input irequest, drequest;
	output iservice, dservice;
	output data_valid;

	wire addr;
	assign addr = iservice ? iaddr : daddr; // stores always come from dcache
	assign iservice = irequest;
	assign dservice = ~irequest & drequest;
					  	
	memory4c mem(
		.clk(clk),
		.rst(rst),
		.data_out(data_out),
		.data_in(data_in),
		.addr(addr),
		.enable(enable),
		.wr(write),
		.data_valid(data_valid)
	);
	



endmodule
