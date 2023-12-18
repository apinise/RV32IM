module fetch_pipe #(
  parameter DWIDTH = 32,
  parameter MEM_SIZE = 16384
)(
  // Global Clock and Reset
  input   logic         Clk_Core,
  input   logic         Rst_Core_N,
  // Interface with Control Unit
  input   logic         pc_sel_fi,
  // Interface with Execution Unit
  input   logic         flush_fi,
  input   logic [31:0]  pc_imm_fi,
  // Interface with Decode Unit
  input   logic         stall_fi,
  output  logic [31:0]  pc_plus_fo,
  output  logic [31:0]  pc_fo,
  output  logic [31:0]  instruct_fo
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

localparam INSTR_NOP = 32'h0000_0013;

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
  .PC_Sel(pc_sel_fi),
  .Stall(stall_fi),
  .Flush(flush_fi),
  .Program_Count_Imm(pc_imm_fi),
  .Program_Count_Off(program_count_plus_c),
  .Program_Count(program_count_c)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Register Outputs for Pipelining
always_ff @(posedge Clk_Core or negedge Rst_Core_N) begin
  if (~Rst_Core_N) begin
    pc_fo         <= '0;
    pc_plus_fo    <= '0;
    instruct_fo   <= '0;
  end
  else begin
    if (Stall) begin
      pc_fo         <= pc_fo;
      pc_plus_fo    <= pc_plus_fo;
      instruct_fo   <= instruct_fo;
    end
    else if (Flush) begin
      instruct_fo   <= INSTR_NOP;
      pc_fo         <= program_count_c;
      pc_plus_fo    <= program_count_plus_c;
    end
    else begin
      pc_fo         <= program_count_c;
      pc_plus_fo    <= program_count_plus_c;
      instruct_fo   <= instruction_c;
    end
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
fetch_pipe fetch #(
  .DWIDTH(),
  .MEM_SIZE()
)(
  .Clk_Core(),
  .Rst_Core_N(),
  .pc_sel_fi(),
  .run_fi(),
  .pc_imm_fi(),
  .pc_plus_fo(),
  .pc_fo(),
  .instruct_fo()
);
*/

endmodule