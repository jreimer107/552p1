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
	MemOp_MEM,
	write
);

	input clk, rst;
	input [15:0] data_out, data_in;
	input [15:0] iaddr, daddr;
	input irequest, drequest;
	output iservice, dservice;
	output data_valid;
	input MemOp_MEM, write;

	wire [15:0] addr;
	assign addr = iservice ? iaddr : daddr; // stores always come from dcache
	assign iservice = irequest;
	assign dservice = ~irequest & drequest;
					  	
	memory4c mem(
		.clk(clk),
		.rst(rst),
		.data_out(data_out),
		.data_in(data_in),
		.addr(addr),
		.enable(MemOp_MEM | irequest),
		.wr(write & ~irequest & ~drequest),
		.data_valid(data_valid)
	);
	



endmodule
