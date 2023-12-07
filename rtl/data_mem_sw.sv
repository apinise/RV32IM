//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2023 08:29:27 PM
// Design Name: 
// Module Name: data_mem_lw.sv
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

module data_mem_sw (
	input  logic [2:0]	Lw_Sw_OP,		    // Control Signal OP
	input  logic [3:0]  Write_Ctrl,			// Byte Write Enable
	input  logic [31:0]	Register_In_B,	// Data in from Reg B
	output logic [31:0] Data_Mem_Write	// Data to write to mem
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

localparam SB_OP_STORE = 3'd5; //store byte opcode
localparam SH_OP_STORE = 3'd6; //store half word opcode
localparam SW_OP_STORE = 3'd7; //store word opcode

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always_comb begin
	Data_Mem_Write = '0;
	casez(Lw_Sw_OP)
		SB_OP_STORE: begin
			casez(Write_Ctrl)
				4'b0001: Data_Mem_Write = {24'd0, Register_In_B[7:0]};			  // Store lower byte of reg into lower byte of mem
				4'b0010: Data_Mem_Write = {16'd0, Register_In_B[7:0], 8'd0};	// Store lower byte of reg into middle lower byte of mem
				4'b0100: Data_Mem_Write = {8'd0, Register_In_B[7:0], 16'd0};	// Store lower byte of reg into middle upper byte of mem
				4'b1000: Data_Mem_Write = {Register_In_B[7:0], 24'd0};			  // Store lower byte of reg into upper byte of mem
			endcase
		end
		SH_OP_STORE: begin
			casez(Write_Ctrl)
				4'b0011: Data_Mem_Write = {16'd0, Register_In_B[15:0]};	// Store lower 2 bytes of reg into lower 2 bytes of mem
				4'b1100: Data_Mem_Write = {Register_In_B[15:0], 16'd0};	// Store lower 2 bytes of reg into upper 2 bytes of mem
			endcase
		end
		SW_OP_STORE: Data_Mem_Write = Register_In_B;	// Store reg into mem
	endcase
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
data_mem_sw data_mem_sw (
  .Lw_Sw_OP(),
  .Write_Ctrl(),
  .Register_In_B(),
  .Data_Mem_Write()
);
*/

endmodule