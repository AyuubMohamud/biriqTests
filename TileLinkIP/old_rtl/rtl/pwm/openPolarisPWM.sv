// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module openPolarisPWM #(
    parameter TL_RS = 4
) (
    input wire logic pwm_clock_i,
    input wire logic pwm_reset_i,

    // Slave interface
    input  wire logic [      2:0] pwm_a_opcode,
    input  wire logic [      2:0] pwm_a_param,
    input  wire logic [      3:0] pwm_a_size,
    input  wire logic [TL_RS-1:0] pwm_a_source,
    input  wire logic [      2:0] pwm_a_address,
    input  wire logic [      3:0] pwm_a_mask,
    input  wire logic [     31:0] pwm_a_data,
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire logic             pwm_a_corrupt,
    /* verilator lint_on UNUSEDSIGNAL */
    input  wire logic             pwm_a_valid,
    output wire logic             pwm_a_ready,

    output logic      [      2:0] pwm_d_opcode,
    output logic      [      1:0] pwm_d_param,
    output logic      [      3:0] pwm_d_size,
    output logic      [TL_RS-1:0] pwm_d_source,
    output logic                  pwm_d_denied,
    output logic      [     31:0] pwm_d_data,
    output logic                  pwm_d_corrupt,
    output logic                  pwm_d_valid,
    input  wire logic             pwm_d_ready,

    output wire logic int_o,

    output wire logic pin_o
);
  /*
        CSR 0: Reload value[12:1], Int ENABLE, PWM enable
        CSR 1: Sample FIFO
    */
  // Requires testing
  wire pwm_busy;
  wire [TL_RS-1:0] working_source;
  wire [3:0] working_size;
  wire [31:0] working_data;
  wire [3:0] working_mask;
  wire [2:0] working_opcode;
  wire [2:0] working_address;
  wire [2:0] working_param;
  wire working_valid;
  skdbf #(TL_RS + 4 + 42 + 3) skidbuffer (
      pwm_clock_i,
      pwm_reset_i,
      ~pwm_d_ready,
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
      pwm_busy,
      {pwm_a_source, pwm_a_size, pwm_a_data, pwm_a_mask, pwm_a_opcode, pwm_a_address, pwm_a_param},
      pwm_a_valid
  );
  assign pwm_a_ready = ~pwm_busy;
  reg [13:0] cfg_pwm;
  wire write_en = working_valid&pwm_d_ready&(working_address[2])&(working_opcode==3'd1||working_opcode==3'd0);
  wire full;
  wire sample_accept;
  wire [11:0] sample_data;
  wire empty;
  wire underflow;
  wire overflow;
  sfifo #(
      .DW(12),
      .FW(8)
  ) samples (
      pwm_clock_i,
      pwm_reset_i,
      write_en,
      working_data[13:2],
      full,
      sample_accept,
      sample_data,
      empty,
      underflow,
      overflow
  );

  always_ff @(posedge pwm_clock_i) begin
    if (pwm_reset_i) begin
      cfg_pwm <= 0;
    end
        else if (working_valid&pwm_d_ready&!(working_address[2])&(working_opcode==3'd1||working_opcode==3'd0)) begin
      cfg_pwm <= working_data[13:0];
    end
  end

  always_ff @(posedge pwm_clock_i) begin
    if (pwm_reset_i) begin
      pwm_d_valid <= 1'b0;
    end else if (working_valid & pwm_d_ready) begin
      pwm_d_data <= working_address[2] ? {30'h0, full, empty} : {18'd0, cfg_pwm};
      pwm_d_denied <= 0;
      pwm_d_corrupt <= 0;
      pwm_d_opcode <= {2'd0, working_opcode == 3'd4};
      pwm_d_param <= 0;
      pwm_d_source <= working_source;
      pwm_d_size <= working_size;
      pwm_d_valid <= 1'b1;
    end else if (!working_valid & pwm_d_ready) begin
      pwm_d_valid <= 1'b0;
    end
  end
  reg [11:0] counter;
  initial counter = 0;
  reg [11:0] sample;
  initial sample = 0;
  always_ff @(posedge pwm_clock_i) begin
    if (pwm_reset_i | cfg_pwm[0]) begin
      counter <= 0;
      sample  <= 0;
    end else if (counter == cfg_pwm[13:2]) begin
      counter <= 0;
      sample  <= sample_data;
    end else begin
      counter <= counter + 1'b1;
    end
  end

  assign sample_accept = counter == cfg_pwm[13:2];
  assign pin_o = (counter < sample);
  assign int_o = empty & cfg_pwm[1] & cfg_pwm[0];
endmodule
