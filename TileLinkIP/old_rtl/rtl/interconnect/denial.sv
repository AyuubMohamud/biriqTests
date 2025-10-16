// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off WIDTHTRUNC */
/* verilator lint_off UNUSEDSIGNAL */
module denial #(
    parameter TL_RS = 1,
    parameter TL_AW = 32,
    TL_DW = 32
) (
    input wire logic denial_clock_i,
    input wire logic denial_reset_i,

    // Slave interface
    input  wire logic [            2:0] denial_a_opcode,
    input  wire logic [            2:0] denial_a_param,
    input  wire logic [            3:0] denial_a_size,
    input  wire logic [      TL_RS-1:0] denial_a_source,
    input  wire logic [      TL_AW-1:0] denial_a_address,
    input  wire logic [(TL_DW/8) - 1:0] denial_a_mask,
    input  wire logic [      TL_DW-1:0] denial_a_data,
    input  wire logic                   denial_a_corrupt,
    input  wire logic                   denial_a_valid,
    output wire logic                   denial_a_ready,

    output logic      [      2:0] denial_d_opcode,
    output logic      [      1:0] denial_d_param,
    output logic      [      3:0] denial_d_size,
    output logic      [TL_RS-1:0] denial_d_source,
    output logic                  denial_d_denied,
    output logic      [TL_DW-1:0] denial_d_data,
    output logic                  denial_d_corrupt,
    output logic                  denial_d_valid,
    input  wire logic             denial_d_ready
);
  wire denial_busy;
  wire [TL_RS-1:0] working_source;
  wire [3:0] working_size;
  wire [TL_DW-1:0] working_data;
  wire [TL_DW/8 - 1:0] working_mask;
  wire [2:0] working_opcode;
  wire [TL_AW-1:0] working_address;
  wire [2:0] working_param;
  wire working_valid;
  reg burst;
  skdbf #(TL_RS + 10 + TL_DW / 8 + TL_DW + TL_AW) skidbuffer (
      denial_clock_i,
      denial_reset_i,
      ~denial_d_ready | burst,
      {
        working_source,
        working_size,
        working_data,
        working_mask,
        working_opcode,
        working_address,
        working_param
      },
      working_valid,
      denial_busy,
      {
        denial_a_source,
        denial_a_size,
        denial_a_data,
        denial_a_mask,
        denial_a_opcode,
        denial_a_address,
        denial_a_param
      },
      denial_a_valid
  );
  assign denial_a_ready = ~denial_busy;
  logic [11:0] number_to_write;
  always_comb begin
    case (working_size)
      4'd0: begin  // 1 byte
        number_to_write = 0;
      end
      4'd1: begin  // 2 bytes
        number_to_write = 0;
      end
      4'd2: begin  // 4 bytes
        number_to_write = 0;
      end
      4'd3: begin  // 8 bytes
        number_to_write = 0;  // Minus 2 as when we have recieved 
      end
      4'd4: begin  // 16 bytes
        number_to_write = TL_DW >= 128 ? 12'd0 : 128 / TL_DW - 2;
      end
      4'd5: begin  // 32 bytes
        number_to_write = TL_DW >= 256 ? 12'd0 : 256 / TL_DW - 2;
      end
      4'd6: begin  // 64 bytes
        number_to_write = 512 / TL_DW - 2;
      end
      4'd7: begin  // 128 bytes
        number_to_write = 1024 / TL_DW - 2;
      end
      4'd8: begin  // 256 bytes
        number_to_write = 2048 / TL_DW - 2;
      end
      4'd9: begin  // 512 bytes
        number_to_write = 4096 / TL_DW - 2;
      end
      4'd10: begin  // 1 kilobyte
        number_to_write = 8192 / TL_DW - 2;
      end
      4'd11: begin  // 2 kilobytes
        number_to_write = 16384 / TL_DW - 2;
      end
      4'd12: begin  // 4 kilobytes
        number_to_write = 32768 / TL_DW - 2;
      end
      default: begin
        number_to_write = 12'd0;
      end
    endcase
  end
  reg [11:0] burst_counters;
  always_ff @(posedge denial_clock_i) begin
    if (denial_reset_i) begin
      burst <= 0;
      burst_counters <= 0;
    end else if (working_valid & denial_d_ready & !burst) begin
      burst <= (working_size > $clog2(TL_DW)) && (working_opcode == 3'd4);
      burst_counters <= number_to_write;
    end else begin
      if (burst & denial_d_ready) begin
        burst_counters <= burst_counters == 0 ? 0 : burst_counters - 1'b1;
        burst <= burst_counters != 0;
      end
    end
  end

  always_ff @(posedge denial_clock_i) begin
    if (denial_reset_i) begin
      denial_d_valid <= 1'b0;
    end else if (burst & denial_d_ready) begin
      denial_d_valid <= 1;
    end else if (working_valid & denial_d_ready) begin
      denial_d_corrupt <= working_opcode==3'd4 || working_opcode==3'd2 || working_opcode==3'd3;
      denial_d_denied <= 1;
      denial_d_opcode <= {
        2'b00, working_opcode == 3'd4 || working_opcode == 3'd2 || working_opcode == 3'd3
      };
      denial_d_data <= 0;
      denial_d_param <= 0;
      denial_d_size <= working_size;
      denial_d_source <= working_source;
      denial_d_valid <= 1;
    end else if (!working_valid & denial_d_ready) begin
      denial_d_valid <= 1'b0;
    end
  end
endmodule
/* verilator lint_on WIDTHEXPAND */
/* verilator lint_on WIDTHTRUNC */
/* verilator lint_on UNUSEDSIGNAL */
