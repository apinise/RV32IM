module fetch_pipe #(
  parameter DWIDTH = 32,
  parameter MEM_SIZE = 16384
)(
  input   logic         Clk_Core,
  input   logic         Rst_Core_N,
  input   logic         PC_Sel,
  input   logic         Run,
  input   logic [31:0]  Program_Count_Imm,
  output  logic [31:0]  Program_Count_Plus,
  output  logic [31:0]  Program_Count,
  output  logic [31:0]  Instruction
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [DWIDTH-1:0]  program_count_c;
logic [DWIDTH-1:0]  program_count_plus_c;
logic [DWIDTH-1:0]  instruction_c;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

instruct_mem #(
  .DWIDTH(DWIDTH)
  .MEM_SIZE(MEM_SIZE)
)
instruct_mem (
  .Clk_Core(Clk_Core),
  .Rst_Core_N(Rst_Core_N),
  .Program_Count(program_count_c),
  .Instruction(instruction_c)
);

program_counter_top #(
  .DWIDTH(DWIDTH)
)
program_counter (
  .Clk_Core(Clk_Core),
  .Rst_Core_N(Rst_Core_N),
  .PC_Sel(PC_Sel),
  .Run(Run),
  .Program_Count_Imm(Program_Count_Imm),
  .Program_Count_Off(Program_Count_Plus),
  .Program_Count(program_count_c)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Register Outputs for Pipelining
always_ff @(posedge Clk_Core or negedge Rst_Core_N) begin
  if (~Rst_Core_N) begin
    Program_Count       <= '0;
    Program_Count_Plus  <= '0;
    Instruction         <= '0;
  end
  else begin
    Program_Count       <= program_count_c;
    Program_Count_Plus  <= program_count_plus_c;
    Instruction         <= instruction_c;
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////

endmodule