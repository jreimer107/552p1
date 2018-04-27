// module cache_fill_FSM(clk, rst, miss_detected, miss_address, fsm_busy, 
// 	write_data_array, write_tag_array, memory_address, memory_data, 
// 	memory_data_valid);
// 	input clk, rst;
// 	input miss_detected; // active high when tag match logic detects a miss
// 	input [15:0] miss_address; // address that missed the cache
// 	output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
// 	output write_data_array; // write enable to cache data array to signal when filling with memory_data
// 	output write_tag_array; // write enable to cache tag array to write tag and valid bit once all words are filled in to data array
// 	output [15:0] memory_address; // address to read from memory
// 	input [15:0] memory_data; // data returned by memory (after  delay)
// 	input memory_data_valid; // active high indicates valid data returning on memory bus

// 	localparam IDLE = 1'b0;
// 	localparam WAIT = 1'b1;

// 	wire state, next_state;
// 	wire [3:0] count, next_count, count_inc;

// 	//State transition signals
// 	wire idletoidle, idletowait, waittowait, waitoidle;
// 	assign idletoidle = (state == IDLE) && ~miss_detected;
// 	assign idletowait = (state == IDLE) && miss_detected;
// 	assign waittowait = (state == WAIT) && ~count[3];
// 	assign waitoidle = (state == WAIT) && count[3];

// 	assign memory_address = {miss_address[15:4], count[2:0], 1'b0};
// 	assign fsm_busy = state == WAIT;
// 	assign write_tag_array = waitoidle;
// 	assign write_data_array = waittowait && memory_data_valid;
	
// 	assign next_count = idletowait ? 4'h0 :
// 						waittowait ? count_inc : count;

// 	assign next_state = (idletowait | waittowait) ? WAIT : IDLE;


// 	dff state_ff(.q(state), .d(next_state), .wen(1'b1), .clk(clk), .rst(rst));
	
// 	dff c0(.q(count[0]), .d(next_count[0]), .wen(memory_data_valid), .clk(clk), .rst(rst));
// 	dff c1(.q(count[1]), .d(next_count[1]), .wen(memory_data_valid), .clk(clk), .rst(rst));
// 	dff c2(.q(count[2]), .d(next_count[2]), .wen(memory_data_valid), .clk(clk), .rst(rst));
// 	dff c3(.q(count[3]), .d(next_count[3]), .wen(memory_data_valid), .clk(clk), .rst(rst));

// 	CLA_4bit incrementor(.A(count), .B(4'h1), .cin(1'b0), .s(count_inc), .G(), .P());

// endmodule


//Devin's probably better fsm
// module cache_fill_FSM(clk, rst, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data, memory_data_valid);

//     input clk, rst;
//     input miss_detected; // active high when tag match logic detects a miss
//     input [15:0] miss_address; // address that missed the cache

//     input [15:0] memory_data; // data returned by memory (after  delay)
//     input memory_data_valid; // active high indicates valid data returning on memory bus

//     output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
//     output write_data_array; // write enable to cache data array to signal when filling with memory_data
//     output write_tag_array; // write enable to cache tag array to write tag and valid bit once all words are filled in to data array
//     output [15:0] memory_address; // address to read from memory

//     wire [2:0] count;
//     wire fsm_input;

//     dff             fsm(.q(fsm_busy), .d(fsm_input), .wen(1'b1), .clk(clk), .rst(rst));
//     counter_3bit     cc(.clk(clk), .rst(rst), .enable(memory_data_valid), .count(count));

//     assign fsm_input = fsm_busy ? ((count == 3'h7) ? 1'b0 : 1'b1) : miss_detected;
//     assign memory_address = {miss_address[15:4], count, 1'b0}; 
//     assign write_data_array = memory_data_valid & fsm_busy;
//     assign write_tag_array = fsm_busy & ~fsm_input;


// endmodule

module counter_3bit(clk, rst, enable, count);

    input clk, rst;
    input enable;
    output [2:0] count;

    wire [2:0] adder_out;
    wire [1:0] adder_carry;

    dff ff0(.d(adder_out[0]), .q(count[0]), .wen(enable), .clk(clk), .rst(rst));
    dff ff1(.d(adder_out[1]), .q(count[1]), .wen(enable), .clk(clk), .rst(rst));
    dff ff2(.d(adder_out[2]), .q(count[2]), .wen(enable), .clk(clk), .rst(rst));

    FA FA0(.S(adder_out[0]), .cout(adder_carry[0]), .A(count[0]), .B(1'b1), .cin(1'b0));
    FA FA1(.S(adder_out[1]), .cout(adder_carry[1]), .A(count[1]), .B(1'b0), .cin(adder_carry[0]));
    FA FA2(.S(adder_out[2]), .cout(/*    NC    */), .A(count[2]), .B(1'b0), .cin(adder_carry[1]));

endmodule

//My improved version of Devin's fsm
//Memory can recieve pipelined read requests, so we increment the memory read address every cycle
//while only incrementing the data cache write addresss every time we get valid data.
module cache_fill_FSM(clk, rst, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array, 
	memory_address, offset, memory_data_valid);

    input clk, rst;
    input miss_detected; // active high when tag match logic detects a miss
    input [15:0] miss_address; // address that missed the cache

    input memory_data_valid; // active high indicates valid data returning on memory bus

    output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    output write_data_array; // write enable to cache data array to signal when filling with memory_data
    output write_tag_array; // write enable to cache tag array to write tag and valid bit once all words are filled in to data array
    output [15:0] memory_address; // address to read from memory
	output [2:0] offset;	//word of cache to currently write to 

    wire [2:0] request, receive;
    wire fsm_input;
    
    localparam IDLE = 1'b0;
    localparam RQING = 1'b1;
    
    wire rq, rq_next, rc, rc_next;
    dff	rqing(.d(rq_next), .q(rq), .wen(1'b1), .clk(clk), .rst(rst));
    dff	rcing(.d(rc_next), .q(rc), .wen(1'b1), .clk(clk), .rst(rst));
        
    assign rq_next = rq ? ((request == 3'h7) ? IDLE : RQING) : fsm_input & ~fsm_busy; 
    assign rc_next = rc ? ((receive == 3'h7) ? IDLE : RQING) : (request == 3'h3);
    
    dff             fsm(.q(fsm_busy), .d(fsm_input), .wen(1'b1), .clk(clk), .rst(rst));
	//TODO: check that request holds at 7 after reaching it until next miss
    counter_3bit	req(.clk(clk), .rst(rst), .enable(rq), .count(request));
	counter_3bit	rec(.clk(clk), .rst(rst), .enable(rc), .count(receive));

	//FSM is busy when it hasn't recieved 8 words.
    assign fsm_input = fsm_busy ? ((receive == 3'h7) ? 1'b0 : 1'b1) : miss_detected;
	//Mem address is given pipelined requests every clock cycle
    assign memory_address = {miss_address[15:4], request, 1'b0}; 
	//Data cache offset is only incremented when data is received
	assign offset = receive;
	//Only write to data array when we have data
    assign write_data_array = memory_data_valid & fsm_busy;
	//Write to the tage array at end of process.
    assign write_tag_array = fsm_busy & ~fsm_input;


endmodule
