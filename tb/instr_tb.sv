module instr_tb();
	reg clk, rst_n;
	reg [15:0] instr;
	wire [15:0] PC;
	wire hlt;

	integer cycle_count;

	cpu DUT(.clk(clk), .rst_n(rst_n), .pc_out(PC), .hlt(hlt), .mode(1'b1), .instr_in(instr));

	always #50 clk = ~clk;


	always @(posedge clk) begin
	  	cycle_count = cycle_count + 1;
		if (cycle_count > 100000) begin
	  		$display("hmm....more than 100000 cycles of simulation...error?\n");
	  		$finish;
		end
	end

	initial begin
  	 $dumpvars;
  	 	cycle_count = 0;
  	 	rst_n = 0; /* Intial reset state */
  	 	clk = 1;
  	 	#201 rst_n = 1; // delay until slightly after two clock periods

		@(negedge clk) instr = 16'hB151;
		@(negedge clk) instr = 16'hA151;
		//@(negedge clk) instr = 16'hB2B0;
		//@(negedge clk) instr = 16'hA2B0;
		//@(negedge clk) instr = 16'h0321;
		@(negedge clk);
		$stop();
	 end
endmodule
