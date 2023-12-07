//////////////////////////////////////////////////////////////// 
// Engineer: Evan Apinis
// 
// Module Name: alu.sv
// Project Name: RV32I 
// Description: 
// 
// ALU module for a RV32I CPU supporting the entire
// base instruction set.
//
// Revision 0.01 - File Created
// 
////////////////////////////////////////////////////////////////


module alu #(
  parameter DWIDTH = 32
)(
  input   logic [DWIDTH-1:0]  ALU_In_A, //Operand A
  input   logic [DWIDTH-1:0]  ALU_In_B, //Operand B
  input   logic [3:0]         ALU_OP,   //ALU Opcode
  input   logic [2:0]         MUL_OP,   //MUL DIV Opcode
  output  logic [DWIDTH-1:0]  ALU_Out,  //ALU Result
  output  logic               ALU_Zero_Flag
);

/*
-----------------------------------------------
|ALU_Sel |   ALU_OPERATION              |
-----------------------------------------------
|  0000  |   ALU_Out = A + B;           |  ADD
-----------------------------------------------
|  0001  |   ALU_Out = A - B;           |  SUB
-----------------------------------------------
|  0010  |   ALU_Out = A << B;          |  SLL
-----------------------------------------------
|  0011  |   ALU_Out = (A < B) ? 1 : 0; |  SLT
-----------------------------------------------
|  0100  |   ALU_Out = (A < B) ? 1 : 0; |  SLTU
-----------------------------------------------
|  0101  |   ALU_Out = A ^ B;           |  XOR
-----------------------------------------------
|  0110  |   ALU_Out = A >> B;          |  SRL
-----------------------------------------------
|  0111  |   ALU_Out = A >>> B;         |  SRA
-----------------------------------------------
|  1000  |   ALU_Out = A | B;           |  OR
-----------------------------------------------
|  1001  |   ALU_Out = A & B;           |  AND
-----------------------------------------------
*/

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

//Local parameters for ALU decode from control logic
localparam ADD  = 4'b0000;
localparam SUB  = 4'b0001;
localparam SLL  = 4'b0010;
localparam SLT  = 4'b0011;
localparam SLTU = 4'b0100;
localparam XOR  = 4'b0101;
localparam SRL  = 4'b0110;
localparam SRA  = 4'b0111;
localparam OR   = 4'b1000;
localparam AND  = 4'b1001;
localparam MULT = 4'b1010;

// Local parameters for Multiplication decode
localparam MUL    = 3'b000;
localparam MULH   = 3'b001;
localparam MULHSU = 3'b010;
localparam MULHU  = 3'b011;
localparam DIV    = 3'b100;
localparam DIVU   = 3'b101;
localparam REM    = 3'b110;
localparam REMU   = 3'b111;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic [DWIDTH-1:0] mul_div_low;
logic [DWIDTH-1:0] mul_div_upper;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

/*
multiplier multiplier (
  .Mul_In_A     (ALU_In_A),
  .Mul_In_B     (ALU_In_B),
  .Mul_Sel      (MUL_OP),
  .Mul_Out_Upper(mul_div_upper),
  .Mul_Out_Lower(mul_div_low)
);
*/

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

always_comb begin
  casez(ALU_OP)
    ADD:  ALU_Out = ALU_In_A + ALU_In_B; //add
    SUB:  ALU_Out = ALU_In_A - ALU_In_B; //subtract
    SLL:  ALU_Out = ALU_In_A << ALU_In_B; //logical left shift
    SLT:  ALU_Out = ($signed(ALU_In_A) < $signed(ALU_In_B)) ? 1 : '0; //signed less than
    SLTU: ALU_Out = (ALU_In_A < ALU_In_B) ? 1 : '0; //Unsigned set on less then
    XOR:  ALU_Out = ALU_In_A ^ ALU_In_B; //xor
    SRL:  ALU_Out = ALU_In_A >> ALU_In_B; //shift logic right
    SRA:  ALU_Out = $signed(ALU_In_A) >>> ALU_In_B; //signed shift logic right
    OR:   ALU_Out = ALU_In_A | ALU_In_B; //or
    AND:  ALU_Out = ALU_In_A & ALU_In_B; //and
    MULT: ALU_Out = ALU_In_A * ALU_In_B;
    /*
    begin
      casez(MUL_OP)
        MUL:    ALU_Out = mul_div_low;
        MULH:   ALU_Out = mul_div_upper;
        MULHSU: ALU_Out = mul_div_upper;
        MULHU:  ALU_Out = mul_div_upper;
        DIV:    ALU_Out = mul_div_low;
        DIVU:   ALU_Out = mul_div_low;
        REM:    ALU_Out = mul_div_low;
        REMU:   ALU_Out = mul_div_low;
      endcase
    end
    */
    default: begin
      ALU_Out = ALU_In_A + ALU_In_B; //default add
    end
  endcase
end

assign ALU_Zero_Flag = (ALU_Out == '0) ? '1 : '0; //set on zero

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
alu #(
  .DWIDTH(32)
)
alu
(
  .ALU_In_A(),
  .ALU_In_B(),
  .ALU_OP(),
  .MUL_OP(),
  .ALU_Out(),
  .ALU_Zero_Flag()
);
*/

endmodule