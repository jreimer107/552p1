module FA(A, B, cin, cout, S);
  input A, B, cin;
  output cin, S;

  assign S = A ^ B ^ cin;
  assign Cout = (A & B) | (B & Cin) | (A & Cin);

endmodule;
