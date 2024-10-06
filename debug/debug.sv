// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module debug #(parameter TL_RS = 4) (
    input   wire logic                          debug_clock_i,
    input   wire logic                          debug_reset_i,

    // Slave interface
    input   wire logic [2:0]                    debug_a_opcode,
    /* verilator lint_off UNUSEDSIGNAL */
    input   wire logic [2:0]                    debug_a_param,
    input   wire logic [3:0]                    debug_a_size,
    input   wire logic [TL_RS-1:0]              debug_a_source,
    input   wire logic [4:0]                    debug_a_address,
    input   wire logic [3:0]                    debug_a_mask,
    input   wire logic [31:0]                   debug_a_data,
    input   wire logic                          debug_a_corrupt,
    /* verilator lint_on UNUSEDSIGNAL */
    input   wire logic                          debug_a_valid,
    output  wire logic                          debug_a_ready,

    output       logic [2:0]                    debug_d_opcode,
    output       logic [1:0]                    debug_d_param,
    output       logic [3:0]                    debug_d_size,
    output       logic [TL_RS-1:0]              debug_d_source,
    output       logic                          debug_d_denied,
    output       logic [31:0]                   debug_d_data,
    output       logic                          debug_d_corrupt,
    output       logic                          debug_d_valid,
    input   wire logic                          debug_d_ready,

    output  wire logic                          callenv,
    output  wire logic [127:0]                  debug_state_o
);
    wire debug_busy;
    wire [TL_RS-1:0] working_source;
    wire [3:0] working_size;
    wire [31:0] working_data;
    wire [3:0] working_mask;
    wire [2:0] working_opcode;
    wire [4:0] working_address;
    wire working_valid;
    skdbf #(TL_RS+4+39+5) skidbuffer (debug_clock_i, debug_reset_i, ~debug_d_ready, {
        working_source,
        working_size,
        working_data,
        working_mask,
        working_opcode,
        working_address
    }, working_valid, debug_busy, {
        debug_a_source, debug_a_size, debug_a_data, debug_a_mask, debug_a_opcode, debug_a_address
    }, debug_a_valid);
    assign debug_a_ready = ~debug_busy;

    reg [31:0] debug0 = 0;
    reg [31:0] debug1 = 0;
    reg [31:0] debug2 = 0;
    reg [31:0] debug3 = 0;
    always_ff @(posedge debug_clock_i) begin
        if (debug_reset_i) begin
            debug_d_valid <= 0;
        end else if (working_valid&debug_d_ready) begin
            case (working_address[3:2])
            2'b00: debug0 <= working_data;
            2'b01: debug1 <= working_data;
            2'b10: debug2 <= working_data;
            2'b11: debug3 <= working_data;
            endcase
        end
    end

    always_ff @(posedge debug_clock_i) begin
        if (debug_reset_i) begin
            debug_d_valid <= 0;
        end else if (working_valid&debug_d_ready) begin
            debug_d_valid <= 1;
            debug_d_source <= working_source;
            debug_d_size <= working_size;
            debug_d_denied <= 0;
            debug_d_corrupt <= 0;
            debug_d_opcode <= 0;
            debug_d_param <= 0;
            debug_d_data <= 0;
        end else if (!working_valid&debug_d_ready) begin
            debug_d_valid <= 0;
        end
    end

    assign debug_state_o = {debug3,debug2,debug1,debug0};
    assign callenv = working_valid&debug_d_ready&working_address[4];
endmodule
