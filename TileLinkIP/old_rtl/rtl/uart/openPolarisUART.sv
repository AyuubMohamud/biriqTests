// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
/**
    Configurable baud rate UART controller:
    Bit 0: Transmit not full interrupt
    Bit 1: Recieve not empty interrupt
    Bit 2: RX & TX enable
    Bit 14 to 3: Clock divider in terms of SYS_CLK/(BAUD_RATE)
**/
module openPolarisUART #(
    parameter TL_RS = 4,
    parameter TL_SZ = 4
) (
    input wire logic uart_clock_i,
    input wire logic uart_reset_i,

    // Slave interface
    input  wire logic [      2:0] uart_a_opcode,
    input  wire logic [      2:0] uart_a_param,
    input  wire logic [TL_SZ-1:0] uart_a_size,
    input  wire logic [TL_RS-1:0] uart_a_source,
    input  wire logic [      3:0] uart_a_address,
    input  wire logic [      3:0] uart_a_mask,
    input  wire logic [     31:0] uart_a_data,
    input  wire logic             uart_a_corrupt,
    input  wire logic             uart_a_valid,
    output wire logic             uart_a_ready,

    output logic      [      2:0] uart_d_opcode,
    output logic      [      1:0] uart_d_param,
    output logic      [TL_SZ-1:0] uart_d_size,
    output logic      [TL_RS-1:0] uart_d_source,
    output logic                  uart_d_denied,
    output logic      [     31:0] uart_d_data,
    output logic                  uart_d_corrupt,
    output logic                  uart_d_valid,
    input  wire logic             uart_d_ready,

    input  wire logic uart_rx_i,
    output wire logic uart_tx_o,

    output wire logic irq_o
);
  wire uart_busy;
  wire [TL_RS-1:0] working_source;
  wire [TL_SZ-1:0] working_size;
  wire [31:0] working_data;
  wire [3:0] working_mask;
  wire [2:0] working_opcode;
  wire [3:0] working_address;
  wire working_valid;
  skdbf #(TL_RS + TL_SZ + 43) skidbuffer (
      uart_clock_i,
      uart_reset_i,
      ~uart_d_ready,
      {working_source, working_size, working_data, working_mask, working_opcode, working_address},
      working_valid,
      uart_busy,
      {uart_a_source, uart_a_size, uart_a_data, uart_a_mask, uart_a_opcode, uart_a_address},
      uart_a_valid
  );
  assign uart_a_ready = ~uart_busy;

  reg [14:0] polarisUartCSR;
  initial polarisUartCSR = 0;
  localparam Get = 3'd4;
  localparam PutFullData = 3'd0;
  always_ff @(posedge uart_clock_i) begin
    if (uart_reset_i) begin
      polarisUartCSR <= 15'h0000;
    end else if (working_valid & uart_a_ready) begin
      if (working_opcode == PutFullData && working_address[3:2] == 2'b00) begin
        polarisUartCSR <= working_data[14:0];
      end
    end
  end
  logic read_fifo;
  logic [7:0] read_data;
  logic write_fifo;
  logic [7:0] write_data;
  wire txempty;
  wire rxempty;
  wire txfull;
  wire rxfull;
  polaris_uart_ip uart0 (
      uart_clock_i,
      uart_reset_i,
      polarisUartCSR[14:3],
      polarisUartCSR[2],
      polarisUartCSR[2],
      write_fifo,
      write_data,
      read_fifo,
      read_data,
      txfull,
      txempty,
      rxfull,
      rxempty,
      uart_rx_i,
      uart_tx_o
  );

  always_comb begin
    read_fifo = working_valid&uart_a_ready&&working_opcode==Get&&working_address[3:2]==2'b10;
    write_fifo = working_valid&uart_a_ready&&working_opcode==PutFullData&&working_address[3:2]==2'b01;
    write_data = working_data[7:0];
  end

  always_ff @(posedge uart_clock_i) begin
    if (uart_reset_i) begin
      uart_d_valid <= 1'b0;
    end else if (working_valid & uart_d_ready) begin
      case (working_address[3:2])
        2'b00: begin
          uart_d_data   <= {13'h0000, txempty, txfull, rxempty, rxfull, polarisUartCSR};
          uart_d_denied <= 1'b0;
          uart_d_opcode <= working_opcode == Get ? 3'd1 : 3'd0;
        end
        2'b01: begin
          uart_d_denied <= working_opcode != PutFullData;
          uart_d_data   <= 32'h00000000;
          uart_d_opcode <= 3'd0;
        end
        2'b10: begin
          uart_d_denied <= working_opcode != Get;
          uart_d_data   <= {24'h000000, read_data};
          uart_d_opcode <= 3'd1;
        end
      endcase
      uart_d_corrupt <= 1'b0;
      uart_d_param <= 2'b00;
      uart_d_size <= working_size;
      uart_d_source <= working_source;
      uart_d_valid <= 1'b1;
    end else if (!working_valid & uart_d_ready) begin
      uart_d_valid <= 1'b0;
    end
  end
  assign irq_o = (!rxempty & polarisUartCSR[1]) | (!txfull & polarisUartCSR[0]);
endmodule
