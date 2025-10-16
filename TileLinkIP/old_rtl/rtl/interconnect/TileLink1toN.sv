// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off WIDTHTRUNC */
module TileLink1toN #(
    parameter N = 3,
    parameter [(TL_AW*(N-1))-1:0] slave_addresses = {
      32'h00001000, 32'h00002000
    },  //! Base addresses of mentioned slaves
    parameter [(TL_AW*(N-1))-1:0] slave_end_addresses = {32'h00002000, 32'h10000000},
    parameter TL_DW = 32,
    parameter TL_AW = 32,
    parameter TL_RS = 4,
    parameter TL_SZ = 4
) (
    input wire logic tilelink_clock_i,
    input wire logic tilelink_reset_i,

    input  wire logic [        2:0] master_a_opcode,
    input  wire logic [        2:0] master_a_param,
    input  wire logic [  TL_SZ-1:0] master_a_size,
    input  wire logic [  TL_RS-1:0] master_a_source,
    input  wire logic [  TL_AW-1:0] master_a_address,
    input  wire logic [TL_DW/8-1:0] master_a_mask,
    input  wire logic [  TL_DW-1:0] master_a_data,
    input  wire logic               master_a_corrupt,
    input  wire logic               master_a_valid,
    output wire logic               master_a_ready,

    output logic      [      2:0] master_d_opcode,
    output logic      [      1:0] master_d_param,
    output logic      [TL_SZ-1:0] master_d_size,
    output logic      [TL_RS-1:0] master_d_source,
    output logic                  master_d_denied,
    output logic      [TL_DW-1:0] master_d_data,
    output logic                  master_d_corrupt,
    output logic                  master_d_valid,
    input  wire logic             master_d_ready,


    output logic      [      3*(N)-1:0] slave_a_opcode,
    output logic      [      3*(N)-1:0] slave_a_param,
    output logic      [  (N*TL_SZ)-1:0] slave_a_size,
    output logic      [  (N*TL_RS)-1:0] slave_a_source,
    output logic      [  (TL_AW*N)-1:0] slave_a_address,
    output logic      [(N*TL_DW/8)-1:0] slave_a_mask,
    output logic      [    N*TL_DW-1:0] slave_a_data,
    output logic      [          N-1:0] slave_a_corrupt,
    output logic      [          N-1:0] slave_a_valid,
    input  wire logic [          N-1:0] slave_a_ready,

    input  wire logic [    (N*3)-1:0] slave_d_opcode,
    input  wire logic [    (N*2)-1:0] slave_d_param,
    input  wire logic [(N*TL_SZ)-1:0] slave_d_size,
    input  wire logic [(N*TL_RS)-1:0] slave_d_source,
    input  wire logic [        N-1:0] slave_d_denied,
    input  wire logic [  N*TL_DW-1:0] slave_d_data,
    input  wire logic [        N-1:0] slave_d_corrupt,
    input  wire logic [        N-1:0] slave_d_valid,
    output wire logic [        N-1:0] slave_d_ready
);
  // A channel is very simple, simple address decode and forward
  wire               master_stalled;
  wire [        2:0] working_master_a_opcode;
  wire [        2:0] working_master_a_param;
  wire [  TL_SZ-1:0] working_master_a_size;
  wire [  TL_RS-1:0] working_master_a_source;
  wire [  TL_AW-1:0] working_master_a_address;
  wire [TL_DW/8-1:0] working_master_a_mask;
  wire [  TL_DW-1:0] working_master_a_data;
  wire               working_master_a_corrupt;
  wire               working_master_a_valid;
  wire               busy;
  assign master_a_ready = !busy;
  skdbf #(
      .DW(7 + TL_DW / 8 + TL_DW + TL_SZ + TL_RS + TL_AW)
  ) skidbuffer (
      tilelink_clock_i,
      tilelink_reset_i,
      master_stalled,
      {
        working_master_a_opcode,
        working_master_a_param,
        working_master_a_size,
        working_master_a_source,
        working_master_a_address,
        working_master_a_mask,
        working_master_a_data,
        working_master_a_corrupt
      },
      working_master_a_valid,
      busy,
      {
        master_a_opcode,
        master_a_param,
        master_a_size,
        master_a_source,
        master_a_address,
        master_a_mask,
        master_a_data,
        master_a_corrupt
      },
      master_a_valid
  );
  wire [N-2:0] slave_decode;
  for (genvar x = 0; x < N - 1; x++) begin : address_decode
    assign slave_decode[x] = ((slave_addresses[(TL_AW*(x+1))-1:(TL_AW*x)]<=working_master_a_address)&&(slave_end_addresses[(TL_AW*(x+1))-1:(TL_AW*x)]>working_master_a_address)&working_master_a_valid);
  end
  wire [N-1:0] slave_select;
  assign slave_select[N-2:0] = slave_decode[N-2:0];
  assign slave_select[N-1] = ~(|slave_decode);
  assign master_stalled = |(slave_select & ~slave_a_ready);

  for (genvar i = 0; i < N; i++) begin : slaveRequest
    always_ff @(posedge tilelink_clock_i) begin : requestPrepare
      if (tilelink_reset_i) begin
        slave_a_valid[i] <= 1'b0;
      end else if (working_master_a_valid & slave_a_ready[i] & slave_select[i]) begin
        slave_a_address[(TL_AW*(i+1))-1:TL_AW*(i)] <= working_master_a_address;
        slave_a_corrupt[i] <= working_master_a_corrupt;
        slave_a_data[(TL_DW*(i+1))-1:TL_DW*(i)] <= working_master_a_data;
        slave_a_mask[((TL_DW/8)*(i+1))-1:(TL_DW/8)*(i)] <= working_master_a_mask;
        slave_a_opcode[3*(i+1)-1:3*i] <= working_master_a_opcode;
        slave_a_param[3*(i+1)-1:3*i] <= working_master_a_param;
        slave_a_size[4*(i+1)-1:4*i] <= working_master_a_size;
        slave_a_source[TL_RS*(i+1)-1:TL_RS*i] <= working_master_a_source;
        slave_a_valid[i] <= 1'b1;
      end else if ((!working_master_a_valid | !slave_select[i]) & slave_a_ready[i]) begin
        slave_a_valid[i] <= 1'b0;
      end
    end
  end

  wire [    N-1:0] slaveResponseStalled;
  wire [      2:0] working_slave_d_opcode [N-1:0];
  wire [      1:0] working_slave_d_param  [N-1:0];
  wire [TL_SZ-1:0] working_slave_d_size   [N-1:0];
  wire [TL_RS-1:0] working_slave_d_source [N-1:0];
  wire             working_slave_d_denied [N-1:0];
  wire [TL_DW-1:0] working_slave_d_data   [N-1:0];
  wire             working_slave_d_corrupt[N-1:0];
  wire             working_slave_d_valid  [N-1:0];
  wire             working_slave_d_busy   [N-1:0];

  for (genvar i = 0; i < N; i++) begin : gen0
    skdbf #(
        .DW(3 + 2 + TL_SZ + TL_DW + TL_RS + 1 + 1)
    ) slave_skidbuffers (
        tilelink_clock_i,
        tilelink_reset_i,
        slaveResponseStalled[i],
        {
          working_slave_d_opcode[i],
          working_slave_d_param[i],
          working_slave_d_size[i],
          working_slave_d_source[i],
          working_slave_d_denied[i],
          working_slave_d_data[i],
          working_slave_d_corrupt[i]
        },
        working_slave_d_valid[i],
        working_slave_d_busy[i],
        {
          slave_d_opcode[((i+1)*3)-1:(i)*3],
          slave_d_param[((i+1)*2)-1:(i)*2],
          slave_d_size[((i+1)*TL_SZ)-1:(i)*TL_SZ],
          slave_d_source[((i+1)*TL_RS)-1:(i)*TL_RS],
          slave_d_denied[i],
          slave_d_data[((i+1)*TL_DW)-1:(i)*TL_DW],
          slave_d_corrupt[i]
        },
        slave_d_valid[i]
    );
  end
  for (genvar i = 0; i < N; i++) begin : gen1
    assign slave_d_ready[i] = ~working_slave_d_busy[i];
  end


  reg [N-1:0] block = 0; //! When a slave responds at the same time as others, a slave is selected, which can respond and the others are stalled,
  //! Then the slave is blocked to let other slaves respond until no more conflicts are found, hence the register is reset
  reg lock = 0;
  reg [N-1:0] locked_slave_select = 0;
  logic [2:0] resp_opcode;
  logic [1:0] resp_param;
  logic [TL_SZ-1:0] resp_size;
  logic [TL_RS-1:0] resp_id;
  logic [TL_DW-1:0] resp_data;
  logic resp_denied;
  logic resp_corrupt;
  reg [11:0] burst_counters = 0;
  logic once;
  wire burst = once & master_d_ready & (resp_size > {$clog2(
      (TL_DW) / 8
  )}) & (resp_opcode == 1) | lock;  // bursts are from the slave
  wire burst_ending = burst_counters == 0 && lock && once;
  logic [$clog2(N)-1:0] bitscan;
  logic twoormore;
  logic FINISHSEL;
  always_comb begin
    bitscan = 'x;
    once = 0;
    FINISHSEL = 0;
    for (integer n = 0; n < N; n++) begin
      if (working_slave_d_valid[n]&master_d_ready&(lock ? locked_slave_select[n] : ~block[n])&!FINISHSEL) begin
        bitscan = n[$clog2(N)-1:0];
        once = 1'b1;
        FINISHSEL = 1;
      end
    end
  end
  logic FINISHSEL2;
  always_comb begin
    twoormore  = 0;
    FINISHSEL2 = 0;
    for (integer n = 0; n < N; n++) begin
      if (working_slave_d_valid[n] && (n[$clog2(
              N
          )-1:0] != bitscan) && once & master_d_ready & !FINISHSEL2) begin
        twoormore  = 1'b1;
        FINISHSEL2 = 1'b1;
      end
    end
  end
  for (genvar i = 0; i < N; i++) begin : blockLogic
    always_ff @(posedge tilelink_clock_i) begin
      block[i] <= tilelink_reset_i ? 1'b0 :
          lock ? block[i] : twoormore ? (i[$clog2(N)-1:0] == bitscan) : 1'b0;
    end
  end
  logic [11:0] number_to_write;
  always_ff @(posedge tilelink_clock_i) begin
    lock <= tilelink_reset_i ? 1'b0 : lock ? !burst_ending : once&master_d_ready&(resp_size>{$clog2(
        TL_DW / 8
    )}) & (resp_opcode == 1);
    for (integer x = 0; x < N; x++) begin
      locked_slave_select[x] <= tilelink_reset_i ? 1'b0 : locked_slave_select[x] ? !burst_ending : x[$clog2(
          N)-1:0] == bitscan && once && burst;
    end
    burst_counters <= lock ? burst_ending ? 12'h000 : once ? burst_counters - 1'b1 : burst_counters : once&&master_d_ready&&(resp_size>{$clog2(
        TL_DW / 8
    )}) && (resp_opcode == 1) ? number_to_write : 12'h000;
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
    resp_corrupt = working_slave_d_corrupt[bitscan];
    resp_data = working_slave_d_data[bitscan];
    resp_denied = working_slave_d_denied[bitscan];
    resp_id = working_slave_d_source[bitscan];
    resp_opcode = working_slave_d_opcode[bitscan];
    resp_param = working_slave_d_param[bitscan];
    resp_size = working_slave_d_size[bitscan];
  end

  for (genvar n = 0; n < N; n++) begin : stallLogic
    assign slaveResponseStalled[n] = (!master_d_ready) | (twoormore && (n[$clog2(
        N
    )-1:0] != bitscan)) | (!locked_slave_select[n] & lock);
  end
  always_ff @(posedge tilelink_clock_i) begin
    if (tilelink_reset_i) begin
      master_d_valid <= 1'b0;
    end else if (once & master_d_ready) begin
      master_d_valid <= 1'b1;
      master_d_corrupt <= resp_corrupt;
      master_d_data <= resp_data;
      master_d_denied <= resp_denied;
      master_d_opcode <= resp_opcode;
      master_d_param <= resp_param;
      master_d_size <= resp_size;
      master_d_source <= resp_id;
    end else if (!once & master_d_ready) begin
      master_d_valid <= 1'b0;
    end
  end
endmodule
