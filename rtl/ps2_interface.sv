module ps2_interface #(
  parameter TIMEOUT = 16'd8192
)(
  input   logic       clk_core,
  input   logic       rst_core_n,
  input   logic       ps2_clk,
  input   logic       ps2_data,
  output  logic [7:0] data_out,
  output  logic       data_valid,
  output  logic       data_error
);

////////////////////////////////////////////////////////////////
////////////////////////   Parameters   ////////////////////////
////////////////////////////////////////////////////////////////

localparam  S_READY = 2'b00,
            S_RECEIVING = 2'b01,
            S_STOP      = 2'b10;

////////////////////////////////////////////////////////////////
///////////////////////   Internal Net   ///////////////////////
////////////////////////////////////////////////////////////////

// State machine nets
logic [1:0] state_c;
logic [1:0] state_r;

// PS2 clock edge detection
logic ps2_clk_r;
logic ps2_clk_negedge;

// PS2 data nets
logic       ps2_data_r;
logic [8:0] data_shift_r;
logic       data_parity;
logic [3:0] bit_cnt;

// Timeout nets
logic [15:0]  timeout_cnt;
logic         timeout_flag;

////////////////////////////////////////////////////////////////
//////////////////////   Instantiations   //////////////////////
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
///////////////////////   Module Logic   ///////////////////////
////////////////////////////////////////////////////////////////

// Register clock edge
always_ff @(posedge clk_core or negedge rst_core_n) begin
  if (~rst_core_n) begin
    ps2_clk_r <= '0;
  end
  else begin
    ps2_clk_r <= ps2_clk;
  end
end

assign ps2_clk_negedge = (ps2_clk_r && ~ps2_clk) ? 1'b1 : 1'b0;

// Shift input data
always_ff @(posedge clk_core or negedge rst_core_n) begin
  if (~rst_core_n) begin
    data_shift_r  <= '0;
    ps2_data_r    <= '0;
  end
  else begin
    ps2_data_r  <= ps2_data;
    
    if ((state_r == S_RECEIVING) && (ps2_clk_negedge ==  1'b1)) begin
      data_shift_r  <= {ps2_data_r, data_shift_r[8:1]};
    end
    else begin
      data_shift_r  <= data_shift_r;
    end
  end
end

// Count recieved bits
always_ff @(posedge clk_core or negedge rst_core_n) begin
  if (~rst_core_n) begin
    bit_cnt <= '0;
  end
  else begin
    if (state_r == S_READY) begin
      bit_cnt <= '0;
    end
    else if ((state_r == S_RECEIVING) && (ps2_clk_negedge == 1'b1)) begin
      bit_cnt <= bit_cnt + 4'd1;
    end
    else begin
      bit_cnt <= bit_cnt;
    end
  end
end

// Determine if timeout
always_ff @(posedge clk_core or negedge rst_core_n) begin
  if (~rst_core_n) begin
    timeout_cnt <= '0;
  end
  else begin
    if (state_r == S_READY) begin
      timeout_cnt <= '0;
    end
    else if (ps2_clk_negedge == 1'b1) begin
      timeout_cnt <= '0;
    end
    else if (timeout_flag == 1'b0) begin
      timeout_cnt <= timeout_cnt + 16'd1;
    end
    else begin
      timeout_cnt <= timeout_cnt;
    end
  end
end

assign timeout_flag = (timeout_cnt >= TIMEOUT) ? 1'b1 : 1'b0;

// Generate parity bit to validate packet
assign parity = ~(data_shift_r[0] +
                  data_shift_r[1] +
                  data_shift_r[2] +
                  data_shift_r[3] +
                  data_shift_r[4] +
                  data_shift_r[5] +
                  data_shift_r[6] +
                  data_shift_r[7]);

// Valid and Error logic
always_ff @(posedge clk_core or negedge rst_core_n) begin
  if (~rst_core_n) begin
    data_valid  <= '0;
    data_error  <= '0;
  end
  else begin
    if (timeout_flag == 1'b1) begin
      data_valid  <= 1'b0;
      data_error  <= 1'b1;
    end
    else if (state_r == S_STOP) begin
      if (ps2_clk_negedge == 1'b1) begin
        if ((ps2_data_r == 1'b1) && (data_shift_r[8] == parity)) begin
          data_valid  <= 1'b1;
          data_error  <= 1'b0;
        end
        else begin
          data_valid  <= 1'b0;
          data_error  <= 1'b1;
        end
      end
      else begin
        data_valid  <= 1'b0;
        data_error  <= 1'b0;
      end
    end
    else begin
      data_valid  <= 1'b0;
      data_error  <= 1'b0;
    end
  end
end

// State machine
always_ff @(posedge clk_core or negedge rst_core_n) begin
  if (~rst_core_n) begin
    state_r <= S_READY;
  end
  else begin
    state_r <= state_c;
  end
end

always_comb begin
  state_c = state_r;
  
  if (timeout_flag == 1'b1) begin
    state_c = S_READY;
  end
  else begin
    casez(state_r)
      S_READY: begin
        if ((ps2_clk_negedge == 1'b1) && (ps2_data_r == 1'b0)) begin
          state_c = S_RECEIVING;
        end
        else begin
          state_c = S_READY;
        end
      end
      S_RECEIVING: begin
        if (bit_cnt >= 4'd9) begin
          state_c = S_STOP;
        end
        else begin
          state_c = S_RECEIVING;
        end
      end
      S_STOP: begin
        if (ps2_clk_negedge == 1'b1) begin
          state_c = S_READY;
        end
        else begin
          state_c = S_STOP;
        end
      end
    endcase
  end
end

// Output register logic
always_ff @(posedge clk_core or negedge rst_core_n) begin
  if (~rst_core_n) begin
    data_out  <= '0;
  end
  else begin
    if ((state_r == S_STOP) && (ps2_clk_negedge == 1'b1)) begin
      data_out  <= data_shift_r[7:0];
    end
    else begin
      data_out  <= data_out;
    end
  end
end

////////////////////////////////////////////////////////////////
//////////////////   Instantiation Template   //////////////////
////////////////////////////////////////////////////////////////
/*
ps2_interface #(
  .TIMEOUT(16'd8192)
)
ps2_reciever (
  .clk_core(),
  .rst_core_n(),
  .ps2_clk(),
  .ps2_data(),
  .data_out(),
  .data_valid(),
  .data_error()
);
*/
endmodule