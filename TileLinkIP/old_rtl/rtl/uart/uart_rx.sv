// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module uart_rx (
    input wire logic i_clk,
    input wire logic i_rx,
    input wire logic [11:0] CLKTOBAUDRATE,
    output wire logic o_rx,
    output wire logic [7:0] o_byte_recieved
);
  localparam IDLE = 2'b00;
  localparam ISSTARTBIT = 2'b01;
  localparam RECIEVING = 2'b10;
  localparam BYTERECIEVED = 2'b11;
  reg [1:0] state;
  reg [7:0] byte_recieved;
  reg [11:0] counter;
  reg [2:0] index;
  reg o_sig_byte_recieved;
  reg x;
  reg y;
  initial state = 2'b00;
  initial index = 0;
  initial x = 0;
  initial y = 0;
  assign o_byte_recieved = byte_recieved;
  assign o_rx = o_sig_byte_recieved;
  wire [11:0] half_of_rate;
  assign half_of_rate = {1'b0, CLKTOBAUDRATE[11:1]};
  wire [11:0] sample_point_0;
  assign sample_point_0 = CLKTOBAUDRATE - 1;
  wire [11:0] sample_point;
  assign sample_point = {1'b0, sample_point_0[11:1]};

  always_ff @(posedge i_clk) begin
    x <= i_rx;
    y <= x;
  end

  always_ff @(posedge i_clk) begin
    case (state)
      IDLE: begin
        if (!y) begin
          state <= ISSTARTBIT;
        end else begin
          state <= IDLE;
        end
        counter <= 12'b000000000000;
        index <= 0;
        byte_recieved <= 0;
        o_sig_byte_recieved <= 0;
      end
      ISSTARTBIT: begin
        if (counter == sample_point) begin
          if (!y) begin
            counter <= 0;
            state   <= RECIEVING;
          end else begin
            state <= IDLE;
          end
        end else begin
          counter <= counter + 1;
          state   <= ISSTARTBIT;
        end
      end
      RECIEVING: begin
        if (counter == CLKTOBAUDRATE - 1) begin
          byte_recieved[index] <= y;
          if (index < 7) begin
            index   <= index + 1;
            state   <= RECIEVING;
            counter <= 0;
          end else begin
            state   <= BYTERECIEVED;
            counter <= 0;
          end
        end else begin
          counter <= counter + 1;
          state   <= RECIEVING;
        end
      end
      BYTERECIEVED: begin
        if (counter == (((half_of_rate + CLKTOBAUDRATE) - 1))) begin
          o_sig_byte_recieved <= 1;
          state <= IDLE;
          counter <= 0;
        end else begin
          counter <= counter + 1;
          state   <= BYTERECIEVED;
        end
      end
      default: begin
        state <= IDLE;
      end
    endcase
  end


endmodule : uart_rx
