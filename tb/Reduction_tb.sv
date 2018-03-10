module Reduction_tb();
  reg signed [15:0] A, B;
  wire signed [3:0] s0, s1, s2, s3;
  wire g0, g1, g2, g3;
  wire signed [15:0] S_t, S_red;

  //Calculate stim values
  assign {g0, s0} = A[3:0] + B[3:0];
  assign {g1, s1} = A[7:4] + B[7:4];
  assign {g2, s2} = A[11:8] + B[11:8];
  assign {g3, s3} = A[15:12] + B[15:12];

  //Calculate test values to compare to result.
  assign S_t[6:0] = A[3:0] + A[7:4] + A[11:8] + A[15:12] +
                    B[3:0] + B[7:4] + B[11:8] + B[15:12];
  assign S_t[15:7] = {9{S_t[6]}};

  Reduction DUT(.s0(s0), .s1(s1), .s2(s2), .s3(s3),
                .g0(g0), .g1(g1), .g2(g2), .g3(g3),
                .S_red(S_red));

  initial begin
    A = 16'h0000;
    B = 16'h0000;
    repeat (100) begin
      A = $random;
      B = $random;
      #20
      $display("A: %h, B: %h, S_t: %h, S_red: %h", A, B, S_t, S_red);
      if (S_t !== S_red) begin
        $display("Error.");
        $stop();
      end
    end
    $display("Test passed");
    $stop();
  end
endmodule
