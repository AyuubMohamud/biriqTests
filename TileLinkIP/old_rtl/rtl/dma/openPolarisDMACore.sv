// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module openPolarisDMACore (
    input wire logic dmac_clock_i,

    input  wire logic        dmac_tx_i,
    input  wire logic [31:0] dmac_source_address_i,
    input  wire logic [31:0] dmac_dest_address_i,
    input  wire logic [31:0] dmac_bytes_tx_i,
    input  wire logic [ 1:0] dmac_max_size_i,
    input  wire logic        dmac_source_stationary_i,
    input  wire logic        dmac_dest_stationary_i,
    output wire logic        dmac_busy_o,
    output logic             dmac_done_o,
    output logic             dmac_err_o,

    output logic      [ 2:0] dma_a_opcode,
    output logic      [ 2:0] dma_a_param,
    output logic      [ 3:0] dma_a_size,
    output logic      [31:0] dma_a_address,
    output logic      [ 3:0] dma_a_mask,
    output logic      [31:0] dma_a_data,
    output logic             dma_a_corrupt,
    output logic             dma_a_valid,
    input  wire logic        dma_a_ready,
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire logic [ 2:0] dma_d_opcode,
    input  wire logic [ 1:0] dma_d_param,
    input  wire logic [ 3:0] dma_d_size,
    /* verilator lint_on UNUSEDSIGNAL */
    input  wire logic        dma_d_denied,
    input  wire logic [31:0] dma_d_data,
    input  wire logic        dma_d_corrupt,
    input  wire logic        dma_d_valid,
    output wire logic        dma_d_ready
);
  assign dma_d_ready = 1;
  reg [31:0] bytesRemaining = 0;
  reg [31:0] nxtSource = 0;
  reg [31:0] nxtDest = 0;

  localparam dma_idle = 2'd0;
  localparam dma_read = 2'd1;
  localparam dma_write = 2'd2;
  localparam dma_await = 2'd3;
  reg [1:0] dma_state = dma_idle;

  wire max_is_1 = nxtDest[0] | nxtSource[0] | bytesRemaining[0] | (dmac_max_size_i == 2'd0);
  wire max_is_2 = nxtDest[1] | nxtSource[1] | bytesRemaining[1] | (dmac_max_size_i == 2'd1);
  assign dmac_busy_o = dma_state != dma_idle;
  always_ff @(posedge dmac_clock_i) begin
    case (dma_state)
      dma_idle: begin
        if (dmac_tx_i) begin
          bytesRemaining <= dmac_bytes_tx_i;
          nxtSource <= dmac_source_address_i;
          nxtDest <= dmac_dest_address_i;
          dma_state <= dma_read;
        end else begin
          dmac_done_o <= 0;
          dmac_err_o  <= 0;
        end
      end
      dma_read: begin
        dma_a_address <= nxtSource;
        dma_a_corrupt <= 0;
        dma_a_param <= 0;
        dma_a_opcode <= 3'd4;
        dma_a_mask <= 0;
        dma_a_size <= max_is_1 ? 4'd0 : max_is_2 ? 4'd1 : 4'd2;
        dma_a_valid <= 1;
        dma_state <= dma_write;
      end
      dma_write: begin
        dma_a_valid <= dma_a_ready ? 1'b0 : dma_a_valid;
        if (dma_d_valid) begin
          if (dma_d_denied | dma_d_corrupt) begin
            dmac_err_o  <= 1;
            dmac_done_o <= 1;
            dma_state   <= dma_idle;
          end else begin
            dma_a_data <= dma_d_data;
            dma_a_address <= nxtDest;
            dma_a_corrupt <= 0;
            dma_a_param <= 0;
            dma_a_opcode <= 3'd0;
            dma_a_mask <= 4'hF;
            dma_a_size <= max_is_1 ? 4'd0 : max_is_2 ? 4'd1 : 4'd2;
            dma_a_valid <= 1;
            nxtSource <= dmac_source_stationary_i ? nxtSource : nxtSource + (max_is_1 ? 32'd1 : max_is_2 ? 32'd2 : 32'd4);
            nxtDest <= dmac_dest_stationary_i ? nxtDest : nxtDest + (max_is_1 ? 32'd1 : max_is_2 ? 32'd2 : 32'd4);
            bytesRemaining <= bytesRemaining - (max_is_1 ? 32'd1 : max_is_2 ? 32'd2 : 32'd4);
            dma_state <= dma_await;
          end
        end
      end
      dma_await: begin
        dma_a_valid <= dma_a_ready ? 1'b0 : dma_a_valid;
        if (dma_d_valid) begin
          if (dma_d_denied | dma_d_corrupt | (bytesRemaining == 0)) begin
            dmac_err_o  <= dma_d_denied | dma_d_corrupt;
            dmac_done_o <= 1;
            dma_state   <= dma_idle;
          end else begin
            dma_state <= dma_read;
          end
        end
      end
    endcase
  end
endmodule
