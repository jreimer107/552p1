module CacheController(clk, rst, address_in, data_in, data_out, stall);
	input clk, rst;
	input [15:0] address_in, data_in;
	output stall;

	localparam valid = 1'b1;
	localparam invalid = 1'b0;

	wire [15:0] data_bus;
	wire [8:0] tag_out;	
	wire fsm_busy, Data_Write, Tag_Write;
	wire miss_detected;
	wire data_valid;

	//16b address
	//16B data -> 4b offset
	//128 lines -> 7b index
	//16b-4b-7b -> 5b tag
	wire [3:0] offset;
	wire [6:0] index;
	wire [4:0] tag;
	assign offset = address_in[3:0];
	assign index = address_in[10:4];
	assign tag = address_in[15:11];

	wire [127:0] line;
	7_128_Decoder linedecoder(.in(index), .out(line));

	wire [7:0] word;
	3_8_Decoder worddecoder(.in(offset), .out(word));

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
	write enable tag array, data array, and memory
	*/




	DataArray data(.clk(clk), .rst(rst), .DataIn(data_bus), .Write(Data_Write), 
		.BlockEnable(line), .WordEnable(word));

	MetaDataArray tags(.clk(clk), .rst(rst), .DataIn({valid, 2'bxx, tag}), 
		.Write(Tag_Write), .BlockEnable(line), .DataOut(tag_out));

	memory4c mem(.data_out(data_bus), .data_in(data_in), .addr(address_in),
		.enable(1'b1), .clk(clk), .rst(rst), .data_valid(data_valid));

	cache_fill_fsm FSM(.clk(clk), .rst(rst), .miss_detected(miss_detected), 
		.miss_address(address_in), .fsm_busy(fsm_busy), 
		.write_data_array(Data_Write), .write_tag_array(Tag_Write),
		.memory_address(memtodata), .mem


endmodule