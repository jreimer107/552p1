module instr_tb();
	reg clk, rst_n;
	reg [15:0] instr;
	wire [15:0] PC;
	wire hlt;

	integer cycle_count;

	cpu DUT(.clk(clk), .rst_n(rst_n), .pc_out(PC), .hlt(hlt), .mode(1'b1), .instr_in(instr));

	always #5 clk = ~clk;


	always @(posedge clk) begin
	  	cycle_count = cycle_count + 1;
		if (cycle_count > 100000) begin
	  		$display("hmm....more than 100000 cycles of simulation...error?\n");
	  		$stop();
		end
		$strobe("WriteData: %x, MemWrite: %x", DUT.WriteData, DUT.MemWrite);
	end

	
	
	initial begin
  	 	$dumpvars;
  	 	cycle_count = 0;
  	 	rst_n = 0; /* Intial reset state */
  	 	clk = 1;
  	 	#25 rst_n = 1; // delay until slightly after two clock periods

		@(negedge clk) instr = 16'hB112; //LLB r1, 12
		$stop();
		@(negedge clk) instr = 16'hA134; //LHB r1, 34
		//$stop();
		@(negedge clk) instr = 16'hB2B0;
		@(negedge clk) instr = 16'hA2A0;
		
		@(negedge clk) instr = 16'hB302;
		@(negedge clk) instr = 16'hA300;
		$stop();
		@(negedge clk) instr = 16'h9122;
		$stop();
		@(negedge clk) instr = 16'h0523;
		$stop();
		@(negedge clk) instr = 16'h8450;
		$stop();
		@(negedge clk) instr = 16'h7542;
		$stop();
		@(negedge clk) instr = 16'h2555;
		//$stop();
		$stop();
		@(negedge clk) instr = 16'hF000;
		$stop();
		@(negedge clk);
		$stop();
	 end
endmodule
