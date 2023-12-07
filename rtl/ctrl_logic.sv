//////////////////////////////////////////////////////////////// 
// Engineer: Evan Apinis
// 
// Module Name: ctrl_logic.sv
// Project Name: RV32I 
// Description: 
// 
// Control logic for RV32I to decode instructions and control
// datapathing.
//
// Revision 0.01 - File Created
// 
////////////////////////////////////////////////////////////////

module ctrl_logic (
  input   logic [31:0]  Instruction,
  // ALU control signal
  output  logic [3:0]   ALU_Opcode,
  output  logic [2:0]   MUL_Opcode,
  // Register control signal
  output  logic         Reg_Wr_En,
  // Mux control signals
  output  logic         PC_Sel,
  output  logic         ALU_Input_A_Sel,
  output  logic         ALU_Input_B_Sel,
  output  logic [1:0]   Reg_WB_Sel,
  output  logic [1:0]   Imm_Gen_Sel,
  // Data Mem SW control signals
  output  logic [2:0]   Lw_Sw_OP,
  output  logic         Store_Word_En,
  output  logic         Read_Ctrl,
  // Branch Comparator control signals
  input   logic         Branch_Equal,
  input   logic         Branch_Less_Than,
  output  logic         Branch_Un_Sel,
  // HALT OPCODE CNTRL
  output  logic         Clk_Enable
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

// OPCODES
localparam OPCODE_ALU_R 	  = 7'b0110011; //Register types
localparam OPCODE_ALU_IMM_I = 7'b0010011; //Immediate types
localparam OPCODE_LW 		    = 7'b0000011; //Load word types
localparam OPCODE_SW 		    = 7'b0100011; //Store word types
localparam OPCODE_BRANCH 	  = 7'b1100011; //Branch types
localparam OPCODE_JALR 		  = 7'b1100111;
localparam OPCODE_JAL 		  = 7'b1101111;
localparam OPCODE_LUI 		  = 7'b0110111;
localparam OPCODE_AUIPC 	  = 7'b0010111;
localparam OPCODE_HALT      = 7'b1111111;

// Decoded ALU OPCODES
localparam ALU_OP_ADD 	= 4'd0;
localparam ALU_OP_SUB 	= 4'd1;
localparam ALU_OP_SLL 	= 4'd2;
localparam ALU_OP_SLT 	= 4'd3;
localparam ALU_OP_SLTU 	= 4'd4;
localparam ALU_OP_XOR 	= 4'd5;
localparam ALU_OP_SRL 	= 4'd6;
localparam ALU_OP_SRA 	= 4'd7;
localparam ALU_OP_OR 	  = 4'd8;
localparam ALU_OP_AND 	= 4'd9;
localparam ALU_OP_M     = 4'd10;

// LW_RW Instruction OPCODES 
localparam LB_OP_LOAD 	= 3'd0;
localparam LH_OP_LOAD 	= 3'd1;
localparam LW_OP_LOAD 	= 3'd2;
localparam LBU_OP_LOAD 	= 3'd3;
localparam LHU_OP_LOAD 	= 3'd4;
localparam SB_OP_STORE 	= 3'd5;
localparam SH_OP_STORE 	= 3'd6;
localparam SW_OP_STORE 	= 3'd7;

// Load Word Funct3
localparam LB_LOAD = 3'b000;
localparam LH_LOAD = 3'b001;
localparam LW_LOAD = 3'b010;
localparam LBU_LOAD = 3'b100;
localparam LHU_LOAD = 3'b101;
    
// Store Word Funct3
localparam SB_STORE = 3'b000;
localparam SH_STORE = 3'b001;
localparam SW_STORE = 3'b010;

// Branch FUNCT3
localparam BEQ = 3'b000;
localparam BNE = 3'b001;
localparam BLT = 3'b100;
localparam BGE = 3'b101;
localparam BLTU = 3'b110;
localparam BGEU = 3'b111;

// M Type Instruction FUNCT3 ALU CODES
localparam MUL    = 3'b000;
localparam MULH   = 3'b001;
localparam MULHSU = 3'b010;
localparam MULHU  = 3'b011;
localparam DIV    = 3'b100;
localparam DIVU   = 3'b101;
localparam REM    = 3'b110;
localparam REMU   = 3'b111;

// R Type Instruction ALU OPCODES
localparam ADD_SUB 	= 3'b000;
localparam SLL 		  = 3'b001;
localparam SLT 		  = 3'b010;
localparam SLTU 	  = 3'b011;
localparam XOR 		  = 3'b100;
localparam SRL_SRA 	= 3'b101;
localparam OR 		  = 3'b110;
localparam AND 		  = 3'b111;

// Immediate Gen Types
localparam I_TYPE = 2'b00;
localparam S_TYPE = 2'b01;
localparam B_TYPE = 2'b10;
localparam J_TYPE = 2'b11;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// R Type Encoded Instructions
logic [6:0] instruct_funct7;
logic [2:0] instruct_funct3;

// OPCODE
logic [6:0] instruct_opcode;

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always_comb begin

  // Reset Regs
  ALU_Opcode      = '0;
  MUL_Opcode      = '0;
  Reg_Wr_En       = '0;
  PC_Sel          = '0;
  ALU_Input_A_Sel = '0;
  ALU_Input_B_Sel = '0;
  Reg_WB_Sel      = '0;
  Imm_Gen_Sel     = '0;
  Lw_Sw_OP        = '0;
  Store_Word_En   = '0;
  Read_Ctrl       = '0;
  Branch_Un_Sel   = '0;
  Clk_Enable      = '1;
  
  // Set Regs to Instruct Values
  instruct_opcode = Instruction[6:0];
  instruct_funct7 = Instruction[31:25];
  instruct_funct3 = Instruction[14:12];
  
  casez(instruct_opcode)
  
    OPCODE_HALT: begin
      Clk_Enable = 1'b0;
      Read_Ctrl  = 1'b1;
    end
  
    OPCODE_ALU_R: begin
      Reg_Wr_En       = 1'b1;   // Emable write to register
      PC_Sel          = 1'b0;   // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;   // Use register value as ALU input
      ALU_Input_B_Sel = 1'b0;   // Use register value as ALU input
      Reg_WB_Sel      = 2'b01;  // Write back ALU data to Register
      Imm_Gen_Sel     = 2'b00;  // Imm Gen value does not matter
      Store_Word_En   = 1'b0;   // Disable storing word to data mem
      Read_Ctrl       = 1'b0;   // Do not read from mem
      if (instruct_funct7[0] == 1'b1) begin
        ALU_Opcode = ALU_OP_M;
        MUL_Opcode = instruct_funct3;
      end
      else begin
        casez(instruct_funct3)
          ADD_SUB:  ALU_Opcode = (instruct_funct7[5] == 1'b1) ? ALU_OP_SUB : ALU_OP_ADD;
          SLL:      ALU_Opcode = ALU_OP_SLL;
          SLT:      ALU_Opcode = ALU_OP_SLT;
          SLTU:     ALU_Opcode = ALU_OP_SLTU;
          XOR:      ALU_Opcode = ALU_OP_XOR;
          SRL_SRA:  ALU_Opcode = (instruct_funct7[5] == 1'b1) ? ALU_OP_SRA : ALU_OP_SRL;
          OR:       ALU_Opcode = ALU_OP_OR;
          AND:      ALU_Opcode = ALU_OP_AND;
        endcase
      end
    end
    
    OPCODE_ALU_IMM_I: begin
      Reg_Wr_En       = 1'b1;   // Emable write to register
      PC_Sel          = 1'b0;   // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;   // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;   // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b01;  // Write back ALU data to Register
      Imm_Gen_Sel     = 2'b00;  // Generates I type immediate
      Store_Word_En   = 1'b0;   // Disable storing word to data mem
      Read_Ctrl       = 1'b0;   // Do not read from mem
      casez(instruct_funct3)
        ADD_SUB:  ALU_Opcode = ALU_OP_ADD;
        SLL:      ALU_Opcode = ALU_OP_SLL;
        SLT:      ALU_Opcode = ALU_OP_SLT;
        SLTU:     ALU_Opcode = ALU_OP_SLTU;
        XOR:      ALU_Opcode = ALU_OP_XOR;
        SRL_SRA:  ALU_Opcode = (instruct_funct7[5] == 1'b1) ? ALU_OP_SRA : ALU_OP_SRL;
        OR:       ALU_Opcode = ALU_OP_OR;
        AND:      ALU_Opcode = ALU_OP_AND;
      endcase
    end
    
    OPCODE_SW: begin
      Reg_Wr_En       = 1'b0;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b00;      // Value does not matter
      Imm_Gen_Sel     = 2'b01;      // Generates S type 
      ALU_Opcode      = ALU_OP_ADD; // ADD immediate to base address
      Store_Word_En   = 1'b1;       // Enable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem
      casez(instruct_funct3)
        SB_STORE: Lw_Sw_OP = SB_OP_STORE;
        SH_STORE: Lw_Sw_OP = SH_OP_STORE;
        SW_STORE: Lw_Sw_OP = SW_OP_STORE;
        default: begin
          $display("Illegal SW FUNCT3");
        end
      endcase
    end
    
    OPCODE_LW: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b00;      // Output from data mem
      Imm_Gen_Sel     = 2'b00;      // Generates I type 
      ALU_Opcode      = ALU_OP_ADD; // ADD immediate to base address
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b1;       // Enable read from mem
      casez(instruct_funct3)
        LB_LOAD:  Lw_Sw_OP = LB_OP_LOAD;
        LH_LOAD:  Lw_Sw_OP = LH_OP_LOAD;
        LW_LOAD:  Lw_Sw_OP = LW_OP_LOAD;
        LBU_LOAD: Lw_Sw_OP = LBU_OP_LOAD;
        LHU_LOAD: Lw_Sw_OP = LHU_OP_LOAD;
        default: begin
          $display("Illegal LW FUNCT3");
        end
      endcase
    end
    
    OPCODE_BRANCH: begin
      Reg_Wr_En       = 1'b0;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b1;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b00;      // Value does not matter
      Imm_Gen_Sel     = 2'b10;      // Generates B type 
      ALU_Opcode      = ALU_OP_ADD; // ADD immediate to base PC
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem
      casez(instruct_funct3)
        BEQ: begin
          Branch_Un_Sel = 1'b0;
          PC_Sel        = (Branch_Equal == 1'b1) ? 1'b1 : 1'b0;
        end
        BNE: begin
          Branch_Un_Sel = 1'b0;
          PC_Sel        = (Branch_Equal == 1'b1) ? 1'b0 : 1'b1;
        end
        BLT: begin
          Branch_Un_Sel = 1'b0;
          PC_Sel        = (Branch_Less_Than == 1'b1) ? 1'b1 : 1'b0;
        end
        BGE: begin
          Branch_Un_Sel = 1'b0;
          PC_Sel        = (Branch_Less_Than == 1'b1) ? 1'b0 : 1'b1;
        end
        BLTU: begin
          Branch_Un_Sel = 1'b1;
          PC_Sel        = (Branch_Less_Than == 1'b1) ? 1'b1 : 1'b0;
        end
        BGEU: begin
          Branch_Un_Sel = 1'b1;
          PC_Sel        = (Branch_Less_Than == 1'b1) ? 1'b0 : 1'b1;
        end
      endcase
    end
    
    OPCODE_JAL: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b1;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b1;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b10;      // Write Back PC4
      Imm_Gen_Sel     = 2'b11;      // Generates B type 
      ALU_Opcode      = ALU_OP_ADD; // ADD immediate to base PC
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem      
    end
    
    OPCODE_JALR: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b1;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b10;      // Write Back PC4
      Imm_Gen_Sel     = 2'b00;      // Generates I type 
      ALU_Opcode      = ALU_OP_ADD; // ADD immediate to base PC
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem    
    end
    
    OPCODE_LUI: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b0;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b01;      // Write Back ALU
      Imm_Gen_Sel     = 2'b11;      // Generates J type 
      ALU_Opcode      = ALU_OP_ADD; // ADD immediate to reg
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem 
    end
    
    OPCODE_AUIPC: begin
      Reg_Wr_En       = 1'b1;       // Emable write to register
      PC_Sel          = 1'b0;       // Set new program count as PC+4
      ALU_Input_A_Sel = 1'b1;       // Use register value as ALU input
      ALU_Input_B_Sel = 1'b1;       // Use immediate value as ALU input
      Reg_WB_Sel      = 2'b01;      // Write Back ALU
      Imm_Gen_Sel     = 2'b11;      // Generates I type 
      ALU_Opcode      = ALU_OP_ADD; // ADD immediate to base PC
      Store_Word_En   = 1'b0;       // Disable storing word to data mem
      Read_Ctrl       = 1'b0;       // Do not read from mem 
    end
    
    default: begin
      $display("Illegal OPCODE");
    end
  endcase
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
ctrl_logic ctrl_logic (
  .Instruction(),
  .ALU_Opcode(),
  .MUL_Opcode(),
  .Reg_Wr_En(),
  .PC_Sel(),
  .ALU_Input_A_Sel(),
  .ALU_Input_B_Sel(),
  .Reg_WB_Sel(),
  .Imm_Gen_Sel(),
  .Lw_Sw_OP(),
  .Store_Word_En(),
  .Branch_Equal(),
  .Branch_Less_Than(),
  .Branch_Un_Sel(),
  .Clk_Enable()
);
*/
endmodule