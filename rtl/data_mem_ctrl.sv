module data_mem_ctrl #(
  parameter DWIDTH = 32
)(
  input   logic [1:0]         Mem_Addr_LSB,
  input   logic [2:0]         Lw_Sw_OP,
  input   logic [DWIDTH-1:0]  Register_In_B,
  input   logic [DWIDTH-1:0]  Data_Mem_Read,
  input   logic               Store_Word_Ctrl,
  output  logic [3:0]         Data_Mem_Write_Ctrl,
  output  logic [DWIDTH-1:0]  Data_Mem_Read_Out,
  output  logic [DWIDTH-1:0]  Data_Mem_Write_Out
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

localparam LB_OP_LOAD 	= 3'd0; //load byte signed
localparam LH_OP_LOAD 	= 3'd1; //load half word signed
localparam LW_OP_LOAD 	= 3'd2; //load word
localparam LBU_OP_LOAD 	= 3'd3; //load byte unsigned
localparam LHU_OP_LOAD 	= 3'd4; //load half word unsigned
localparam SB_OP_STORE  = 3'd5; //store byte opcode
localparam SH_OP_STORE  = 3'd6; //store half word opcode
localparam SW_OP_STORE  = 3'd7; //store word opcode

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

data_mem_lw data_mem_lw (
  .Lw_Sw_OP           (Lw_Sw_OP),         // Load Store Operation Codes
  .Byte_Loc           (Mem_Addr_LSB),     // LSB Of Mem address
  .Data_Mem_Read      (Data_Mem_Read),    // Data read from memory
  .Data_Mem_Read_Out  (Data_Mem_Read_Out) // Data to write into register
);

data_mem_sw data_mem_sw (
  .Lw_Sw_OP       (Lw_Sw_OP),             // Load Store Operation Codes
  .Write_Ctrl     (Data_Mem_Write_Ctrl),  // Mem Write Enable Ctrl
  .Register_In_B  (Register_In_B),        // Data to write into Mem from reg
  .Data_Mem_Write (Data_Mem_Write_Out)    // Data to write to Mem
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always_comb begin
  Data_Mem_Write_Ctrl = 4'b0000;
  if (Store_Word_Ctrl) begin
    casez (Mem_Addr_LSB)
      2'b00: begin
        casez (Lw_Sw_OP)
          SB_OP_STORE: Data_Mem_Write_Ctrl = 4'b0001;
          SH_OP_STORE: Data_Mem_Write_Ctrl = 4'b0011;
          SW_OP_STORE: Data_Mem_Write_Ctrl = 4'b1111;
        endcase
      end
      2'b01: begin
        casez (Lw_Sw_OP)
          SB_OP_STORE: Data_Mem_Write_Ctrl = 4'b0010;
        endcase
      end
      2'b10: begin
        casez (Lw_Sw_OP)
          SB_OP_STORE: Data_Mem_Write_Ctrl = 4'b0100;
          SH_OP_STORE: Data_Mem_Write_Ctrl = 4'b1100;
        endcase
      end
      2'b11: begin
        casez (Lw_Sw_OP)
          SB_OP_STORE: Data_Mem_Write_Ctrl = 4'b1000;
        endcase
      end
    endcase
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
data_mem_ctrl data_mem_ctrl (
  .Mem_Addr_LSB(),
  .Lw_Sw_OP(),
  .Register_In_B(),
  .Data_Mem_Read(),
  .Store_Word_Ctrl(),
  .Data_Mem_Write_Ctrl(),
  .Data_Mem_Read_Out(),
  .Data_Mem_Write_Out()
);
*/

endmodule