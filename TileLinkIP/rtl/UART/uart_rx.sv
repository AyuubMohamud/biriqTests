module uart_rx (
    input  wire        clock,
    input  wire        resetn,
    input  wire [15:0] bauddiv_i,  // set as BAUDDIV_q+1
    input  wire        rx_i,
    output wire [ 7:0] rx_byte_o,
    output wire        rx_o,
    output wire        rx_busy_o
);
  (* ASYNC_REG = "TRUE" *) reg rx_q, rx_qq;
  reg sample_q, start_q, stop_q, hbit_q, cmpl_q;
  reg [15:0] counter_q;
  reg [ 7:0] rx_byte_q;
  reg [ 2:0] byte_cnt_q;
  wire rx, zero, sample_en, shift_en, last_shift;

  initial begin
    rx_q = 1'b1;
    rx_qq = 1'b1;
    rx_byte_q = 8'd0;
    sample_q = 1'b0;
    start_q = 1'b0;
    byte_cnt_q = 3'd0;
    counter_q = 16'd0;
    cmpl_q = 1'b0;
  end

  assign rx = !rx_qq;
  assign zero = counter_q == '0;
  assign sample_en = counter_q == {1'b0, bauddiv_i[15:1]};
  assign shift_en = zero && sample_q && start_q && !stop_q;
  assign last_shift = byte_cnt_q == 3'd7 && shift_en;
  assign rx_o = cmpl_q;
  assign rx_byte_o = rx_byte_q;
  assign rx_busy_o = sample_q | start_q | stop_q | hbit_q | cmpl_q;

  always_ff @(posedge clock)
    if (!resetn) rx_q <= 1'b1;
    else rx_q <= rx_i;

  always_ff @(posedge clock)
    if (!resetn) rx_qq <= 1'b1;
    else rx_qq <= rx_q;

  always_ff @(posedge clock)
    if ((!rx & !(sample_q | start_q)) || zero || !resetn || (sample_en & sample_q & rx & !start_q) || rx_o)
      counter_q <= bauddiv_i;
    else counter_q <= counter_q - 1'b1;


  // Check for start bit
  always_ff @(posedge clock)
    if (rx_o || !resetn) sample_q <= 1'b0;
    else if (!sample_q) sample_q <= rx;

  // Now check it's still low
  always_ff @(posedge clock)
    if (rx_o || !resetn) start_q <= 1'b0;
    else if (!start_q) start_q <= sample_en & sample_q & rx;

  // Byte recieval block

  always_ff @(posedge clock)
    if (rx_o || !resetn) rx_byte_q <= 8'd0;
    else if (shift_en) rx_byte_q <= {rx_qq, rx_byte_q[7:1]};

  always_ff @(posedge clock)
    if (rx_o || !resetn) byte_cnt_q <= 3'd0;
    else if (shift_en) byte_cnt_q <= byte_cnt_q + 1'b1;

  always_ff @(posedge clock)
    if (rx_o || !resetn) stop_q <= 1'b0;
    else if (!stop_q) stop_q <= last_shift;

  always_ff @(posedge clock)
    if (rx_o || !resetn) hbit_q <= 1'b0;
    else if (stop_q && (counter_q == '0)) hbit_q <= 1'b1;

  always_ff @(posedge clock)
    if (rx_o || !resetn) cmpl_q <= 1'b0;
    else if (hbit_q && (counter_q == {1'b0, bauddiv_i[15:1]})) cmpl_q <= 1'b1;
endmodule
