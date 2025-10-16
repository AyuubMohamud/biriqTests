// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module polaris_uart_ip (
    input wire logic        uart_clk_i,
    input wire logic        uart_rst_i,
    input wire logic [11:0] clktobaudrate,
    input wire logic        tx_en,
    input wire logic        rx_en,

    input wire logic       tx_fifo_en_i,
    input wire logic [7:0] tx_fifo_en_data_i,

    input  wire logic       rx_fifo_de_i,
    output wire logic [7:0] rx_fifo_de_data_i,


    output wire logic tx_fifo_full,
    output wire logic tx_fifo_empty,
    output wire logic rx_fifo_full,
    output wire logic rx_fifo_empty,

    input  wire logic uart_rx_i,
    output wire logic uart_tx_o
);

  wire rx_vld;
  wire [7:0] rx_byte;

  wire rx_wr_en = rx_vld & rx_en;


  uart_rx rx0 (
      uart_clk_i,
      uart_rx_i,
      clktobaudrate,
      rx_vld,
      rx_byte
  );
  wire rx_underflow, rx_overflow;
  sfifo #(
      .FW(32),
      .DW(8)
  ) rx_fifo (
      uart_clk_i,
      uart_rst_i,
      rx_wr_en,
      rx_byte,
      rx_fifo_full,
      rx_fifo_de_i,
      rx_fifo_de_data_i,
      rx_fifo_empty,
      rx_underflow,
      rx_overflow
  );

  wire transmit;
  wire tx_busy;
  assign transmit = !tx_fifo_empty & !tx_busy & tx_en;
  wire [7:0] tx_byte;
  wire tx_underflow, tx_overflow;
  uart_tx tx0 (
      uart_clk_i,
      transmit,
      clktobaudrate,
      uart_tx_o,
      tx_byte,
      tx_busy
  );

  sfifo #(
      .FW(32),
      .DW(8)
  ) tx_fifo (
      uart_clk_i,
      uart_rst_i,
      tx_fifo_en_i,
      tx_fifo_en_data_i,
      tx_fifo_full,
      transmit,
      tx_byte,
      tx_fifo_empty,
      tx_underflow,
      tx_overflow
  );
endmodule
