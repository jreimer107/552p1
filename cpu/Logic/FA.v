module FA(A, B, cin, cout, S);
  input A, B, cin;
  output cout, S;

  assign S = A ^ B ^ cin;
  assign cout = (A & B) | (B & cin) | (A & cin);

endmodule
