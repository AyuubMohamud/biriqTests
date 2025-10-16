// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module uart_tx (
    input wire logic i_clk,
    input wire logic i_start_transmission,
    input wire logic [11:0] CLKTOBAUDRATE,
    output logic o_uart_tx,
    input wire logic [7:0] i_uart_tx_byte,
    output wire logic o_tx_busy
);
  localparam IDLE = 3'b000;
  localparam HNDL_START_BIT = 3'b001;
  localparam HNDL_DATA_BITS = 3'b010;
  localparam HNDL_STOP_BIT = 3'b011;

  reg [2:0] state_machine_stage;
  initial state_machine_stage = IDLE;
  reg [ 7:0] tx_byte = 0;
  reg [11:0] counter = 0;

  reg [ 2:0] bit_index = 0;
  initial o_uart_tx = 0;
  // TRANSMISSION VERIFIED :)
  always_ff @(posedge i_clk) begin
    case (state_machine_stage)
      IDLE: begin
        o_uart_tx <= 1;
        counter   <= 0;
        if (i_start_transmission) begin
          state_machine_stage <= HNDL_START_BIT;
          tx_byte <= i_uart_tx_byte;
        end else begin
          state_machine_stage <= IDLE;
        end
      end
      HNDL_START_BIT: begin
        o_uart_tx <= 0;
        if (counter < CLKTOBAUDRATE - 1) begin
          counter <= counter + 1;
          state_machine_stage <= HNDL_START_BIT;
        end else begin
          counter <= 0;
          state_machine_stage <= HNDL_DATA_BITS;
          bit_index <= 0;
        end
      end
      HNDL_DATA_BITS: begin
        o_uart_tx <= tx_byte[bit_index];
        if (counter < CLKTOBAUDRATE - 1) begin
          counter <= counter + 1;
          state_machine_stage <= HNDL_DATA_BITS;
        end else begin
          counter <= 0;
          if (bit_index == 7) begin
            bit_index <= 0;
            state_machine_stage <= HNDL_STOP_BIT;
          end else begin
            bit_index <= bit_index + 1;
            state_machine_stage <= HNDL_DATA_BITS;
          end
        end
      end
      HNDL_STOP_BIT: begin
        o_uart_tx <= 1;
        if (counter < CLKTOBAUDRATE - 1) begin
          counter <= counter + 1;
          state_machine_stage <= HNDL_STOP_BIT;
        end else begin
          counter <= 0;
          state_machine_stage <= IDLE;

        end
      end
      default: state_machine_stage <= IDLE;
    endcase
  end
  assign o_tx_busy = state_machine_stage != IDLE;

endmodule : uart_tx
