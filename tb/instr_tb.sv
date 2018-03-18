module instr_tb();
	reg clk, rst_n;
	reg [15:0] instr;
	wire [15:0] PC;
	wire hlt;

	integer cycle_count;

	cpu DUT(.clk(clk), .rst_n(rst_n), .pc_out(PC), .hlt(hlt), .mode(1'b0), .instr_in(instr));

	always #5 clk = ~clk;


	always @(posedge clk) begin
	  	cycle_count = cycle_count + 1;
		if (cycle_count > 100000) begin
	  		$display("hmm....more than 100000 cycles of simulation...error?\n");
	  		$stop();
		end
		$strobe("PC: %x, Instr: %x, WriteData: %x, MemWrite: %x", DUT.pc,
			DUT.instr, DUT.WriteData, DUT.MemWrite);
		$stop(); //Stop for each instruction
	end



	initial begin
  	 	$dumpvars;
  	 	cycle_count = 0;
  	 	rst_n = 0; /* Intial reset state */
  	 	clk = 1;
  	 	#25 rst_n = 1; // delay until slightly after two clock periods

		@(negedge clk) instr = 16'hB102;
		@(negedge clk) instr = 16'hA100; //R1 <- 0002
		@(negedge clk) instr = 16'hB201;
		@(negedge clk) instr = 16'hA200; //R2 <- 0001
		@(negedge clk) instr = 16'hB604;
		@(negedge clk) instr = 16'hA600; //R6 <- 0004
		@(negedge clk) instr = 16'h1112; //R1 <- R1 - R2 = 0001
		@(negedge clk) instr = 16'hE500; //R5 <- PC + 2
		@(negedge clk) instr = 16'hC202; //BEQ b1 (not taken )
		@(negedge clk) instr = 16'hD360; //BR R6 (0004)
		@(negedge clk) instr = 16'hF000; //HLT
		@(negedge clk) instr = 16'h0462; //R4 <- R6 + R2 = 0005
		@(negedge clk) instr = 16'hF000; //HLT
		@(negedge clk) instr = 16'h1462; //R4 <- R6 - R2 = 0003
		@(negedge clk) instr = 16'hF000; //HLT
		@(negedge clk);
	 end
endmodule
