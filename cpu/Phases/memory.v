module memory(clk, rst, alu_out, RegData2, MemOp, MemWrite, mem_out, stall,
	service, data_from_mem, data_valid, addr_to_mem, fsm_busy);

	input clk, rst;
	input MemOp, MemWrite;
	input [15:0] alu_out, RegData2;
	output [15:0] mem_out;
	output stall;

	//Signals to arbitrator
	input service, data_valid;
	input [15:0] data_from_mem;
	output [15:0] addr_to_mem;
	output fsm_busy;



	// memory1c DMem(.data_out(mem_out), .data_in(RegData2), .addr(alu_out),
	// .enable(MemOp), .wr(MemWrite), .clk(clk), .rst(rst));

	Cache_Controller Dmem(.clk(clk), .rst(rst), .write(MemWrite), .op(MemOp),
		.address_in(alu_out), .data_out(mem_out), .data_in(RegData2), .stall(stall),
		.service(service), .data_from_mem(data_from_mem), .data_valid(data_valid), 
		.addr_to_mem(addr_to_mem), .fsm_busy(fsm_busy));


endmodule
