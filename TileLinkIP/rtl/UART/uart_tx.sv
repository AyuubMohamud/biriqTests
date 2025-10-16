module uart_tx (
    input  wire        clock,
    input  wire        resetn,
    input  wire [15:0] bauddiv_i,     // set as BAUDDIV_q+1
    input  wire        tx_i,
    input  wire [ 7:0] tx_byte_i,
    output wire        tx_dequeue_o,
    output wire        tx_o,
    output wire        tx_busy_o
);
  reg start_q, byte_q, stop_q, cmpl_q, tx_q;
  reg [15:0] counter_q;
  reg [7:0] tx_byte_q;
  reg [2:0] byte_cnt_q;
  wire zero;

  initial begin
    start_q    = 1'b0;
    byte_q     = 1'b0;
    stop_q     = 1'b0;
    cmpl_q     = 1'b0;
    tx_q       = 1'b1;
    counter_q  = 16'd0;
    tx_byte_q  = 8'd0;
    byte_cnt_q = 3'd0;
  end

  assign zero = counter_q == 16'd0;
  assign tx_o = tx_q;
  assign tx_dequeue_o = cmpl_q;
  assign tx_busy_o = start_q | byte_q | stop_q | cmpl_q;

  always_ff @(posedge clock)
    if (!resetn || !(start_q || byte_q || stop_q) || zero || cmpl_q) counter_q <= bauddiv_i;
    else counter_q <= counter_q - 1'b1;

  always_ff @(posedge clock)
    if (!resetn || !(start_q | stop_q | byte_q | cmpl_q)) tx_q <= 1'b1;
    else if (cmpl_q) tx_q <= 1'b1;
    else if (stop_q) tx_q <= 1'b1;
    else if (byte_q) tx_q <= tx_byte_q[0];
    else if (start_q) tx_q <= 1'b0;

  always_ff @(posedge clock)
    if (!resetn || cmpl_q) start_q <= 1'b0;
    else if (!start_q) start_q <= tx_i;

  always_ff @(posedge clock)
    if (!resetn || cmpl_q) byte_q <= 1'b0;
    else if (!byte_q) byte_q <= start_q && zero;

  always_ff @(posedge clock)
    if (!resetn || cmpl_q) stop_q <= 1'b0;
    else if (!stop_q) stop_q <= byte_q && zero && (byte_cnt_q == 3'd7);

  always_ff @(posedge clock)
    if (!resetn || cmpl_q) byte_cnt_q <= 3'd0;
    else if (byte_q && zero) byte_cnt_q <= byte_cnt_q + 3'd1;

  always_ff @(posedge clock)
    if (!resetn || tx_i) tx_byte_q <= tx_byte_i;
    else if (byte_q && zero) tx_byte_q <= {1'b0, tx_byte_q[7:1]};

  always_ff @(posedge clock)
    if (!resetn || cmpl_q) cmpl_q <= 1'b0;
    else if (!cmpl_q) cmpl_q <= stop_q && zero;

endmodule
