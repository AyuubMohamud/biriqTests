`default_nettype none
module TL_UART #(
    parameter [15:0] C_DEFAULT_BAUD_RATE = 16'd868,
    parameter C_DEFAULT_TX_ON = 1,
    parameter C_DEFAULT_RX_ON = 1,
    parameter C_TILELINK_ID_WIDTH = 1
) (
    input  wire                           uart_clock_i,
    input  wire                           uart_reset_i,
    // Slave interface
    input  wire [                    2:0] uart_a_opcode,
    input  wire [                    2:0] uart_a_param,
    input  wire [                    2:0] uart_a_size,
    input  wire [C_TILELINK_ID_WIDTH-1:0] uart_a_source,
    input  wire [                   11:0] uart_a_address,
    input  wire [                    3:0] uart_a_mask,
    input  wire [                   31:0] uart_a_data,
    input  wire                           uart_a_corrupt,
    input  wire                           uart_a_valid,
    output wire                           uart_a_ready,
    output wire [                    2:0] uart_d_opcode,
    output wire [                    1:0] uart_d_param,
    output wire [                    2:0] uart_d_size,
    output wire [C_TILELINK_ID_WIDTH-1:0] uart_d_source,
    output wire                           uart_d_denied,
    output wire [                   31:0] uart_d_data,
    output wire                           uart_d_corrupt,
    output wire                           uart_d_valid,
    input  wire                           uart_d_ready,
    input  wire                           UART_RX,
    output wire                           UART_TX,
    output wire                           UART_RX_IRQ,
    output wire                           UART_TX_IRQ
);
  localparam AW = 12;
  localparam IW = C_TILELINK_ID_WIDTH;
  wire          a_ready;
  wire          a_valid;
  wire [   2:0] a_opcode;
  // verilator lint_off UNUSED
  wire [   2:0] a_param;
  // verilator lint_on UNUSED
  wire [   2:0] a_size;
  wire [IW-1:0] a_source;
  wire [  11:0] a_address;
  wire [   3:0] a_mask;
  wire [  31:0] a_data;
  wire          a_corrupt;
  wire          d_ready;
  reg  [   2:0] d_opcode_q;
  reg  [   1:0] d_param_q;
  reg  [   2:0] d_size_q;
  reg  [IW-1:0] d_source_q;
  reg           d_denied_q;
  reg  [  15:0] d_data_q;
  reg           d_corrupt_q;
  reg           d_valid_q;

  initial begin
    d_opcode_q  = '0;
    d_param_q   = '0;
    d_size_q    = 3'd0;
    d_source_q  = '0;
    d_denied_q  = 1'b0;
    d_data_q    = '0;
    d_corrupt_q = 1'b0;
    d_valid_q   = 1'b0;
  end

  `include "TL.svh"
  assign d_ready = uart_d_ready;
  assign a_ready = d_ready;
  assign uart_d_opcode = d_opcode_q;
  assign uart_d_param = d_param_q;
  assign uart_d_size = d_size_q;
  assign uart_d_source = d_source_q;
  assign uart_d_denied = d_denied_q;
  assign uart_d_data = {16'd0, d_data_q};
  assign uart_d_corrupt = d_corrupt_q;
  assign uart_d_valid = d_valid_q;
  skdbf #(
      .DW  (58 + IW),
      .SYNC(0)
  ) skdbf_inst (
      .clk_i(uart_clock_i),
      .rst_i(uart_reset_i),
      .combinational_ready_i(a_ready),
      .cycle_data_o({a_opcode, a_param, a_size, a_source, a_address, a_mask, a_data, a_corrupt}),
      .cycle_vld_o(a_valid),
      .registered_ready_o(uart_a_ready),
      .registered_data_i({
        uart_a_opcode,
        uart_a_param,
        uart_a_size,
        uart_a_source,
        uart_a_address,
        uart_a_mask,
        uart_a_data,
        uart_a_corrupt
      }),
      .registered_vld_i(uart_a_valid)
  );

  localparam [11:0] REG_UART_CTRL = 12'h000; // (FIFO watermarks, enable transmission, enable recieval etc.)
  localparam [11:0] REG_UART_STATUS = 12'h004;  // UART Status (Full, Empty, Interrupts)
  localparam [11:0] REG_UART_FIFOAX = 12'h008;  // FIFO Read/Write
  localparam [11:0] REG_UART_BAUDDIV = 12'h00C;  // 16-bit baud rate divisor

  /**
    UARTCTRL (R/W): Bit 0 -> Enable Receival
              Bit 1 -> Enable Transmission
              Bit 6:2 -> FIFO RX Watermark
              Bit 11:7 -> FIFO TX Watermark
              Bit 12 -> Enable FIFO RX Watermark Interrupt
              Bit 13 -> Enable FIFO TX Watermark Interrupt
              
    UARTSTATS (R/W): Bit 0 -> RX FIFO Full
                Bit 1 -> RX FIFO Empty
                Bit 2 -> RX FIFO Interrupt Pending
                Bit 3 -> RX Recieving
                Bit 4 -> TX FIFO Full
                Bit 5 -> TX FIFO Empty
                Bit 6 -> TX FIFO Interrupt Pending
                Bit 7 -> TX Transmitting
    
    FIFOAX (R/W): Bit 7:0 -> Data to transmit (if write), Data to read (if read)
    
    BAUDDIV (R/W): Bit 15:0 -> Baud rate divisor 
  **/
  logic [15:0] UARTCTRL_q, UARTSTATS_q, FIFOAX_q, BAUDDIV_q, DATA_r;
  wire tx_dequeue, rx_enqueue, tx_full, tx_empty, rx_full, rx_empty, tx_underflow, tx_overflow, rx_underflow, rx_overflow, rx_threshold, tx_threshold, rx_busy, tx_busy;
  wire [7:0] rx_char, tx_char;
  reg
      RX_q,
      TX_q,
      RX_WATERMARK_IRQ_q,
      TX_WATERMARK_IRQ_q,
      RX_WATERMARK_IRQEN_q,
      TX_WATERMARK_IRQEN_q;
  reg [4:0] RX_WATERMARK_q, TX_WATERMARK_q;

  assign UARTCTRL_q = {
    2'd0, TX_WATERMARK_IRQEN_q, RX_WATERMARK_IRQEN_q, TX_WATERMARK_q, RX_WATERMARK_q, TX_q, RX_q
  };
  assign FIFOAX_q[15:8] = 8'd0;
  assign UARTSTATS_q = {
    8'd0,
    tx_busy,
    TX_WATERMARK_IRQ_q,
    tx_empty,
    tx_full,
    rx_busy,
    RX_WATERMARK_IRQ_q,
    rx_empty,
    rx_full
  };

  assign UART_RX_IRQ = RX_WATERMARK_IRQ_q;
  assign UART_TX_IRQ = TX_WATERMARK_IRQ_q;

  logic [15:0] w_val;
  assign w_val = a_data[15:0];

  /* UARTCTRL_q logic */
  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) TX_q <= C_DEFAULT_TX_ON == 1 ? 1'b1 : 1'b0;
    else if (TL_isWriteTo(a_address, REG_UART_CTRL)) TX_q <= w_val[0];

  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) RX_q <= C_DEFAULT_RX_ON == 1 ? 1'b1 : 1'b0;
    else if (TL_isWriteTo(a_address, REG_UART_CTRL)) RX_q <= w_val[1];

  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) RX_WATERMARK_q <= 5'd0;
    else if (TL_isWriteTo(a_address, REG_UART_CTRL)) RX_WATERMARK_q <= w_val[6:2];

  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) TX_WATERMARK_q <= 5'd0;
    else if (TL_isWriteTo(a_address, REG_UART_CTRL)) TX_WATERMARK_q <= w_val[11:7];

  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) RX_WATERMARK_IRQEN_q <= 1'b0;
    else if (TL_isWriteTo(a_address, REG_UART_CTRL)) RX_WATERMARK_IRQEN_q <= w_val[12];

  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) TX_WATERMARK_IRQEN_q <= 1'b0;
    else if (TL_isWriteTo(a_address, REG_UART_CTRL)) TX_WATERMARK_IRQEN_q <= w_val[13];

  /* UARTSTATS_q logic */
  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) RX_WATERMARK_IRQ_q <= 1'b0;
    else if (TL_isWriteTo(a_address, REG_UART_STATUS)) RX_WATERMARK_IRQ_q <= w_val[2];
    else if (RX_WATERMARK_IRQEN_q & rx_threshold & !RX_WATERMARK_IRQ_q) RX_WATERMARK_IRQ_q <= 1'b1;
    else if (!RX_WATERMARK_IRQEN_q) RX_WATERMARK_IRQ_q <= 1'b0;

  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) TX_WATERMARK_IRQ_q <= 1'b0;
    else if (TL_isWriteTo(a_address, REG_UART_STATUS)) TX_WATERMARK_IRQ_q <= w_val[6];
    else if (TX_WATERMARK_IRQEN_q & tx_threshold) TX_WATERMARK_IRQ_q <= 1'b1;
    else if (!TX_WATERMARK_IRQEN_q) TX_WATERMARK_IRQ_q <= 1'b0;

  /* BAUDDIV_q logic */
  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) BAUDDIV_q <= C_DEFAULT_BAUD_RATE;
    else if (TL_isWriteTo(a_address, REG_UART_BAUDDIV)) BAUDDIV_q <= w_val[15:0];

  /* Read Logic */
  always_comb
    if (TL_isReadTo(a_address, REG_UART_CTRL)) DATA_r = UARTCTRL_q;
    else if (TL_isReadTo(a_address, REG_UART_STATUS)) DATA_r = UARTSTATS_q;
    else if (TL_isReadTo(a_address, REG_UART_FIFOAX)) DATA_r = FIFOAX_q;
    else if (TL_isReadTo(a_address, REG_UART_BAUDDIV)) DATA_r = BAUDDIV_q;
    else DATA_r = 'x;


  always_ff @(posedge uart_clock_i)
    if (uart_reset_i) begin
      d_valid_q <= 1'b0;
    end else if (a_valid && (d_ready || !d_valid_q)) begin
      d_valid_q <= 1'b1;
      d_opcode_q <= TL_RetCode();
      d_param_q <= '0;
      d_size_q <= a_size;
      d_source_q <= a_source;
      d_denied_q <= 1'b0;
      d_data_q <= DATA_r;
      d_corrupt_q <= 1'b0;
    end else if (d_ready) begin
      d_valid_q <= 1'b0;
    end

  fifo_sync #(
      .FW(32),
      .DW(8),
      .MD(1),
      .SYNC_RD(0)
  ) rx_fifo_inst (
      .clk_i(uart_clock_i),
      .reset_i(uart_reset_i),
      .wr_en_i(UARTCTRL_q[0] & rx_enqueue),
      .wr_data_i(rx_char),
      .full_o(rx_full),
      .rd_i(TL_isReadTo(a_address, REG_UART_FIFOAX)),
      .rd_data_o(FIFOAX_q[7:0]),
      .empty_o(rx_empty),
      .underflow_o(rx_underflow),
      .overflow_o(rx_overflow),
      .threshold_i(UARTCTRL_q[6:2]),
      .threshold_o(rx_threshold)
  );

  fifo_sync #(
      .FW(32),
      .DW(8),
      .MD(1),
      .SYNC_RD(0)
  ) tx_fifo_inst (
      .clk_i(uart_clock_i),
      .reset_i(uart_reset_i),
      .wr_en_i(TL_isWriteTo(a_address, REG_UART_FIFOAX)),
      .wr_data_i(a_data[7:0]),
      .full_o(tx_full),
      .rd_i(tx_dequeue),
      .rd_data_o(tx_char),
      .empty_o(tx_empty),
      .underflow_o(tx_underflow),
      .overflow_o(tx_overflow),
      .threshold_i(UARTCTRL_q[11:7]),
      .threshold_o(tx_threshold)
  );

  uart_rx uart_reciever (
      .clock(uart_clock_i),
      .resetn(uart_reset_i),
      .bauddiv_i(BAUDDIV_q),
      .rx_i(UART_RX),
      .rx_byte_o(rx_char),
      .rx_o(rx_enqueue),
      .rx_busy_o(rx_busy)
  );

  uart_tx uart_trasmitter (
      .clock(uart_clock_i),
      .resetn(uart_reset_i),
      .bauddiv_i(BAUDDIV_q),
      .tx_i(UARTCTRL_q[1] & !tx_empty),
      .tx_byte_i(tx_char),
      .tx_dequeue_o(tx_dequeue),
      .tx_o(UART_TX),
      .tx_busy_o(tx_busy)
  );


  // verilator lint_off UNUSED
  wire unused;
  assign unused = (|a_data[31:16]) | tx_underflow | rx_underflow | tx_overflow | rx_overflow | (|a_mask) | a_corrupt;
  // verilator lint_on UNUSED
endmodule
