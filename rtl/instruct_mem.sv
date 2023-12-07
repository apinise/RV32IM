//////////////////////////////////////////////////////////////// 
// Engineer: Evan Apinis
// 
// Module Name: instruct_mem.sv
// Project Name: RV32I 
// Description: 
// 
// Instruction memory for RV32I hart
// 
//
// Revision 0.01 - File Created
// 
////////////////////////////////////////////////////////////////

module instruct_mem #(
  parameter DWIDTH = 32,
  parameter MEM_SIZE = 16384 // Mem size in words
)(
  input   logic               Clk_Core,
  input   logic               Rst_Core_N,
  input   logic [DWIDTH-1:0]  Program_Count,
  output  logic [31:0]        Instruction
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

localparam ADDR_SIZE = $clog2(MEM_SIZE); // Parameterized address size based on mem size in words

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [31:0] instr_mem [0:MEM_SIZE-1];  // Create BRAM
logic [ADDR_SIZE-1:0] 	rom_addr;	      // Read address net

integer i;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

assign rom_addr = Program_Count[ADDR_SIZE+1:2]; // Assign effective address range
assign Instruction = instr_mem[rom_addr];       //Asynchronous read from instruct mem

initial begin
  for (i=0; i<MEM_SIZE; i++) begin //Fill Instruct with 0 before writing from file
    instr_mem[i] = '0;
  end
  instr_mem[0] = 32'h00c00513;
  instr_mem[1] = 32'h00c000ef;
  instr_mem[2] = 32'h00a02023;
  instr_mem[3] = 32'h0000007f;
  instr_mem[4] = 32'hff810113;
  instr_mem[5] = 32'h00112223;
  instr_mem[6] = 32'h00a12023;
  instr_mem[7] = 32'hfff50513;
  instr_mem[8] = 32'h00051863;
  instr_mem[9] = 32'h00100513;
  instr_mem[10] = 32'h00810113;
  instr_mem[11] = 32'h00008067;
  instr_mem[12] = 32'hfe1ff0ef;
  instr_mem[13] = 32'h00050293;
  instr_mem[14] = 32'h00012503;
  instr_mem[15] = 32'h00412083;
  instr_mem[16] = 32'h00810113;
  instr_mem[17] = 32'h02550533;
  instr_mem[18] = 32'h00008067;
  //$readmemh("../../../../../../project/mem_files/instruct_file_3.txt", instr_mem); //read hex from instruct file
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
instruct_mem #(
  .DWIDTH(32)
  .MEM_SIZE(16384)
)
instruct_mem (
  .Clk_Core(),
  .Rst_Core_N(),
  .Program_Count(),
  .Instruction()
);
*/

endmodule