module Shifter (Shift_In, Shift_Val, Mode, Shift_Out);
  input  [15:0] Shift_In; //This is the number to perform shift operation on
  input  [3:0]  Shift_Val; //Shift amount (used to shift the ‘Shift_In’)
  input  [1:0]  Mode; // To indicate SLL(00),  SRA(01), or ROR(10)
  output [15:0] Shift_Out; //Shifter value

  wire SLL, SRA, ROR;
  assign SLL = (Mode == 2'b00);
  assign SRA = (Mode == 2'b01);
  assign ROR = (Mode == 2'b1x);

  wire [15:0] shift0, shift1, shift2;

  /*
  if (Shift_Val[0]) begin
    if (SLL) shift0 = {Shift_In[14:0], 1'b0};
    else if (SRA) shift0 = {Shift_In[15], Shift_In[15:1]};
    else shift0 = {Shift_In[0], Shift_In[15:1]};
  end
  */
 assign shift0 = Shift_Val[0] ? (SLL ? {Shift_In[14:0], 1'b0} :
                                 SRA ? {Shift_In[15], Shift_In[15:1]} :
                                       {Shift_In[0], Shift_In[15:1]}) :
									   Shift_In;

 assign shift1 = Shift_Val[1] ? (SLL ? {shift0[13:0], 2'h0} :
                                 SRA ? {{2{shift0[15]}}, shift0[15:2]} :
                                       {shift0[1:0], shift0[15:2]}) :
									   shift0;

 assign shift2 = Shift_Val[2] ? (SLL ? {shift1[11:0], 4'h0} :
                                 SRA ? {{4{shift1[15]}}, shift1[15:4]} :
                                       {shift1[3:0], shift1[15:4]}) :
									   shift1;

 assign Shift_Out = Shift_Val[3] ? (SLL ? {shift2[7:0], 8'h0} :
                                 SRA ? {{8{shift2[15]}}, shift2[15:8]} :
                                       {shift2[7:0], shift2[15:8]}) :
									   shift2;

/*   assign shift0 = 
    Shift_Val[0] ?
      SLL ?
        {Shift_In[14:0], 1'b0} :
      SRA ?
      	{Shift_In[15], Shift_In[15:1]} :
      ROR ? 
      	{Shift_In[15], Shift_In[15:1]} : 
   	  Shift_In
    : Shift_In;
      
  assign shift1 = 
    Shift_Val[1] ?
      SLL ?
        {Shift_In[14:0], 1'b0} :
      SRA ?
      	{{2{shift0[15]}}, shift0[15:2]} :
      ROR ? 
      	{shift0[1:0], shift0[15:2]} : 
      shift0
    : shift0;
    
  assign shift2 = 
    Shift_Val[2] ?
      SLL ?
        {shift1[11:0], 4'h0} :
      SRA ?
      	{{4{shift1[15]}}, shift1[15:4]} :
      ROR ? 
      	{shift1[3:0], shift1[15:4]} : 
      shift1
    : shift1;
    
  assign Shift_Out = 
    Shift_Val[3] ?
      SLL ?
        {shift2[7:0], 8'h0} :
      SRA ?
      	{{8{shift0[15]}}, shift1[15:8]} :
      ROR ? 
      	{shift0[7:0], shift0[15:8]} : 
      shift2
    : shift2;

 */

endmodule
