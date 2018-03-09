module CLA_16bit_tb();
  reg [15:0] A, B;
  reg cin;
  wire cout;
  wire [15:0] S;

  //Test wires
  wire cout_t;
  wire [15:0] S_t;
  assign {cout_t, S_t} = A + B + cin;

  CLA_16bit DUT(.A(A), .B(B), .cin(cin), .cout(cout), .S(S));

  initial begin
    A = 16'h0000;
    B = 16'h0000;
    cin = 1'b0;
    repeat (100) begin
      A = $random;
      B = $random;
      cin = $random;
      #20
      $display("cout_t: %d, cout: %d, S_t: %d, S: %d", cout_t, cout, S_t, S);
      if (cout_t !== cout || S_t !== S) begin
        $display("Error");
        $stop();
      end
    end
    $display("Test passed");
    $stop();
  end
endmodule
