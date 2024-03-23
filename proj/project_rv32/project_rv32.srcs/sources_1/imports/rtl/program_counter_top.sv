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

module program_counter_top #(
  parameter DWIDTH = 32
)(
  input  logic              Clk_Core,				      // 100 MHz Core Clock
  input  logic              Rst_Core_N,				    // Core Clock Reset
  input  logic              PC_Sel,					      // Input Select 0: Increment 1: Immediate
  input  logic              Stall,
  input  logic              Flush,
  input  logic [DWIDTH-1:0] Program_Count_Imm,		// Immediate Offset of PC
  output logic [DWIDTH-1:0] Program_Count_Off,    // PC + 4 Offset
  output logic [DWIDTH-1:0] Program_Count			    // Current Program Count
);

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [DWIDTH-1:0] program_count_four;
logic [DWIDTH-1:0] program_count_new;

logic [DWIDTH-1:0] program_count_r;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

mux2to1 mux2to1 (
  .Mux_In_A (program_count_four),
  .Mux_In_B (Program_Count_Imm),
  .Input_Sel(PC_Sel),
  .Mux_Out  (program_count_new)
);

program_counter_add program_counter_add (
  .Program_Count_Curr(Program_Count),
  .Program_Count_Next(program_count_four)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

assign Program_Count_Off = program_count_four;	// Assign PC+4 to output

always@(posedge Clk_Core) begin
  if (~Rst_Core_N) begin
    program_count_r <= '0;	              // Reset PC on reset
  end else begin
    if (Flush) begin
      program_count_r <= Program_Count_Imm;//program_count_new + 32'd4;	// Set new PC
    end
    else if (Stall) begin
      program_count_r <= program_count_r;
    end
    else begin
      program_count_r <= program_count_new;
    end
  end
end

assign Program_Count = program_count_r;
//assign Program_Count = (Flush == 1'b1) ? Program_Count_Imm : program_count_r;

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////

/*
program_counter_top #(
  .DWIDTH()
)
program_counter (
  .Clk_Core(),
  .Rst_Core_N(),
  .PC_Sel(),
  .Run(),
  .Program_Count_Imm(),
  .Program_Count_Off(),
  .Program_Count()
);
*/

endmodule