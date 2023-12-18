//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2023 09:54:34 PM
// Design Name: 
// Module Name: program_counter.sv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module program_counter #(
  parameter DWIDTH = 32
)(
  input   logic               Clk_Core,				      // Core Clock
  input   logic               Rst_Core_N,				    // Core Clock Reset
  input   logic               Stall,                // Stall from Decode Unit
  input   logic               Flush,                // Flush from execution unit
  input   logic [DWIDTH-1:0]  Program_Count_New,		// Next Program Count
  output  logic [DWIDTH-1:0]  Program_Count			    // Current Program Count
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////


initial begin
  Program_Count = '0;
end

always@(posedge Clk_Core) begin
  if (~Rst_Core_N) begin
    Program_Count <= '0;	              // Reset PC on reset
  end else begin
    if (Stall) begin
      Program_Count <= Program_Count;
    end
    else if (Flush) begin
      Program_Count <= Program_Count_New;	// Set new PC
    end
    else begin
      Program_Count <= Program_Count_New;
    end
  //end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////

/*
program_counter #(
  .DWIDTH()
)
program_counter (
  .Clk_Core(),
  .Rst_Core_N(),
  .Run(),
  .Program_Count_New(),
  .Program_Count()
);
*/

endmodule