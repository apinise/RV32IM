//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Evan Apinis
// 
// Create Date: 06/24/2023 12:35:45 PM
// Design Name: 
// Module Name: mux2to1.sv
// Project Name: RV32I
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: MUX module for a RV32I CPU
// 		 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mux2to1 #(
  parameter DWIDTH = 32
)(
  input  logic [DWIDTH-1:0] Mux_In_A,
  input  logic [DWIDTH-1:0] Mux_In_B,
  input  logic              Input_Sel,
  output logic [DWIDTH-1:0] Mux_Out
);

always_comb begin
  Mux_Out = {DWIDTH{1'b0}};
  casez(Input_Sel)
    1'b0: begin
      Mux_Out = Mux_In_A;
    end
    1'b1: begin
      Mux_Out = Mux_In_B;
    end
  endcase
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
mux2to1 #(
  .DWIDTH()
)
mux2to1 (
  .Mux_In_A(),
  .Mux_In_B(),
  .Input_Sel(),
  .Mux_Out()
);
*/

endmodule