// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off WIDTHTRUNC */
module TileLinkMto1 #(
    parameter M = 2,
    parameter TL_DW = 32,
    parameter TL_AW = 32,
    parameter TL_RS = 4,
    parameter TL_SZ = 4
) (
    input wire logic tilelink_clock_i,
    input wire logic tilelink_reset_i,

    input  wire logic [      3*(M)-1:0] master_a_opcode,
    input  wire logic [      3*(M)-1:0] master_a_param,
    input  wire logic [  (M*TL_SZ)-1:0] master_a_size,
    input  wire logic [  (M*TL_RS)-1:0] master_a_source,
    input  wire logic [  (TL_AW*M)-1:0] master_a_address,
    input  wire logic [(M*TL_DW/8)-1:0] master_a_mask,
    input  wire logic [    M*TL_DW-1:0] master_a_data,
    input  wire logic [          M-1:0] master_a_corrupt,
    input  wire logic [          M-1:0] master_a_valid,
    output wire logic [          M-1:0] master_a_ready,

    output logic      [    (M*3)-1:0] master_d_opcode,
    output logic      [    (M*2)-1:0] master_d_param,
    output logic      [(M*TL_SZ)-1:0] master_d_size,
    output logic      [(M*TL_RS)-1:0] master_d_source,
    output logic      [        M-1:0] master_d_denied,
    output logic      [  M*TL_DW-1:0] master_d_data,
    output logic      [        M-1:0] master_d_corrupt,
    output logic      [        M-1:0] master_d_valid,
    input  wire logic [        M-1:0] master_d_ready,

    output logic      [                2:0] slave_a_opcode,
    output logic      [                2:0] slave_a_param,
    output logic      [          TL_SZ-1:0] slave_a_size,
    output logic      [$clog2(M)+TL_RS-1:0] slave_a_source,
    output logic      [          TL_AW-1:0] slave_a_address,
    output logic      [        TL_DW/8-1:0] slave_a_mask,
    output logic      [          TL_DW-1:0] slave_a_data,
    output logic                            slave_a_corrupt,
    output logic                            slave_a_valid,
    input  wire logic                       slave_a_ready,

    input  wire logic [                2:0] slave_d_opcode,
    input  wire logic [                1:0] slave_d_param,
    input  wire logic [          TL_SZ-1:0] slave_d_size,
    input  wire logic [$clog2(M)+TL_RS-1:0] slave_d_source,
    input  wire logic                       slave_d_denied,
    input  wire logic [          TL_DW-1:0] slave_d_data,
    input  wire logic                       slave_d_corrupt,
    input  wire logic                       slave_d_valid,
    output wire logic                       slave_d_ready
);
  // A channel is very simple, simple address decode and forward
  wire                       master_stalled;
  wire [                2:0] working_slave_d_opcode;
  wire [                1:0] working_slave_d_param;
  wire [          TL_SZ-1:0] working_slave_d_size;
  wire [$clog2(M)+TL_RS-1:0] working_slave_d_source;
  wire                       working_slave_d_denied;
  wire [          TL_DW-1:0] working_slave_d_data;
  wire                       working_slave_d_corrupt;
  wire                       working_slave_d_valid;
  wire                       busy;
  assign slave_d_ready = !busy;
  skdbf #(
      .DW(7 + TL_DW + TL_SZ + TL_RS + $clog2(M))
  ) skidbuffer (
      tilelink_clock_i,
      tilelink_reset_i,
      master_stalled,
      {
        working_slave_d_opcode,
        working_slave_d_param,
        working_slave_d_size,
        working_slave_d_source,
        working_slave_d_denied,
        working_slave_d_data,
        working_slave_d_corrupt
      },
      working_slave_d_valid,
      busy,
      {
        slave_d_opcode,
        slave_d_param,
        slave_d_size,
        slave_d_source,
        slave_d_denied,
        slave_d_data,
        slave_d_corrupt
      },
      slave_d_valid
  );
  wire [M-1:0] master_select;
  for (genvar x = 0; x < M; x++) begin : master_decode
    assign master_select[x] = (x == (working_slave_d_source[$clog2(
        M
    )+TL_RS-1:TL_RS])) & working_slave_d_valid;
  end

  assign master_stalled = |(master_select & ~master_d_ready);

  for (genvar i = 0; i < M; i++) begin : slaveResponse
    always_ff @(posedge tilelink_clock_i) begin : responsePrepare
      if (tilelink_reset_i) begin
        master_d_valid[i] <= 1'b0;
      end else if (working_slave_d_valid & master_d_ready[i] & master_select[i]) begin
        master_d_corrupt[i] <= working_slave_d_corrupt;
        master_d_data[(TL_DW*(i+1))-1:TL_DW*(i)] <= working_slave_d_data;
        master_d_denied[i] <= working_slave_d_denied;
        master_d_opcode[3*(i+1)-1:3*i] <= working_slave_d_opcode;
        master_d_param[2*(i+1)-1:2*i] <= working_slave_d_param;
        master_d_size[4*(i+1)-1:4*i] <= working_slave_d_size;
        master_d_source[TL_RS*(i+1)-1:TL_RS*i] <= working_slave_d_source[TL_RS-1:0];
        master_d_valid[i] <= 1'b1;
      end else if ((!working_slave_d_valid | !master_select[i]) & master_d_ready[i]) begin
        master_d_valid[i] <= 1'b0;
      end
    end
  end
  wire [      M-1:0] masterRequestStalled;
  wire [        2:0] working_master_a_opcode [M-1:0];
  wire [        2:0] working_master_a_param  [M-1:0];
  wire [  TL_SZ-1:0] working_master_a_size   [M-1:0];
  wire [  TL_RS-1:0] working_master_a_source [M-1:0];
  wire [TL_DW/8-1:0] working_master_a_mask   [M-1:0];
  wire [  TL_DW-1:0] working_master_a_data   [M-1:0];
  wire [  TL_AW-1:0] working_master_a_address[M-1:0];
  wire               working_master_a_corrupt[M-1:0];
  wire               working_master_a_valid  [M-1:0];
  wire               working_master_a_busy   [M-1:0];

  for (genvar i = 0; i < M; i++) begin : gen0
    skdbf #(
        .DW(3 + 2 + TL_SZ + TL_DW + TL_RS + 1 + TL_DW / 8 + TL_AW + 1)
    ) master_skidbuffers (
        tilelink_clock_i,
        tilelink_reset_i,
        masterRequestStalled[i],
        {
          working_master_a_opcode[i],
          working_master_a_param[i],
          working_master_a_size[i],
          working_master_a_source[i],
          working_master_a_mask[i],
          working_master_a_data[i],
          working_master_a_address[i],
          working_master_a_corrupt[i]
        },
        working_master_a_valid[i],
        working_master_a_busy[i],
        {
          master_a_opcode[((i+1)*3)-1:(i)*3],
          master_a_param[((i+1)*3)-1:(i)*3],
          master_a_size[((i+1)*TL_SZ)-1:(i)*TL_SZ],
          master_a_source[((i+1)*TL_RS)-1:(i)*TL_RS],
          master_a_mask[((i+1)*TL_DW/8)-1:(i)*TL_DW/8],
          master_a_data[((i+1)*TL_DW)-1:(i)*TL_DW],
          master_a_address[((i+1)*TL_AW)-1:(i)*TL_AW],
          master_a_corrupt[i]
        },
        master_a_valid[i]
    );
  end
  for (genvar i = 0; i < M; i++) begin : gen1
    assign master_a_ready[i] = ~working_master_a_busy[i];
  end


  reg [M-1:0] block = 0; //! When a slave responds at the same time as others, a slave is selected, which can respond and the others are stalled,
  //! Then the slave is blocked to let other slaves respond until no more conflicts are found, hence the register is reset
  reg lock = 0;
  reg [M-1:0] locked_master_select = 0;
  logic [2:0] resp_opcode;
  logic [2:0] resp_param;
  logic [TL_SZ-1:0] resp_size;
  logic [TL_RS-1:0] resp_id;
  logic [TL_DW-1:0] resp_data;
  logic [TL_DW/8-1:0] resp_mask;
  logic [TL_AW-1:0] resp_address;
  logic resp_corrupt;
  reg [11:0] burst_counters = 0;
  logic once;
  wire burst = once & slave_a_ready & (resp_size > {$clog2(
      (TL_DW) / 8
  )}) && (resp_opcode != 4) | lock;
  wire burst_ending = burst_counters == 0 && lock && once;
  logic [$clog2(M)-1:0] bitscan;
  logic twoormore;
  logic Break;
  always_comb begin
    bitscan = 'x;
    once = 0;
    Break = 0;
    for (integer n = 0; n < M; n++) begin
      if (working_master_a_valid[n]&slave_a_ready&(lock ? locked_master_select[n] : ~block[n])&!Break) begin
        bitscan = n[$clog2(M)-1:0];
        once = 1'b1;
        Break = 1;
      end
    end
  end
  logic Break2;
  always_comb begin
    twoormore = 0;
    Break2 = 0;
    for (integer n = 0; n < M; n++) begin
      if (working_master_a_valid[n] && (n[$clog2(
              M
          )-1:0] != bitscan) && once & slave_a_ready & !Break2) begin
        twoormore = 1'b1;
        Break2 = 1'b1;
      end
    end
  end
  for (genvar i = 0; i < M; i++) begin : blockLogic
    always_ff @(posedge tilelink_clock_i) begin
      block[i] <= tilelink_reset_i ? 1'b0 :
          lock ? block[i] : twoormore ? (i[$clog2(M)-1:0] == bitscan) : 1'b0;
    end
  end
  logic [11:0] number_to_write;
  always_ff @(posedge tilelink_clock_i) begin
    lock <= tilelink_reset_i ? 1'b0 : lock ? !burst_ending : once&slave_a_ready&(resp_size>{$clog2(
        TL_DW / 8
    )}) & (resp_opcode != 4);
    for (integer x = 0; x < M; x++) begin
      locked_master_select[x] <= tilelink_reset_i ? 1'b0 : locked_master_select[x] ? !burst_ending : x[$clog2(
          M)-1:0] == bitscan && once && burst;
    end
    burst_counters <= lock ?  burst_ending ? 12'h000 : once ? burst_counters - 1'b1 : burst_counters : once&&slave_a_ready&&(resp_size>{$clog2(
        TL_DW / 8
    )}) && (resp_opcode != 4) ? number_to_write : 12'h000;
  end
  always_comb begin
    case (resp_size)
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
  always_comb begin
    resp_corrupt = working_master_a_corrupt[bitscan];
    resp_data = working_master_a_data[bitscan];
    resp_address = working_master_a_address[bitscan];
    resp_id = working_master_a_source[bitscan];
    resp_opcode = working_master_a_opcode[bitscan];
    resp_param = working_master_a_param[bitscan];
    resp_size = working_master_a_size[bitscan];
    resp_mask = working_master_a_mask[bitscan];
  end
  for (genvar n = 0; n < M; n++) begin : stallLogic
    assign masterRequestStalled[n] = (!slave_a_ready) | (twoormore && (n[$clog2(
        M
    )-1:0] != bitscan)) | (!locked_master_select[n] & lock);
  end
  always_ff @(posedge tilelink_clock_i) begin
    if (tilelink_reset_i) begin
      slave_a_valid <= 1'b0;
    end else if (once & slave_a_ready) begin
      slave_a_valid <= 1'b1;
      slave_a_corrupt <= resp_corrupt;
      slave_a_data <= resp_data;
      slave_a_mask <= resp_mask;
      slave_a_address <= resp_address;
      slave_a_opcode <= resp_opcode;
      slave_a_param <= resp_param;
      slave_a_size <= resp_size;
      slave_a_source <= {bitscan, resp_id};
    end else if (!once & slave_a_ready) begin
      slave_a_valid <= 1'b0;
    end
  end
endmodule
