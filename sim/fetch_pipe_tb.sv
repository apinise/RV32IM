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

integer       fvectors, r;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

fetch_pipe fetch #(
  .DWIDTH(32),
  .MEM_SIZE(1024)
)(
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
  fvectors = $fopen("../refV/fetch_pipe.txt", "r");
  if (fvectors == 0) begin
     $display("Could not open ../refV/fetch_pipe.txt");
     $finish;
  end
  
  clk     <= '0;
  rst_n   <= '1;
  pc_sel  <= '0;
  flush   <= '0;
  stall   <= '0;
  pc_imm  <= '0;
  
  @(posedge clk);
  @(posedge clk);
  
  rst_n   <= '0;
  
  @(posedge clk);
  @(posedge clk);
  
  rst_n   <= '1;
  
	while (!$feof(fvectors)) begin
     
  end
  
	$fclose(fvectors);
  
end

always begin 
	#5 clk <= ~clk;
end

endmodule