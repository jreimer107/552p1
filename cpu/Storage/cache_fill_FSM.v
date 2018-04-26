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
module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data, memory_data_valid);

    input clk, rst_n;
    input miss_detected; // active high when tag match logic detects a miss
    input [15:0] miss_address; // address that missed the cache

    input [15:0] memory_data; // data returned by memory (after  delay)
    input memory_data_valid; // active high indicates valid data returning on memory bus

    output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    output write_data_array; // write enable to cache data array to signal when filling with memory_data
    output write_tag_array; // write enable to cache tag array to write tag and valid bit once all words are filled in to data array
    output [15:0] memory_address; // address to read from memory

    wire [2:0] count;
    wire fsm_input;

    dff             fsm(.q(fsm_input), .d(fsm_busy), .wen(1'b1), .clk(clk), .rst(~rst_n));
    counter_3bit     cc(.clk(clk), .rst(rst), .enable(memory_data_valid), .count(count));

    assign fsm_input = fsm_busy ? (count == 3'h7) ? 1'b0 : 1'b1 : miss_detected;
    assign memory_address = {miss_address[15:4], count, 1'b0}; 
    assign write_data_array = memory_data_valid;
    assign write_tag_array = fsm_busy & ~fsm_input;


endmodule

module counter_3bit(clk, rst, enable, count);

    input clk, rst;
    input enable;
    output [2:0] count;

    wire [2:0] adder_out;
    wire [1:0] adder_carry;

    dff ff0(.q(adder_out[0]), .d(count[0]), .wen(enable), .clk(clk), .rst(rst));
    dff ff1(.q(adder_out[1]), .d(count[1]), .wen(enable), .clk(clk), .rst(rst));
    dff ff2(.q(adder_out[2]), .d(count[2]), .wen(enable), .clk(clk), .rst(rst));

   	FA FA0(.S(adder_out[0]), .cout(adder_carry[0]), .A(count[0]), .B(1'b1), .cin(1'b0));
    FA FA1(.S(adder_out[1]), .cout(adder_carry[1]), .A(count[0]), .B(1'b0), .cin(adder_carry[0]));
    FA FA2(.S(adder_out[2]), .cout(/*    NC    */), .A(count[0]), .B(1'b0), .cin(adder_carry[1]));

endmodule