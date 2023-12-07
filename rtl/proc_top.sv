//////////////////////////////////////////////////////////////// 
// Engineer: Evan Apinis
// 
// Module Name: proc_top.sv
// Project Name: RV32I 
// Description: 
// 
// RV32I processor top file including hart datapath and
// memory modules
//
// Revision 0.01 - File Created
// 
////////////////////////////////////////////////////////////////

module proc_top #(
  parameter DWIDTH = 32
)(
  input logic Clk_Core
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

(* DONT_TOUCH = "TRUE" *)logic Clk_Core_P;
(* DONT_TOUCH = "TRUE" *)logic Clk_Core_N;
(* DONT_TOUCH = "TRUE" *)logic Clk_Core_W;
(* DONT_TOUCH = "TRUE" *)logic locked;

// Instruction Mem Interface Nets
(* DONT_TOUCH = "TRUE" *)logic [DWIDTH-1:0]  program_count;
(* DONT_TOUCH = "TRUE" *)logic [31:0]        instruction;

// Data Mem Interface Nets
(* DONT_TOUCH = "TRUE" *)logic [DWIDTH-1:0]  data_mem_address;
(* DONT_TOUCH = "TRUE" *)logic [DWIDTH-1:0]  data_mem_read;
(* DONT_TOUCH = "TRUE" *)logic [DWIDTH-1:0]  data_mem_write;
(* DONT_TOUCH = "TRUE" *)logic [3:0]         data_mem_write_ctrl;
(* DONT_TOUCH = "TRUE" *)logic               data_mem_read_ctrl;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

core core_1 (
  .Clk_Core       (Clk_Core_P),
  .Clk_Core_WB    (Clk_Core_W),
  .Rst_Core_N     (1'b1),
  .Instruction    (instruction),
  .Program_Count  (program_count),
  .Mem_Data_Read  (data_mem_read),
  .Mem_Data_Write (data_mem_write),
  .Mem_Data_Addr  (data_mem_address),
  .Mem_Read_Ctrl  (data_mem_read_ctrl),
  .Mem_Write_Ctrl (data_mem_write_ctrl),
  .Locked         (locked)
);

instruct_mem instruct_mem (
  .Clk_Core       (Clk_Core_P),
  .Rst_Core_N     (1'b1),
  .Program_Count  (program_count),
  .Instruction    (instruction)
);

data_mem data_mem (
  .Clk_Core         (Clk_Core_N),
  .Read_Ctrl        (data_mem_read_ctrl),
  .Write_Ctrl       (data_mem_write_ctrl),
  .Mem_Data_Address (data_mem_address),
  .Mem_Data_Write   (data_mem_write),
  .Mem_Data_Read    (data_mem_read)
);

clk_mmcm clk_mmcm (
    .clk_in1(Clk_Core),
    .resetn(1'b1),
    .clk_out1(Clk_Core_P),
    .clk_out2(Clk_Core_N),
    .clk_out3(Clk_Core_W),
    .locked(locked)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

assign Addr = data_mem_read[15:0];

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
proc_top #(
  .DWIDTH()
)
proc_top (
  .Clk_Core(),
  .Rst_Core_N()
);
*/

endmodule