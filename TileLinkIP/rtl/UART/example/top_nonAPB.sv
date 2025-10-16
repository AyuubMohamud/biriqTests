module top (
    input  wire sys_clock_i,
    input  wire uart_rx,
    output wire uart_tx
);
  reg [7:0] rx_byte;
  reg rx;
  uart_rx uart_rx_inst (
      .clock(sys_clock_i),
      .resetn(1'b1),
      .bauddiv_i(16'd867),
      .rx_i(uart_rx),
      .rx_byte_o(rx_byte),
      .rx_o(rx)
  );
  wire tx_dequeue_o;
  uart_tx uart_tx_inst (
      .clock(sys_clock_i),
      .resetn(1'b1),
      .bauddiv_i(16'd867),
      .tx_i(rx),
      .tx_byte_i(rx_byte),
      .tx_dequeue_o(tx_dequeue_o),
      .tx_o(uart_tx)
  );
endmodule
