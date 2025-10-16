// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module flashphy (
    input wire logic flash_clock_i,

    input  wire logic        flash_tx_i,
    input  wire logic [23:0] flash_addr_i,
    input  wire logic [ 3:0] flash_size_i,
    output wire logic        flash_busy_o,

    output logic        flash_enqueue,
    output logic [31:0] flash_data,

    output logic      flash_cs_n,
    output logic      flash_mosi,
    input  wire logic flash_miso,
    output logic      flash_sck
);
  reg [31:0] flash_cmd = 0;
  localparam flash_init = 2'b00;
  localparam flash_idle = 2'b01;
  localparam flash_tx = 2'b10;
  localparam flash_rx = 2'b11;
  reg [1:0] flash_fsm;
  initial flash_fsm = flash_init;
  reg   [ 3:0] flash_size = 0;
  reg   [11:0] cmd = 0;
  logic [11:0] bits;
  assign flash_busy_o = flash_fsm != flash_idle;
  always_comb begin
    case (flash_size)
      4'd0: begin
        bits = 7;
      end
      4'd1: begin
        bits = 15;
      end
      4'd2: begin
        bits = 31;
      end
      4'd3: begin
        bits = 63;
      end
      4'd4: begin
        bits = 127;
      end
      4'd5: begin
        bits = 255;
      end
      4'd6: begin
        bits = 511;
      end
      4'd7: begin
        bits = 1023;
      end
      4'd8: begin
        bits = 2047;
      end
      4'd9: begin
        bits = 4095;
      end
      default: begin
        bits = 7;
      end
    endcase
  end
  reg [30:0] flash_read_ff = 0;
  wire [31:0] flash_read_reg = {flash_read_ff[30:0], flash_miso};
  wire [15:0] hw_endian_switch = {flash_read_reg[7:0], flash_read_reg[15:8]};
  wire [31:0] word_endian_switch = {
    flash_read_reg[7:0], flash_read_reg[15:8], flash_read_reg[23:16], flash_read_reg[31:24]
  };
  always_ff @(posedge flash_clock_i) begin
    case (flash_fsm)
      flash_init: begin
        if (cmd == 12'hFFF) begin
          flash_fsm <= flash_idle;
        end
        cmd <= cmd + 1;
      end
      flash_idle: begin
        flash_enqueue <= 0;
        if (flash_tx_i) begin
          flash_cs_n <= 0;
          flash_cmd  <= {8'h03, flash_addr_i};
          flash_size <= flash_size_i;
          flash_fsm  <= flash_tx;
        end
        flash_sck  <= 0;
        flash_mosi <= 0;
      end
      flash_tx: begin
        flash_sck <= ~flash_sck;
        if (~flash_sck) begin
          {flash_mosi, flash_cmd} <= {flash_cmd, 1'b0};
          cmd <= cmd + 1;
        end else if (flash_sck && (cmd == 12'd32)) begin
          flash_fsm <= flash_rx;
          cmd <= bits;
        end
      end
      flash_rx: begin
        flash_sck <= ~flash_sck;
        if (flash_sck) begin
          {flash_read_ff} <= {flash_read_ff[29:0], flash_miso};
          if (cmd[4:0] == 0) begin
            flash_enqueue <= 1;
            flash_data <= flash_size==4'd0 ? {24'h0,flash_read_reg[7:0]} : flash_size == 4'd1 ? {16'h0,hw_endian_switch} : word_endian_switch;
          end
          if (cmd == 0) begin
            flash_cs_n <= 1;
            flash_fsm  <= flash_idle;
          end else begin
            cmd <= cmd - 1;
          end
        end else if (~flash_sck) begin
          flash_enqueue <= 0;
        end
      end
      default: begin

      end
    endcase
  end
endmodule
