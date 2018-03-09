module RegisterFile(clk, rst, SrcReg1, SrcReg2, DstReg, WriteReg, DstData, SrcData1, SrcData2);
	input clk, rst;
	input [3:0] SrcReg1, SrcReg2, DstReg;	//Numbers of regs to read and write to
	input WriteReg;							//Signal to write
	input [15:0] DstData;					//Data to be written
	inout [15:0] SrcData1, SrcData2;		//Data to be read
	
	wire [15:0] readline1, readline2, writeline;	//Decoded bus to enable a register for reading/writing
	wire [15:0] readFromReg1, readFromReg2;			//The raw data read from registers. Muxed with writeline data to allow forwarding.
	
	//Muxes for forwarding
	assign SrcData1 = (SrcReg1 == DstReg && WriteReg) ? DstData : readFromReg1;
	assign SrcData2 = (SrcReg2 == DstReg && WriteReg) ? DstData : readFromReg2;
	
	//Decoders, change Src/DstReg encoded values into bitlines
	WriteDecoder_4_16 writer(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(writeline));
	ReadDecoder_4_16 reader1(.RegId(SrcReg1), .Wordline(readline1));
	ReadDecoder_4_16 reader2(.RegId(SrcReg2), .Wordline(readline2));
	
	//Registers
	Register reg0(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[0]), .ReadEnable1(readline1[0]), .ReadEnable2(readline2[0]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register reg1(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[1]), .ReadEnable1(readline1[1]), .ReadEnable2(readline2[1]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register reg2(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[2]), .ReadEnable1(readline1[2]), .ReadEnable2(readline2[2]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register reg3(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[3]), .ReadEnable1(readline1[3]), .ReadEnable2(readline2[3]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register reg4(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[4]), .ReadEnable1(readline1[4]), .ReadEnable2(readline2[4]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register reg5(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[5]), .ReadEnable1(readline1[5]), .ReadEnable2(readline2[5]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register reg6(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[6]), .ReadEnable1(readline1[6]), .ReadEnable2(readline2[6]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register reg7(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[7]), .ReadEnable1(readline1[7]), .ReadEnable2(readline2[7]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register reg8(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[8]), .ReadEnable1(readline1[8]), .ReadEnable2(readline2[8]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register reg9(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[9]), .ReadEnable1(readline1[9]), .ReadEnable2(readline2[9]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register regA(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[10]), .ReadEnable1(readline1[10]), .ReadEnable2(readline2[10]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register regB(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[11]), .ReadEnable1(readline1[11]), .ReadEnable2(readline2[11]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register regC(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[12]), .ReadEnable1(readline1[12]), .ReadEnable2(readline2[12]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register regD(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[13]), .ReadEnable1(readline1[13]), .ReadEnable2(readline2[13]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register regE(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[14]), .ReadEnable1(readline1[14]), .ReadEnable2(readline2[14]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	Register regF(.clk(clk), .rst(rst), .D(DstData), .WriteReg(writeline[15]), .ReadEnable1(readline1[15]), .ReadEnable2(readline2[15]), .Bitline1(readFromReg1), .Bitline2(readFromReg2));
	
endmodule

module Register(clk, rst, D, WriteReg, ReadEnable1, ReadEnable2, Bitline1, Bitline2);
	input clk, rst;
	input [15:0] D;									//Data to be written to bitcells
	input WriteReg, ReadEnable1, ReadEnable2;		//Enables
	inout [15:0] Bitline1, Bitline2;				//Output data lines
	
	BitCell bit0(.clk(clk), .rst(rst), .D(D[0]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[0]), .Bitline2(Bitline2[0]));
	BitCell bit1(.clk(clk), .rst(rst), .D(D[1]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[1]), .Bitline2(Bitline2[1]));
	BitCell bit2(.clk(clk), .rst(rst), .D(D[2]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[2]), .Bitline2(Bitline2[2]));
	BitCell bit3(.clk(clk), .rst(rst), .D(D[3]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[3]), .Bitline2(Bitline2[3]));
	BitCell bit4(.clk(clk), .rst(rst), .D(D[4]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[4]), .Bitline2(Bitline2[4]));
	BitCell bit5(.clk(clk), .rst(rst), .D(D[5]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[5]), .Bitline2(Bitline2[5]));
	BitCell bit6(.clk(clk), .rst(rst), .D(D[6]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[6]), .Bitline2(Bitline2[6]));
	BitCell bit7(.clk(clk), .rst(rst), .D(D[7]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[7]), .Bitline2(Bitline2[7]));
	BitCell bit8(.clk(clk), .rst(rst), .D(D[8]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[8]), .Bitline2(Bitline2[8]));
	BitCell bit9(.clk(clk), .rst(rst), .D(D[9]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[9]), .Bitline2(Bitline2[9]));
	BitCell bitA(.clk(clk), .rst(rst), .D(D[10]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[10]), .Bitline2(Bitline2[10]));
	BitCell bitB(.clk(clk), .rst(rst), .D(D[11]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[11]), .Bitline2(Bitline2[11]));
	BitCell bitC(.clk(clk), .rst(rst), .D(D[12]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[12]), .Bitline2(Bitline2[12]));
	BitCell bitD(.clk(clk), .rst(rst), .D(D[13]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[13]), .Bitline2(Bitline2[13]));
	BitCell bitE(.clk(clk), .rst(rst), .D(D[14]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[14]), .Bitline2(Bitline2[14]));
	BitCell bitF(.clk(clk), .rst(rst), .D(D[15]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[15]), .Bitline2(Bitline2[15]));
	
endmodule

module ReadDecoder_4_16(RegId, Wordline);
	input [3:0] RegId;
	output [15:0] Wordline;
	
	assign Wordline = (RegId == 4'h0) ? 16'h0001 :
					  (RegId == 4'h1) ? 16'h0002 :
					  (RegId == 4'h2) ? 16'h0004 :
					  (RegId == 4'h3) ? 16'h0008 :
					  (RegId == 4'h4) ? 16'h0010 :
					  (RegId == 4'h5) ? 16'h0020 :
					  (RegId == 4'h6) ? 16'h0040 :
					  (RegId == 4'h7) ? 16'h0080 :
					  (RegId == 4'h8) ? 16'h0100 :
					  (RegId == 4'h9) ? 16'h0200 :
					  (RegId == 4'hA) ? 16'h0400 :
					  (RegId == 4'hB) ? 16'h0800 :
					  (RegId == 4'hC) ? 16'h1000 :
					  (RegId == 4'hD) ? 16'h2000 :
					  (RegId == 4'hE) ? 16'h4000 :
										16'h8000;

endmodule										

module WriteDecoder_4_16(RegId, WriteReg, Wordline);
	input [3:0] RegId;
	input WriteReg;
	output [15:0] Wordline;
	
	assign Wordline = !WriteReg ? 16'h000 :
					(RegId == 4'h0) ? 16'h0001 :
					(RegId == 4'h1) ? 16'h0002 :
					(RegId == 4'h2) ? 16'h0004 :
					(RegId == 4'h3) ? 16'h0008 :
					(RegId == 4'h4) ? 16'h0010 :
					(RegId == 4'h5) ? 16'h0020 :
					(RegId == 4'h6) ? 16'h0040 :
					(RegId == 4'h7) ? 16'h0080 :
					(RegId == 4'h8) ? 16'h0100 :
					(RegId == 4'h9) ? 16'h0200 :
					(RegId == 4'hA) ? 16'h0400 :
					(RegId == 4'hB) ? 16'h0800 :
					(RegId == 4'hC) ? 16'h1000 :
					(RegId == 4'hD) ? 16'h2000 :
					(RegId == 4'hE) ? 16'h4000 :
									  16'h8000;
									  
endmodule
					
module BitCell(clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2, Bitline1, Bitline2);
	input clk, rst;
	input D;										//Data to store
	input WriteEnable, ReadEnable1, ReadEnable2;	//Enables for tristates
	inout Bitline1, Bitline2;
	
	wire q;
	
	dff	Flop(.q(q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));
	
	assign Bitline1 = ReadEnable1 ? q : 1'bz;
	assign Bitline2 = ReadEnable2 ? q : 1'bz;
	
endmodule

// Gokul's D-flipflop

module dff (q, d, wen, clk, rst);

    output         q; //DFF output
    input          d; //DFF input
    input 	   wen; //Write Enable
    input          clk; //Clock
    input          rst; //Reset (used synchronously)

    reg            state;

    assign q = state;

    always @(posedge clk) begin
      state = rst ? 0 : (wen ? d : state);
    end

endmodule
