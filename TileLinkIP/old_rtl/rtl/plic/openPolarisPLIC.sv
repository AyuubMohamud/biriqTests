// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module openPolarisPLIC #(
    parameter TL_RS = 4
) (
    input wire logic plic_clock_i,
    input wire logic plic_reset_i,

    // Slave interface
    input  wire logic [      2:0] plic_a_opcode,
    input  wire logic [      2:0] plic_a_param,
    input  wire logic [      3:0] plic_a_size,
    input  wire logic [TL_RS-1:0] plic_a_source,
    input  wire logic [     21:0] plic_a_address,
    input  wire logic [      3:0] plic_a_mask,
    input  wire logic [     31:0] plic_a_data,
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire logic             plic_a_corrupt,
    /* verilator lint_on UNUSEDSIGNAL */
    input  wire logic             plic_a_valid,
    output wire logic             plic_a_ready,

    output logic      [      2:0] plic_d_opcode,
    output logic      [      1:0] plic_d_param,
    output logic      [      3:0] plic_d_size,
    output logic      [TL_RS-1:0] plic_d_source,
    output logic                  plic_d_denied,
    output logic      [     31:0] plic_d_data,
    output logic                  plic_d_corrupt,
    output logic                  plic_d_valid,
    input  wire logic             plic_d_ready,

    input   wire logic [30:0]                   int_i, //! No gateway needed, only one interrupt is performed per peripheral

    output wire logic [1:0] int_o
);
  wire plic_busy;
  wire [TL_RS-1:0] working_source;
  wire [3:0] working_size;
  wire [31:0] working_data;
  wire [3:0] working_mask;
  wire [2:0] working_opcode;
  wire [21:0] working_address;
  wire [2:0] working_param;
  wire working_valid;
  skdbf #(TL_RS + 4 + 60 + 4) skidbuffer (
      plic_clock_i,
      plic_reset_i,
      ~plic_d_ready,
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
      plic_busy,
      {
        plic_a_source,
        plic_a_size,
        plic_a_data,
        plic_a_mask,
        plic_a_opcode,
        plic_a_address,
        plic_a_param
      },
      plic_a_valid
  );
  assign plic_a_ready = !plic_busy;
  reg [31:0] source_priority;
  reg [31:0] int_enable[0:1];
  reg priority_threshold[0:1];
  always_ff @(posedge plic_clock_i) begin
    if (working_valid&plic_d_ready&(working_opcode==3'd0)&(working_address[21:12]==0)) begin
      source_priority[working_address[6:2]] <= working_address[6:2] == 0 ? 0 : working_data[0];
    end
    if (working_valid&plic_d_ready&(working_opcode==3'd0)&(working_address[21:12]==10'd2)) begin
      int_enable[working_address[7]] <= working_data & 32'hFFFFFFFE;
    end
    if (working_valid&plic_d_ready&(working_opcode==3'd0)&(working_address[21:16]==6'b100000)&(!working_address[2])) begin
      priority_threshold[working_address[12]] <= working_data[0];
    end
  end


  reg [4:0] claim[0:1];
  wire [31:0] interrupt_pending = {int_i, 1'b0};
  logic [31:0] claim_block[0:1];
  for (genvar i = 0; i < 2; i++) begin : percontext
    for (genvar x = 0; x < 32; x++) begin : perbit
      assign claim_block[i][x] = claim[i] == x;
    end
  end
  logic [4:0] res[0:1];
  for (genvar i = 0; i < 2; i++) begin : genClaimLogic
    always_comb begin
      casez (int_enable[i] & ~claim_block[i] & interrupt_pending)
        32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz10: res[i] = 1;
        32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzz100: res[i] = 2;
        32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzz1000: res[i] = 3;
        32'bzzzzzzzzzzzzzzzzzzzzzzzzzzz10000: res[i] = 4;
        32'bzzzzzzzzzzzzzzzzzzzzzzzzzz100000: res[i] = 5;
        32'bzzzzzzzzzzzzzzzzzzzzzzzzz1000000: res[i] = 6;
        32'bzzzzzzzzzzzzzzzzzzzzzzzz10000000: res[i] = 7;
        32'bzzzzzzzzzzzzzzzzzzzzzzz100000000: res[i] = 8;
        32'bzzzzzzzzzzzzzzzzzzzzzz1000000000: res[i] = 9;
        32'bzzzzzzzzzzzzzzzzzzzzz10000000000: res[i] = 10;
        32'bzzzzzzzzzzzzzzzzzzzz100000000000: res[i] = 11;
        32'bzzzzzzzzzzzzzzzzzzz1000000000000: res[i] = 12;
        32'bzzzzzzzzzzzzzzzzzz10000000000000: res[i] = 13;
        32'bzzzzzzzzzzzzzzzzz100000000000000: res[i] = 14;
        32'bzzzzzzzzzzzzzzzz1000000000000000: res[i] = 15;
        32'bzzzzzzzzzzzzzzz10000000000000000: res[i] = 16;
        32'bzzzzzzzzzzzzzz100000000000000000: res[i] = 17;
        32'bzzzzzzzzzzzzz1000000000000000000: res[i] = 18;
        32'bzzzzzzzzzzzz10000000000000000000: res[i] = 19;
        32'bzzzzzzzzzzz100000000000000000000: res[i] = 20;
        32'bzzzzzzzzzz1000000000000000000000: res[i] = 21;
        32'bzzzzzzzzz10000000000000000000000: res[i] = 22;
        32'bzzzzzzzz100000000000000000000000: res[i] = 23;
        32'bzzzzzzz1000000000000000000000000: res[i] = 24;
        32'bzzzzzz10000000000000000000000000: res[i] = 25;
        32'bzzzzz100000000000000000000000000: res[i] = 26;
        32'bzzzz1000000000000000000000000000: res[i] = 27;
        32'bzzz10000000000000000000000000000: res[i] = 28;
        32'bzz100000000000000000000000000000: res[i] = 29;
        32'bz1000000000000000000000000000000: res[i] = 30;
        32'b10000000000000000000000000000000: res[i] = 31;
        default: res[i] = 0;
      endcase
    end
  end

  logic [31:0] context_specific_read;
  always_comb begin
    case (working_address[2])
      1'b0: begin
        context_specific_read = {31'h0, priority_threshold[working_address[12]]};
      end
      1'b1: begin
        context_specific_read = {27'h0, res[working_address[12]]};
      end
    endcase
  end

  logic [31:0] generic_read;
  always_comb begin
    case (working_address[13:12])
      2'b00: begin
        generic_read = {31'h0, source_priority[working_address[6:2]]};
      end
      2'b01: begin
        generic_read = interrupt_pending & ~claim_block[0] & ~claim_block[1];
      end
      2'b10: begin
        generic_read = int_enable[working_address[7]];
      end
      default: begin
        generic_read = 0;
      end
    endcase
  end

  wire generic = (working_address < 22'h200000);

  wire claim_made = working_valid&plic_d_ready&(working_opcode==3'd4)&(working_address[2]&working_address[21:16]==6'b100000);
  wire complete_attempted =  working_valid&plic_d_ready&(working_opcode==3'd0)&(working_address[2]&working_address[21:16]==6'b100000);

  always_ff @(posedge plic_clock_i) begin
    if (claim_made) begin
      claim[working_address[12]] <= res[working_address[12]];
    end else if (complete_attempted) begin
      claim[working_address[12]] <= 0;
    end
  end

  always_ff @(posedge plic_clock_i) begin
    if (plic_reset_i) begin
      plic_d_valid <= 0;
    end else if (working_valid && plic_d_ready) begin
      plic_d_valid <= 1;
      plic_d_corrupt <= 0;
      plic_d_denied <= 0;
      plic_d_source <= working_source;
      plic_d_size <= working_size;
      plic_d_param <= 0;
      plic_d_opcode <= {2'b00, working_opcode == 3'd4};
      plic_d_data <= generic ? generic_read : context_specific_read;
    end else if (!working_valid && plic_d_ready) begin
      plic_d_valid <= 0;
    end
  end

  for (genvar i = 0; i < 2; i++) begin : generateLevelInterrupts
    assign int_o[i] = |({32{priority_threshold[i]}}&(interrupt_pending)&int_enable[i]&source_priority&~claim_block[0]&~claim_block[1]);
  end

endmodule
