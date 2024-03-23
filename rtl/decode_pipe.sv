module decode_pipe #(
  parameter DWIDTH = 32
)(
  // Global Inputs
  input   logic   Clk_Core,
  input   logic   Rst_Core_N,
  // Inputs From Fetch Cycle
  input   logic [DWIDTH-1:0]  instruct_di,
  input   logic [DWIDTH-1:0]  pc_di,
  input   logic [DWIDTH-1:0]  pc_plus_di,
  // Inputs From WB
  input   logic [4:0]         wr_addr_1_di,
  input   logic [DWIDTH-1:0]  wr_data_1_di,
  input   logic               reg_wr_en_di,
  // Register Ouptuts
  output  logic [DWIDTH-1:0]  rd_data_1_do,
  output  logic [DWIDTH-1:0]  rd_data_2_do,
  // Immediate Outputs
  output  logic [DWIDTH-1:0]  immediate_do,
  // PC Outputs
  output  logic [DWIDTH-1:0]  pc_do,
  output  logic [DWIDTH-1:0]  pc_plus_do
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [DWIDTH-1:0]  read_data_port_1_c;
logic [DWIDTH-1:0]  read_data_port_2_c;

logic [6:0] opcode;
logic [4:0] rd;
logic [4:0] rs1;
logic [4:0] rs2;
logic [2:0] funct3;
logic [6:0] funct7;

logic [DWIDTH-1:0]  immediate_c;

logic [1:0] imm_sel_c;

// Control logic nets
logic [3:0] alu_opcode_c;
logic [2:0] mul_opcode_c;
logic       reg_wr_en_c;
logic       pc_sel_c;
logic       alu_input_a_sel_c;
logic       alu_input_b_sel_c;
logic [1:0] reg_wb_sel_c;
logic [2:0] lw_sw_op_c;
logic       sw_en_c;
logic       read_ctrl_c;
logic       branch_equal_c;
logic       branch_lt_c;
logic       branch_un_sel_c;
logic       clk_enable_c;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

register_file registers(
  .Clk_Core(Clk_Core),
  .Rst_Core_N(Rst_Core_N),
  .Read_Addr_Port_1(rs1),
  .Read_Data_Port_1(read_data_port_1_c),
  .Read_Addr_Port_2(rs2),
  .Read_Data_Port_2(read_data_port_2_c),
  .Write_Addr_Port_1(wr_addr_1_di),
  .Write_Data_Port_1(wr_data_1_di),
  .Wr_En(reg_wr_en_di)
);

imm_gen #(
  .DWIDTH(DWIDTH)
)
imm_gen (
  .Instruction(instruct_di),
  .Imm_Sel(imm_sel_c),
  .Imm_Gen_Out(immediate_c)
);

ctrl_logic ctrl_logic (
  .Instruction(instruct_di),
  .ALU_Opcode(alu_opcode_c),
  .MUL_Opcode(mul_opcode_c),
  .Reg_Wr_En(reg_wr_en_c),
  .PC_Sel(pc_sel_c),
  .ALU_Input_A_Sel(alu_input_a_sel_c),
  .ALU_Input_B_Sel(alu_input_b_sel_c),
  .Reg_WB_Sel(reg_wb_sel_c),
  .Imm_Gen_Sel(imm_sel_c),
  .Lw_Sw_OP(lw_sw_op_c),
  .Store_Word_En(sw_en_c),
  .Read_Ctrl(read_ctrl_c),
  .Branch_Equal(branch_equal_c),
  .Branch_Less_Than(branch_lt_c),
  .Branch_Un_Sel(branch_un_sel_c),
  .Clk_Enable(clk_enable_c)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

assign opcode = instruct_di[6:0];
assign rd     = instruct_di[11:7];
assign rs1    = instruct_di[19:15];
assign rs2    = instruct_di[24:20];
assign funct3 = instruct_di[14:12];
assign funct7 = instruct_di[31:25];

always_ff @(posedge Clk_Core or negedge Rst_Core_N) begin
  if (~Rst_Core_N) begin
    rd_data_1_do  <= '0;
    rd_data_2_do  <= '0;
    pc_do         <= '0;
    pc_plus_do    <= '0;
    immediate_do  <= '0;
  end
  else begin
    rd_data_1_do  <= read_data_port_1_c;
    rd_data_2_do  <= read_data_port_2_c;
    pc_do         <= pc_di;
    pc_plus_do    <= pc_plus_di;
    immediate_do  <= immediate_c;
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////

endmodule