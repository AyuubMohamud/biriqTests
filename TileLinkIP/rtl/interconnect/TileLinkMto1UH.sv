// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off WIDTHTRUNC */
module TileLinkMto1UH #(
    parameter  C_ARBITRATION_SCHEME  = 1,
    parameter  C_NUM_MASTERS         = 2,
    parameter  C_TILELINK_DATA_WIDTH = 32,
    parameter  C_TILELINK_ADDR_WIDTH = 32,
    parameter  C_TILELINK_ID_WIDTH   = 4,
    localparam NM                    = C_NUM_MASTERS,
    localparam DW                    = C_TILELINK_DATA_WIDTH,
    localparam AW                    = C_TILELINK_ADDR_WIDTH,
    localparam ID                    = C_TILELINK_ID_WIDTH,
    localparam SZ                    = 3
) (
    input  wire                     tilelink_clock_i,
    input  wire                     tilelink_reset_i,
    input  wire [       3*(NM)-1:0] master_a_opcode,
    input  wire [       3*(NM)-1:0] master_a_param,
    input  wire [      (NM*SZ)-1:0] master_a_size,
    input  wire [      (NM*ID)-1:0] master_a_source,
    input  wire [      (AW*NM)-1:0] master_a_address,
    input  wire [    (NM*DW/8)-1:0] master_a_mask,
    input  wire [        NM*DW-1:0] master_a_data,
    input  wire [           NM-1:0] master_a_corrupt,
    input  wire [           NM-1:0] master_a_valid,
    output wire [           NM-1:0] master_a_ready,
    output wire [       (NM*3)-1:0] master_d_opcode,
    output wire [       (NM*2)-1:0] master_d_param,
    output wire [      (NM*SZ)-1:0] master_d_size,
    output wire [      (NM*ID)-1:0] master_d_source,
    output wire [           NM-1:0] master_d_denied,
    output wire [        NM*DW-1:0] master_d_data,
    output wire [           NM-1:0] master_d_corrupt,
    output wire [           NM-1:0] master_d_valid,
    input  wire [           NM-1:0] master_d_ready,
    output wire [              2:0] slave_a_opcode,
    output wire [              2:0] slave_a_param,
    output wire [              2:0] slave_a_size,
    output wire [$clog2(NM)+ID-1:0] slave_a_source,
    output wire [           AW-1:0] slave_a_address,
    output wire [         DW/8-1:0] slave_a_mask,
    output wire [           DW-1:0] slave_a_data,
    output wire                     slave_a_corrupt,
    output wire                     slave_a_valid,
    input  wire                     slave_a_ready,
    input  wire [              2:0] slave_d_opcode,
    input  wire [              1:0] slave_d_param,
    input  wire [              2:0] slave_d_size,
    input  wire [$clog2(NM)+ID-1:0] slave_d_source,
    input  wire                     slave_d_denied,
    input  wire [           DW-1:0] slave_d_data,
    input  wire                     slave_d_corrupt,
    input  wire                     slave_d_valid,
    output wire                     slave_d_ready
);
  // A channel is very simple, simple address decode and forward
  wire                     master_ready;
  wire [              2:0] working_slave_d_opcode;
  wire [              1:0] working_slave_d_param;
  wire [              2:0] working_slave_d_size;
  wire [$clog2(NM)+ID-1:0] working_slave_d_source;
  wire                     working_slave_d_denied;
  wire [           DW-1:0] working_slave_d_data;
  wire                     working_slave_d_corrupt;
  wire                     working_slave_d_valid;
  wire                     d_ready;
  reg  [       (NM*3)-1:0] master_d_opcode_q;
  reg  [       (NM*2)-1:0] master_d_param_q;
  reg  [      (NM*SZ)-1:0] master_d_size_q;
  reg  [      (NM*ID)-1:0] master_d_source_q;
  reg  [           NM-1:0] master_d_denied_q;
  reg  [        NM*DW-1:0] master_d_data_q;
  reg  [           NM-1:0] master_d_corrupt_q;
  reg  [           NM-1:0] master_d_valid_q;
  initial master_d_valid_q = '0;
  assign slave_d_ready = d_ready;
  assign master_d_opcode = master_d_opcode_q;
  assign master_d_param = master_d_param_q;
  assign master_d_size = master_d_size_q;
  assign master_d_source = master_d_source_q;
  assign master_d_denied = master_d_denied_q;
  assign master_d_data = master_d_data_q;
  assign master_d_corrupt = master_d_corrupt_q;
  assign master_d_valid = master_d_valid_q;
  tl_skdbf #(
      .DW  (7 + DW + SZ + ID + $clog2(NM)),
      .SYNC(0)
  ) skidbuffer (
      .clk_i(tilelink_clock_i),
      .rst_i(tilelink_reset_i),
      .combinational_ready_i(master_ready),
      .cycle_data_o({
        working_slave_d_opcode,
        working_slave_d_param,
        working_slave_d_size,
        working_slave_d_source,
        working_slave_d_denied,
        working_slave_d_data,
        working_slave_d_corrupt
      }),
      .cycle_vld_o(working_slave_d_valid),
      .registered_ready_o(d_ready),
      .registered_data_i({
        slave_d_opcode,
        slave_d_param,
        slave_d_size,
        slave_d_source,
        slave_d_denied,
        slave_d_data,
        slave_d_corrupt
      }),
      .registered_vld_i(slave_d_valid)
  );
  wire [NM-1:0] master_select;
  for (genvar x = 0; x < NM; x++) begin : master_decode
    assign master_select[x] = (x == (working_slave_d_source[$clog2(NM)+ID-1:ID]));
  end

  assign master_ready = |(master_select & master_d_ready); // Simply check if the currently routed master is ready

  for (genvar i = 0; i < NM; i++) begin : slaveResponse
    always_ff @(posedge tilelink_clock_i) begin : responsePrepare
      if (tilelink_reset_i) begin
        master_d_valid_q[i] <= 1'b0;
      end else if (working_slave_d_valid & (master_d_ready[i]||!master_d_valid[i]) & master_select[i]) begin
        master_d_corrupt_q[i] <= working_slave_d_corrupt;
        master_d_data_q[(DW*(i+1))-1:DW*(i)] <= working_slave_d_data;
        master_d_denied_q[i] <= working_slave_d_denied;
        master_d_opcode_q[3*(i+1)-1:3*i] <= working_slave_d_opcode;
        master_d_param_q[2*(i+1)-1:2*i] <= working_slave_d_param;
        master_d_size_q[3*(i+1)-1:3*i] <= working_slave_d_size;
        master_d_source_q[ID*(i+1)-1:ID*i] <= working_slave_d_source[ID-1:0];
        master_d_valid_q[i] <= 1'b1;
      end else if (master_d_ready[i]) begin
        master_d_valid_q[i] <= 1'b0;
      end
    end
  end

  wire [  NM-1:0] masterRequestReady;
  wire [     2:0] working_master_a_opcode [NM-1:0];
  wire [     2:0] working_master_a_param  [NM-1:0];
  wire [     2:0] working_master_a_size   [NM-1:0];
  wire [  ID-1:0] working_master_a_source [NM-1:0];
  wire [DW/8-1:0] working_master_a_mask   [NM-1:0];
  wire [  DW-1:0] working_master_a_data   [NM-1:0];
  wire [  AW-1:0] working_master_a_address[NM-1:0];
  wire            working_master_a_corrupt[NM-1:0];
  wire [  NM-1:0] working_master_a_valid;
  wire            working_master_a_ready  [NM-1:0];

  for (genvar i = 0; i < NM; i++) begin : gen0
    tl_skdbf #(
        .DW(3 + 2 + SZ + DW + ID + 1 + DW / 8 + AW + 1)
    ) master_skidbuffers (
        tilelink_clock_i,
        tilelink_reset_i,
        masterRequestReady[i],
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
        working_master_a_ready[i],
        {
          master_a_opcode[((i+1)*3)-1:(i)*3],
          master_a_param[((i+1)*3)-1:(i)*3],
          master_a_size[((i+1)*SZ)-1:(i)*SZ],
          master_a_source[((i+1)*ID)-1:(i)*ID],
          master_a_mask[((i+1)*DW/8)-1:(i)*DW/8],
          master_a_data[((i+1)*DW)-1:(i)*DW],
          master_a_address[((i+1)*AW)-1:(i)*AW],
          master_a_corrupt[i]
        },
        master_a_valid[i]
    );
  end
  for (genvar i = 0; i < NM; i++) begin : gen1
    assign master_a_ready[i] = working_master_a_ready[i];
  end

  /**
    The condition for accepting any request is ready||!valid for the slave
  **/
  reg lock_active_q;
  reg [NM-1:0] lock_q;
  logic [NM-1:0] bus_grant;
  reg [4:0] burst_count;
  initial begin
    lock_active_q = '0;
    lock_q = '0;

  end

  logic [           2:0] arb_opcode;
  logic [           2:0] arb_param;
  logic [           2:0] arb_size;
  logic [        ID-1:0] arb_id;
  logic [        DW-1:0] arb_data;
  logic [      DW/8-1:0] arb_mask;
  logic [        AW-1:0] arb_address;
  logic                  arb_corrupt;
  logic [$clog2(NM)-1:0] arb_sel;
  generate
    if (C_ARBITRATION_SCHEME == 0) begin : g_fxp
      always_comb begin
        arb_sel     = 'x;
        bus_grant   = '0;
        arb_opcode  = 'x;
        arb_param   = 'x;
        arb_size    = 'x;
        arb_id      = 'x;
        arb_data    = 'x;
        arb_mask    = 'x;
        arb_address = 'x;
        arb_corrupt = 'x;
        for (integer i = 0; i < NM; i++) begin
          if (working_master_a_valid[i] & ((lock_q[i] & lock_active_q) || !lock_active_q)) begin
            arb_sel     = i[$clog2(NM)-1:0];
            bus_grant   = 1'd1 << i;
            arb_opcode  = working_master_a_opcode[i];
            arb_param   = working_master_a_param[i];
            arb_size    = working_master_a_size[i];
            arb_id      = working_master_a_source[i];
            arb_data    = working_master_a_data[i];
            arb_mask    = working_master_a_mask[i];
            arb_address = working_master_a_address[i];
            arb_corrupt = working_master_a_corrupt[i];
          end
        end
      end
    end else if (C_ARBITRATION_SCHEME == 1) begin : g_rr
      reg [NM-1:0] pref_q;
      initial begin
        pref_q[0] = '1;
        pref_q[NM-1:1] = '0;
      end
      always_ff @(posedge tilelink_clock_i) begin
        if (tilelink_reset_i) begin
          pref_q[0] <= 1'b1;
          pref_q[NM-1:1] <= '0;
        end else if (!lock_active_q && (slave_a_ready || !slave_a_valid)) begin
          pref_q <= bus_grant != working_master_a_valid ? working_master_a_valid&~bus_grant : pref_q; // Double check this
        end
      end
      always_comb begin
        arb_sel     = 'x;
        bus_grant   = '0;
        arb_opcode  = 'x;
        arb_param   = 'x;
        arb_size    = 'x;
        arb_id      = 'x;
        arb_data    = 'x;
        arb_mask    = 'x;
        arb_address = 'x;
        arb_corrupt = 'x;
        for (integer i = 0; i < NM; i++) begin
          if (working_master_a_valid[i] & ((lock_q[i] & lock_active_q) || (!lock_active_q&pref_q[i]))) begin
            arb_sel     = i[$clog2(NM)-1:0];
            bus_grant   = 1'd1 << i;
            arb_opcode  = working_master_a_opcode[i];
            arb_param   = working_master_a_param[i];
            arb_size    = working_master_a_size[i];
            arb_id      = working_master_a_source[i];
            arb_data    = working_master_a_data[i];
            arb_mask    = working_master_a_mask[i];
            arb_address = working_master_a_address[i];
            arb_corrupt = working_master_a_corrupt[i];
          end
        end
      end
    end
  endgenerate

  genvar i;
  for (i = 0; i < NM; i++) begin
    assign masterRequestReady[i] = bus_grant[i] & slave_a_ready;
  end

  logic [4:0] number_to_write;
  always_comb begin
    case (arb_size)
      3'd0: begin  // 1 byte
        number_to_write = 0;
      end
      3'd1: begin  // 2 bytes
        number_to_write = 0;
      end
      3'd2: begin  // 4 bytes
        number_to_write = 0;
      end
      3'd3: begin  // 8 bytes
        number_to_write = 0;  // Minus 2 as when we have recieved 
      end
      3'd4: begin  // 16 bytes
        number_to_write = DW >= 64 ? 5'd0 : 128 / DW - 2;
      end
      3'd5: begin  // 32 bytes
        number_to_write = DW >= 128 ? 5'd0 : 256 / DW - 2;
      end
      3'd6: begin  // 64 bytes
        number_to_write = 512 / DW - 2;
      end
      3'd7: begin  // 128 bytes
        number_to_write = 1024 / DW - 2;
      end
    endcase
  end

  always_ff @(posedge tilelink_clock_i)
    if (tilelink_reset_i) lock_active_q <= 1'b0;
    else if (lock_active_q)
      lock_active_q <= !((burst_count == 0) && (slave_a_ready || !slave_a_valid) && (|bus_grant));
    else if ((|bus_grant) & (slave_a_ready || !slave_a_valid))
      lock_active_q <= (arb_size > $clog2(DW / 8)) && (arb_opcode != 4);

  always_ff @(posedge tilelink_clock_i)
    if (tilelink_reset_i) lock_q <= '0;
    else if (!lock_active_q) lock_q <= bus_grant;

  always_ff @(posedge tilelink_clock_i)
    if (tilelink_reset_i) burst_count <= '0;
    else if (lock_active_q) begin
      if ((slave_a_ready || !slave_a_valid) && (|bus_grant))
        if (burst_count != 0) burst_count <= burst_count - 1;
    end else burst_count <= number_to_write;
  reg [              2:0] slave_a_opcode_q;
  reg [              2:0] slave_a_param_q;
  reg [              2:0] slave_a_size_q;
  reg [$clog2(NM)+ID-1:0] slave_a_source_q;
  reg [           AW-1:0] slave_a_address_q;
  reg [         DW/8-1:0] slave_a_mask_q;
  reg [           DW-1:0] slave_a_data_q;
  reg                     slave_a_corrupt_q;
  reg                     slave_a_valid_q;
  initial slave_a_valid_q = 1'b0;
  always_ff @(posedge tilelink_clock_i) begin
    if (tilelink_reset_i) begin
      slave_a_valid_q <= 1'b0;
    end else if ((|bus_grant) & (slave_a_ready || !slave_a_valid)) begin
      slave_a_valid_q <= 1'b1;
      slave_a_corrupt_q <= arb_corrupt;
      slave_a_data_q <= arb_data;
      slave_a_mask_q <= arb_mask;
      slave_a_address_q <= arb_address;
      slave_a_opcode_q <= arb_opcode;
      slave_a_param_q <= arb_param;
      slave_a_size_q <= arb_size;
      slave_a_source_q <= {arb_sel, arb_id};
    end else if (slave_a_ready) begin
      slave_a_valid_q <= 1'b0;
    end
  end
  assign slave_a_opcode  = slave_a_opcode_q;
  assign slave_a_param   = slave_a_param_q;
  assign slave_a_size    = slave_a_size_q;
  assign slave_a_source  = slave_a_source_q;
  assign slave_a_address = slave_a_address_q;
  assign slave_a_mask    = slave_a_mask_q;
  assign slave_a_data    = slave_a_data_q;
  assign slave_a_corrupt = slave_a_corrupt_q;
  assign slave_a_valid   = slave_a_valid_q;
endmodule
/* verilator lint_on WIDTHEXPAND */
/* verilator lint_on WIDTHTRUNC */
