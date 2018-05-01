/* Forwarding Unit
* This module controls the inputs to the ALU input muxes, controlling which
* stages the ALU gets its inputs from.
* @input Rd_MEM is the WriteReg stored in the EX/MEM plr.
* @input Rd_WB is the WriteReg stored in the MEM/WB plr.
* @input idexRR1 is the ReadReg1 stored in the ID/EX plr.
* @input idexRR2 is the ReadReg2 stored in the ID/EX plr.
* @output ForwardA is the input to the ALUin1 control mux.
* @output ForwardB is the input to the ALUin2 control mux.
*/
//TODO: needs testing.
module ForwardingUnit(Rs_EX, Rt_EX, Rd_MEM, Rd_WB, RegWrite_MEM, 
	RegWrite_WB, ForwardA, ForwardB);
	input [3:0] Rs_EX, Rt_EX, Rd_MEM, Rd_WB;
	input RegWrite_MEM, RegWrite_WB;
	output [1:0] ForwardA, ForwardB;

	/* Types of forwarding this needs to accomplish
	* 1. EX/MEM.WriteReg = ID/EX.ReadReg1
	* 2. EX/MEM.WriteReg = ID/EX.ReadReg2
	* 3. MEM/WB.WriteReg = ID/EX.ReadReg1
	* 4. MEM/WB.WriteReg = ID/EX.ReadReg2
	*/

	//MEM HAZARD
	wire ExHazard1, ExHazard2;
	assign ExHazard1 = (RegWrite_MEM && Rd_MEM && (Rd_MEM == Rs_EX));
	assign ExHazard2 = (RegWrite_MEM && Rd_MEM && (Rd_MEM == Rt_EX));

	//WB HAZARD
	wire MemHazard1, MemHazard2;
	assign MemHazard1 = (RegWrite_WB && Rd_WB && !ExHazard1 && (Rd_WB == Rs_EX));
	assign MemHazard2 = (RegWrite_WB && Rd_WB && !ExHazard2 && (Rd_WB == Rt_EX));


	/* Forward A: whether ALUin1 needs to be forwarded
	* 00 if no conditions true, no forwarding needed
	* 1x if ExHazard1 true, forwarding from EX/MEM.ALUOut needed
	* 01 if MemHazard1 true, forwarding from MEM/WB.WriteData needed
	*/
	assign ForwardA = ExHazard1  ? 2'b1x :
					  MemHazard1 ? 2'b01 :
					  			   2'b00;


 	/* Forward B: whether ALUin2 needs to be forwarded
	* 00 if no conditions true, no forwarding needed
	* 1x if ExHazard2 true, forwarding from EX/MEM.ALUOut needed
	* 01 if MemHazard2 true, forwarding from MEM/WB.WriteData needed
	*/
	assign ForwardB = ExHazard2  ? 2'b1x :
					  MemHazard2 ? 2'b01 :
					  			   2'b00;

endmodule
