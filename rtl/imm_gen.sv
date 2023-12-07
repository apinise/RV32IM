//////////////////////////////////////////////////////////////// 
// Engineer: Evan Apinis
// 
// Module Name: imm_gen.sv
// Project Name: RV32I 
// Description: 
// 
// RV32I hart datapath excluding memory modules
// 
//
// Revision 0.01 - File Created
// 
////////////////////////////////////////////////////////////////

module imm_gen #(
  parameter DWIDTH = 32
)(
  input   logic [31:0]        Instruction,
  input   logic [1:0]         Imm_Sel,
  output  logic [DWIDTH-1:0]  Imm_Gen_Out
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

// Immediate Gen Types
localparam I_TYPE = 2'b00;
localparam S_TYPE = 2'b01;
localparam B_TYPE = 2'b10;
localparam J_TYPE = 2'b11;

localparam SLL      = 3'b001;
localparam SRL_SRA  = 3'b101;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [11:0] imm_i_type;
logic [11:0] imm_s_type;
logic [12:0] imm_b_type;
logic [20:0] imm_j_type;

logic [2:0] instruct_funct3;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always_comb begin
  Imm_Gen_Out = '0;
  instruct_funct3 = Instruction[14:12];
  casez (Imm_Sel)
    I_TYPE: begin
      if (instruct_funct3 == SLL || instruct_funct3 == SRL_SRA) begin
        Imm_Gen_Out = {{26{1'b0}},Instruction[24:20]};
      end
      else begin
        Imm_Gen_Out = (Instruction[31] == 1'b1) ? {{21{1'b1}},Instruction[30:20]} : {{21{1'b0}},Instruction[30:20]};
      end
    end  
    S_TYPE: Imm_Gen_Out = (Instruction[31] == 1'b1) ? {{21{1'b1}},Instruction[30:25],Instruction[11:7]} : {{21{1'b0}},Instruction[30:25],Instruction[11:7]};
    B_TYPE: Imm_Gen_Out = (Instruction[31] == 1'b1) ? {{20{1'b1}},Instruction[7],Instruction[30:25],Instruction[11:8],1'b0} : {{20{1'b0}},Instruction[7],Instruction[30:25],Instruction[11:8],1'b0};
    J_TYPE: begin
      if (Instruction[6:0] == 7'b1101111) begin
        Imm_Gen_Out = (Instruction[31] == 1'b1) ? {{12{1'b1}},Instruction[19:12],Instruction[20],Instruction[30:21],1'b0} : {{12{1'b0}},Instruction[19:12],Instruction[20],Instruction[30:21],1'b0};
      end
      else begin
        Imm_Gen_Out = (Instruction[31] == 1'b1) ? {{13{1'b1}},Instruction[30:12]} : {{13{1'b0}},Instruction[30:12]};
      end
    end
  endcase
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
imm_gen #(
  .DWIDTH()
)
imm_gen (
  .Instruction(),
  .Imm_Sel(),
  .Imm_Gen_Out()
);
*/
endmodule