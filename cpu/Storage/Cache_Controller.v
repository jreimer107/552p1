module Cache_Controller(clk, rst, write, op, address_in, data_in, data_out, stall);
	input clk, rst;
	input write, op;
	input [15:0] address_in, data_in;
	output stall;
	output [15:0] data_out;

	wire [15:0] data_bus;
	wire [7:0] tag_out;	
	wire fsm_busy, Data_Write, Tag_Write;
	wire miss_detected;
	wire data_valid;

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
	wire [15:0] mem_addr, addr_FSM;
	assign mem_addr = fsm_busy ? addr_FSM : address_in;

	//mux between word we want and word the FSM is updating
	assign offset = fsm_busy ? offset_FSM : address_in[3:1];
	assign index = address_in[10:4];
	assign tag = address_in[15:11];


	wire [127:0] line;
	Decoder_7_128 linedecoder(.in(index), .out(line));

	wire [7:0] word;
	Decoder_3_8 worddecoder(.in(offset), .out(word));

	/* If read
	check tag - set miss detected
	if miss detected
		fsm sets fsm_busy (stall?)
		for (8) {
			memory fetches word
			data writes word to block seleted by line
				(mux offset?)
		}
		tag array writes new tag at line
		fsm resets fsm_busy (end stall?)
		offset muxes back to given address
		data from data array should now be correct

	If write
	if(tag == wanted tag) { hit
		block = wanted block;
		write_data = 1;
		write_mem = 1;
	}
	else { //miss
		miss detected = 1;
		while(fsm_busy) {
			block = fsm block;
			if (mem data valid) {
				write_data = 1;
			}
		}
		write_tag = 1;
		block = wanted_block;
		write_mem = 1;
	}

	If fsm busy, block = block_fsm.
	If write || fsm_data_write, data_write = 1; 
	If write & !miss_detected || fsm_write_tag, write_tag = 1;
	if !miss_detected & write, write_mem = 1;


	*/



	DataArray data(.clk(clk), .rst(rst), .DataIn(data_bus), .Write(Data_Write | write), 
		.BlockEnable(line), .WordEnable(word), .DataOut(data_out));

	MetaDataArray tags(.clk(clk), .rst(rst), .DataIn({1'b1, 2'b0, tag}), 
		.Write(Tag_Write), .BlockEnable(line), .DataOut(tag_out));

	memory4c mem(.data_out(data_bus), .data_in(data_in), .addr(mem_addr),
		.enable(op), .wr(write), .clk(clk), .rst(rst), .data_valid(data_valid));

	// cache_fill_FSM FSM(.clk(clk), .rst(rst), .miss_detected(miss_detected), 
	// 	.miss_address(address_in), .fsm_busy(fsm_busy), 
	// 	.write_data_array(Data_Write), .write_tag_array(Tag_Write),
	// 	.memory_address(addr_FSM), .memory_data(16'hxxxx), .memory_data_valid(data_valid));

	cache_fill_FSM_pipe FSMP(.clk(clk), .rst(rst), .miss_detected(miss_detected), 
		.miss_address(address_in), .fsm_busy(fsm_busy), 
		.write_data_array(Data_Write), .write_tag_array(Tag_Write),
		.memory_address(addr_FSM), .offset(offset_FSM), .memory_data_valid(data_valid));



	assign stall = fsm_busy | miss_detected;

endmodule