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

module data_mem_lw (
	input  logic [2:0]	Lw_Sw_OP,
	input  logic [1:0]	Byte_Loc,
	input  logic [31:0]	Data_Mem_Read,
	output logic [31:0] Data_Mem_Read_Out
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

localparam LB_OP_LOAD 	= 3'd0; //load byte signed
localparam LH_OP_LOAD 	= 3'd1; //load half word signed
localparam LW_OP_LOAD 	= 3'd2; //load word
localparam LBU_OP_LOAD 	= 3'd3; //load byte unsigned
localparam LHU_OP_LOAD 	= 3'd4; //load half word unsigned

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
	Data_Mem_Read_Out = '0;
	casez(Lw_Sw_OP)
		LB_OP_LOAD: begin
			casez(Byte_Loc)
				2'b00: Data_Mem_Read_Out = (Data_Mem_Read[7] == 1'b1)  ? {24'hFFFFFF, Data_Mem_Read[7:0]}  : {24'd0, Data_Mem_Read[7:0]};
				2'b01: Data_Mem_Read_Out = (Data_Mem_Read[15] == 1'b1) ? {24'hFFFFFF, Data_Mem_Read[15:8]} : {24'd0, Data_Mem_Read[15:8]};
				2'b10: Data_Mem_Read_Out = (Data_Mem_Read[23] == 1'b1) ? {24'hFFFFFF, Data_Mem_Read[23:16]} : {24'd0, Data_Mem_Read[23:16]};
				2'b11: Data_Mem_Read_Out = (Data_Mem_Read[31] == 1'b1) ? {24'hFFFFFF, Data_Mem_Read[31:24]} : {24'd0, Data_Mem_Read[31:24]};
			endcase
		end
		LH_OP_LOAD: begin
			casez(Byte_Loc)
				2'b00: Data_Mem_Read_Out = (Data_Mem_Read[15] == 1'b1) ? {16'hFFFF, Data_Mem_Read[15:0]}  : {16'd0, Data_Mem_Read[15:0]};
				2'b10: Data_Mem_Read_Out = (Data_Mem_Read[31] == 1'b1) ? {16'hFFFF, Data_Mem_Read[31:16]} : {16'd0, Data_Mem_Read[31:16]};
			endcase
		end
		LW_OP_LOAD: Data_Mem_Read_Out = Data_Mem_Read;
		LBU_OP_LOAD: begin
			casez(Byte_Loc)
				2'b00: Data_Mem_Read_Out = {24'd0, Data_Mem_Read[7:0]};
				2'b01: Data_Mem_Read_Out = {24'd0, Data_Mem_Read[15:8]};
				2'b10: Data_Mem_Read_Out = {24'd0, Data_Mem_Read[23:16]};
				2'b11: Data_Mem_Read_Out = {24'd0, Data_Mem_Read[31:24]};
			endcase
		end
		LHU_OP_LOAD:
			casez(Byte_Loc)
				2'b00: Data_Mem_Read_Out = {16'd0, Data_Mem_Read[15:0]};
				2'b10: Data_Mem_Read_Out = {16'd0, Data_Mem_Read[31:16]};
			endcase
	endcase
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
data_mem_lw data_mem_lw (
  .Lw_Sw_OP(),
  .Byte_Loc(),
  .Data_Mem_Read(),
  .Data_Mem_Read_Out()
);
*/

endmodule