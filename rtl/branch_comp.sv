module branch_comp #(
  parameter DWIDTH = 32
)(
  input   logic [DWIDTH-1:0]  Read_Reg_Data_1,
  input   logic [DWIDTH-1:0]  Read_Reg_Data_2,
  input   logic               Branch_Un_Ctrl,
  output  logic               Branch_Equal,
  output  logic               Branch_Lt  
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always_comb begin
  Branch_Equal = (Read_Reg_Data_1 == Read_Reg_Data_2) ? 1'b1 : 1'b0;
  if (Branch_Un_Ctrl) begin
    Branch_Lt = (Read_Reg_Data_1 < Read_Reg_Data_2) ? 1'b1 : 1'b0;
  end
  else begin
    Branch_Lt = ($signed(Read_Reg_Data_1) < $signed(Read_Reg_Data_2)) ? 1'b1 : 1'b0;
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
branch_comp branch_comp (
  .Read_Reg_Data_1(),
  .Read_Reg_Data_2(),
  .Branch_Un_Ctrl(),
  .Branch_Equal(),
  .Branch_Lt()
);
*/

endmodule