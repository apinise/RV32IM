//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2023 03:30:56 PM
// Design Name: 
// Module Name: data_mem.sv
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

module data_mem #(
  parameter MEM_SIZE  = 16384,
  parameter NUM_COL   = 4,
  parameter COL_WIDTH = 8
)(
  input   logic        Clk_Core,			    // 100 MHz Core Clock				
  input   logic        Read_Ctrl,		      // Read Control
  input   logic [3:0]  Write_Ctrl,		    // Byte Write Enable
  input   logic [31:0] Mem_Data_Address,	// Data Mem Address
  input   logic [31:0] Mem_Data_Write,		// Data Mem Write Port
  output  logic [31:0] Mem_Data_Read		  // Data Mem Read Port
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

localparam DWIDTH = NUM_COL * COL_WIDTH;	// Create DWIDTH Parameter
localparam ADDR_SIZE = $clog2(MEM_SIZE);	// Create Address size

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [DWIDTH-1:0]    data_mem [MEM_SIZE-1:0];	// Create BRAM
logic [ADDR_SIZE-1:0] mem_address;				      // Create MEM address

genvar  i;
integer j;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

initial begin //initialize data memory to all 0
  for(j=0; j<MEM_SIZE; j=j+1) begin
    data_mem[j] = '0;
  end
end

assign mem_address = Mem_Data_Address[ADDR_SIZE+1:2];	// Assign effective address range

// Write Port Generate
generate
  for (i=0; i<NUM_COL; i=i+1) begin
    always_ff @(posedge Clk_Core) begin
      if (mem_address < MEM_SIZE) begin
        if (Write_Ctrl[i]) begin	// Makes 4 locations per word
          data_mem[mem_address][i*COL_WIDTH +: COL_WIDTH] <= Mem_Data_Write[i*COL_WIDTH +: COL_WIDTH];
        end
      end
    end
  end
endgenerate

// Read Port
always_ff @(posedge Clk_Core) begin
  if (Read_Ctrl && ((mem_address) < MEM_SIZE)) begin 
    Mem_Data_Read <= data_mem[mem_address];
  end 
  else begin
    Mem_Data_Read <= 'z;
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
data_mem data_mem (
  .Clk_Core(),
  .Read_Ctrl(),
  .Write_Ctrl(),
  .Mem_Data_Address(),
  .Mem_Data_Write(),
  .Mem_Data_Read()
);
*/

endmodule