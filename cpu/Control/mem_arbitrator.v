module mem_arbitrator();

	input icache_rq
	input dcache_rq;

	output permit_icache;
	output permit_dcache;

	assign permit_icache = icache_rq;
	assign permit_dcache = ~icache_rq & dcache_rq;

endmodule
