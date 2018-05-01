module Cache_Controller(clk, rst, write, op, address_in, data_in, data_out, stall,
	service, data_from_mem, data_valid, addr_to_mem, miss_detected);
	input clk, rst;
	input write, op;
	input [15:0] address_in, data_in;
	output stall;
	output [15:0] data_out;

	//Signals to/from arbitrator
	input service, data_valid;
	input [15:0] data_from_mem;
	output [15:0] addr_to_mem;
	output fsm_busy;


	//FSM signals
	wire [7:0] tag_out;	
	wire miss_detected, Data_Write, Tag_Write;

	//16b address
	//16B data -> 4b offset (lsb not used)
	//128 lines -> 7b index
	//16b-4b-7b -> 5b tag
	wire [2:0] offset, offset_FSM;
	wire [6:0] index;
	wire [4:0] tag;


	//Cache miss if block is not valid or tags do not match.
	assign miss_detected = op & (!tag_out[7] || (tag != tag_out[4:0]));
	//FSM will set fsm_busy, triggering all muxes

	//Mux between addr we want and addr FSM is updating
	wire [15:0] addr_to_mem, addr_FSM;
	assign addr_to_mem = fsm_busy ? addr_FSM : address_in;

	//mux between word we want and word the FSM is updating
	assign offset = fsm_busy ? offset_FSM : address_in[3:1];
	assign index = address_in[10:4];
	assign tag = address_in[15:11];


	wire [127:0] line;
	Decoder_7_128 linedecoder(.in(index), .out(line));

	wire [7:0] word;
	Decoder_3_8 worddecoder(.in(offset), .out(word));

	wire [15:0] mem_or_input;
	assign mem_or_input = fsm_busy ? data_from_mem : data_in; 

	DataArray data(.clk(clk), .rst(rst), .DataIn(mem_or_input), 
		.Write(Data_Write | (op & write)), .BlockEnable(line), 
		.WordEnable(word), .DataOut(data_out));

	MetaDataArray tags(.clk(clk), .rst(rst), .DataIn({1'b1, 2'b0, tag}), 
		.Write(Tag_Write), .BlockEnable(line), .DataOut(tag_out));

	// memory4c mem(.data_out(data_mem), .data_in(data_in), .addr(mem_addr),
	// 	.enable(op), .wr(write & ~fsm_busy), .clk(clk), .rst(rst), .data_valid(data_valid));

	cache_fill_FSM FSM(.clk(clk), .rst(rst), 
		.miss_address(address_in), .fsm_busy(fsm_busy), .service(service),
		.write_data_array(Data_Write), .write_tag_array(Tag_Write),
		.memory_address(addr_FSM), .offset(offset_FSM), .memory_data_valid(data_valid));

	assign stall = fsm_busy | miss_detected;

endmodule
