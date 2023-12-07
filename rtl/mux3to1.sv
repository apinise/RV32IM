//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Evan Apinis
// 
// Create Date: 06/24/2023 01:11:23 PM
// Design Name: 
// Module Name: mux3to1.sv
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

module mux3to1 #(
  parameter DWIDTH = 32
)(
  input  logic [DWIDTH-1:0] Mux_In_A,
  input  logic [DWIDTH-1:0] Mux_In_B,
  input  logic [DWIDTH-1:0] Mux_In_C,
  input  logic [1:0]        Input_Sel,
  output logic [DWIDTH-1:0] Mux_Out
);

always_comb begin
  Mux_Out = {DWIDTH{1'b0}};
  casez(Input_Sel)
    2'b00: begin
      Mux_Out = Mux_In_A;
    end
    2'b01: begin
      Mux_Out = Mux_In_B;
    end
    2'b10: begin
	    Mux_Out = Mux_In_C;
    end
  endcase
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
mux3to1 #(
  .DWIDTH()
)
mux3to1 (
  .Mux_In_A(),
  .Mux_In_B(),
  .Mux_In_C(),
  .Input_Sel(),
  .Mux_Out()
);
*/

endmodule