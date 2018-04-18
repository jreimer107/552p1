module ALU_Control(instr, RegData1, RegData2, pcs, alu_out_MEM, WriteData, 
	ForwardA, ForwardB, ALUA, ALUB, ALUop);
	input [15:0] instr, RegData1, RegData2, pcs; //ID inputs
	input [15:0] alu_out_MEM, WriteData;	//Forwarded inputs
	input [2:0] ForwardA, ForwardB;
	output [15:0] ALUA, ALUB;
	output [1:0] ALUop;

	//Forwarding nonsense
	assign ALUA = (ForwardA == 2'b00) ? RegData1 :
				  (ForwardA == 2'b01) ? WriteData :
				  						alu_out_MEM;
	assign ALUB = (ForwardB == 2'b00) ? alu_in :
				  (ForwardB == 2'b01) ? WriteData :
				  						alu_out_MEM;