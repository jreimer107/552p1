module ALU_tb();


reg [15:0] A, B;
reg [3:0] op;
wire [15:0] out;

reg machine_broke = 0;

ALU alu(.A(A), .B(B), .op(op), .out(out));


initial begin



////////////////////////// PADDSB TEST /////////////////////////////////////////
    op = 4'b0111;

    // zero
    // 0000 + 0000 = 0000

    A = 16'h0000;
    B = 16'h0000;
    #1
    if (out !== 16'h0000) begin
        machine_broke = 1;
        $display("PADDSB: 0x0000 + 0x0000 = 0x0000, got: %x", out);
    end

    // pos + pos
    // 1111 + 1111 = 2222
    A = 16'h1111;
    B = 16'h1111;
    #1
    if (out !== 16'h2222) begin
        machine_broke = 1;
        $display("PADDSB: 0x1111 + 0x1111 = 0x2222, got: %x", out);
    end

    // neg + neg
    // FFFF + FFFF = EEEE
    A = 16'hFFFF;
    B = 16'hFFFF;
    #1
    if (out !== 16'hEEEE) begin
        machine_broke = 1;
        $display("PADDSB: 0xFFFF + 0xFFFF = 0xEEEE, got: %x", out);
    end

    // neg + pos
    // CCCC + 3333 = FFFF
    A = 16'hCCCC;
    B = 16'h3333;
    #1
    if (out !== 16'hFFFF) begin
        machine_broke = 1;
        $display("PADDSB: 0xCCCC + 0x3333 = 0xFFFF, got: %x", out);
    end

    // pos + neg
    // 4444 + DDDD = 1111
    A = 16'h4444;
    B = 16'hDDDD;
    #1
    if (out !== 16'h1111) begin
        machine_broke = 1;
        $display("PADDSB: 0x4444 + 0xDDDD = 0x1111, got: %x", out);
    end

    // test pos saturation
    // 7777 + 7777 = 7777
    A = 16'h7777;
    B = 16'h7777;
    #1
    if (out !== 16'h7777) begin
        machine_broke = 1;
        $display("PADDSB: 0x7777 + 0x7777 = 0x7777, got: %x", out);
    end

    // test neg saturation
    // 8888 + 8888 = 8888
    A = 16'h8888;
    B = 16'h8888;
    #1
    if (out !== 16'h8888) begin
        machine_broke = 1;
        $display("PADDSB: 0x8888 + 0x8888 = 0x8888, got: %x", out);
    end



    if (machine_broke === 1) begin
        $display("Tests failed.");
    end
    else begin
        $display("Tests passed!");
    end

	$stop();

end

endmodule
