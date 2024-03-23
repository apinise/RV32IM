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
  output  logic [31:0]  pc_fo,
  output  logic [31:0]  pc_plus_fo,
  output  logic [31:0]  instruct_fo
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

localparam INSTR_NOP = 32'h0000_0013;
localparam PC_INIT = 32'h0000_0000;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [DWIDTH-1:0]  program_count_plus_c;
logic [DWIDTH-1:0]  program_count_next_c;
logic [31:0]        pc_fo_r;

logic [DWIDTH-1:0]  instruction_c;
logic [31:0]        instruct_fo_r;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

instruct_mem #(
  .DWIDTH(DWIDTH),
  .MEM_SIZE(MEM_SIZE)
)
instruct_mem (
  .Clk_Core(Clk_Core),
  .Rst_Core_N(Rst_Core_N),
  .Program_Count(pc_fo_r),
  .Instruction(instruction_c)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

assign pc_fo = pc_fo_r;
assign instruct_fo = instruct_fo_r;
assign pc_plus_fo = pc_fo_r + 32'd4;

// Generate PC
always_ff @(posedge Clk_Core or negedge Rst_Core_N) begin
  if (~Rst_Core_N) begin
    pc_fo_r         <= PC_INIT;
  end
  else begin
    if (flush_fi) begin
      pc_fo_r <= pc_imm_fi;
    end
    else if (stall_fi) begin
      pc_fo_r <= pc_fo_r;
    end
    else begin
      pc_fo_r <= program_count_next_c;
    end
  end
end

assign program_count_plus_c = pc_fo_r + 32'd4;
assign program_count_next_c = flush_fi ? (pc_imm_fi + 32'd4) : program_count_plus_c;

// Fetch Instruct
always_ff @(posedge Clk_Core or negedge Rst_Core_N) begin
  if (~Rst_Core_N) begin
    instruct_fo_r <= INSTR_NOP;
  end
  else begin
    if (flush_fi) begin
      instruct_fo_r <= INSTR_NOP;
    end
    else if (stall_fi) begin
      instruct_fo_r <= instruct_fo_r;
    end
    else begin
      instruct_fo_r <= instruction_c;
    end
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
fetch_cycle fetch #(
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