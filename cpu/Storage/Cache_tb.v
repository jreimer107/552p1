module Cache_tb();
	reg clk, rst;
	reg write;
	reg [15:0] address, data_in;
	wire[15:0] data_out;
	wire stall;

	Cache_Controller DUT(.clk(clk), .rst(rst), .write(write), .address_in(address), 
		.data_in(data_in), .data_out(data_out), .stall(stall));

	always begin
		#5 clk = ~clk;
		$stop();
	end

	initial begin
		clk = 0;
		rst = 1;
		@(negedge clk);
		@(negedge clk) rst = 0;

		//Write something then read it
		write = 1;
		address = 16'h1234;
		data_in = 16'h5678;
		
		@(negedge clk);
		//$stop();
		write = 0;
		@(negedge clk);
		write = 1;
		address = 16'hAAAA;
		data_in = 16'BBBB;
		@(negedge clk);
		
		


	end

endmodule