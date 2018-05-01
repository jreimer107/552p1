/* fetch
* This module stores the PC register and changes it based on current
* conditions. Under normal conditions, the PC will increment by 2 each
* clock cycle. In the case of a branch, the PC will be changed to the
* branch address. Finally, in the case of a halt or a bubble, the PC
* will not advance. It also houses the instruction memory that the PC
* will read instructions from.
* @input pc_branch is the address calculated by the branch section of
*	the ID phase (taken directly from there).
* @input branch is a control signaling if a branch instr is in the decode
*	phase.
* @input stop signifies that PC advancement should be halted.
* @output instr is the output instruction based on the current pc.
* @output pc is the current pc, needed for top level output.
* @output pcs is the incremented pc, used for pcs instructions.
*/
module fetch(clk, rst, pc_branch, branch, stop, instr, pc, pcs,
	service, data_from_mem, data_valid, addr_to_mem, fsm_busy);

	input clk, rst;
	input stop, branch;
	input [15:0] pc_branch;
	output [15:0] pc, pcs, instr;

	//Signals to arbitrator
	input service, data_valid;
	input [15:0] data_from_mem;
	output [15:0] addr_to_mem;
	output fsm_busy;

	wire stall;

	wire [15:0] pc_inc, pc_next, increment, instr_raw;

	//Selects next pc based on branch coditions.
	assign pc_next = branch ? pc_branch : pc_inc;
	//Pauses/stops pc based on HLT instrs or control hazard bubbles.
	assign increment = (stop | stall) ? 16'h0000 : 16'h0002;

	//Makes pc_next current pc.
	Register PC(.clk(clk), .rst(rst), .D(pc_next), .WriteReg(1'b1),
		.ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc), .Bitline2());

	//Makes pc_inc out of pc.
	CLA_16bit incrementor(.A(increment), .B(pc), .S(pc_inc));

	Cache_Controller Imem(.clk(clk), .rst(rst), .write(1'b0), .op(1'b1),
		.address_in(pc), .data_out(instr_raw), .data_in(16'hzzzz), .stall(stall),
		.service(service), .data_from_mem(data_from_mem), .data_valid(data_valid), 
		.addr_to_mem(addr_to_mem), .fsm_busy(fsm_busy));	

	assign instr = (branch | stall) ? 16'h0000 : instr_raw; 	//For instr squashing
	assign pcs = pc_inc; //Redirect pc_inc to better name for externals.
endmodule
