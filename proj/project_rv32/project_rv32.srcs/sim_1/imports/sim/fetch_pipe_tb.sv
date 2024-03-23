module fetch_pipe_tb (
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

logic clk;
logic rst_n;

logic pc_sel;
logic flush;
logic stall;

logic [31:0]  pc_imm;
logic [31:0]  pc_plus;
logic [31:0]  pc;
logic [31:0]  instruct;

logic [31:0]  chkInst;
logic [31:0]  chkPC;
logic [31:0]  chkPCplus;

logic instruct_pass;
logic pc_pass;
logic stall_pass;
logic flush_pass;
logic testbench_pass;

integer       fvectors, r;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

fetch_pipe #(
  .DWIDTH(32),
  .MEM_SIZE(1024)
)
dut (
  .Clk_Core(clk),
  .Rst_Core_N(rst_n),
  .pc_sel_fi(pc_sel),
  .flush_fi(flush),
  .stall_fi(stall),
  .pc_imm_fi(pc_imm),
  .pc_plus_fo(pc_plus),
  .pc_fo(pc),
  .instruct_fo(instruct)
);

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

initial begin
  // Open Test File
  /*
  fvectors = $fopen("../refV/fetch_pipe.txt", "r");
  if (fvectors == 0) begin
     $display("Could not open ../refV/fetch_pipe.txt");
     $finish;
  end
  */
  
  clk     <= '0;
  rst_n   <= '1;
  pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;
  
  chkInst   <= '0;
  chkPC     <= '0;
  chkPCplus <= '0;
  
  instruct_pass   <= '1;
  pc_pass         <= '1;
  stall_pass      <= '1;
  flush_pass      <= '1;
  testbench_pass  <= '1;
  
  @(posedge clk);
  @(posedge clk);
  
  rst_n   <= '0;
  
  @(posedge clk);
  @(posedge clk);
  
  rst_n   <= '1;
  
  /*
	while (!$feof(fvectors)) begin
    r = $fscanf(fvectors,"%d %d %d %h %h %h %h\n", pc_sel, stall, flush, pc_imm, chkInst, chkPC, chkPCplus);
    @(posedge clk);
  end
  
	$fclose(fvectors);
    */
    
  pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk);

  pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk);
  
    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk);
  
    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk);
  
    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk);
  
    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk);
  
    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk);
  
    pc_sel  <= '1;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= 32'h00000010;   
  @(posedge clk);
 
    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk);
  
    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '1;
  pc_imm  <= '0;   
  @(posedge clk);

    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '1;
  pc_imm  <= '0;   
  @(posedge clk);
  
      pc_sel  <= '0;
  flush   <= '0;
  stall   <= '1;
  pc_imm  <= '0;   
  @(posedge clk);
  
    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk); 
  
      pc_sel  <= '1;
  flush   <= '1;
  stall   <= '0;
  pc_imm  <= 32'h00000034;   
  @(posedge clk);
 
    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk); 

    pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;   
  @(posedge clk); 

  $finish;
end

always begin 
	#5 clk <= ~clk;
end

endmodule