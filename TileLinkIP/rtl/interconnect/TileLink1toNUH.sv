// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off WIDTHTRUNC */
module TileLink1toNUH #(
    parameter C_ARBITRATION_SCHEME = 1,
    parameter C_NUM_SLAVES = 2,
    parameter C_TILELINK_DATA_WIDTH = 32,
    parameter C_TILELINK_ADDR_WIDTH = 32,
    parameter C_TILELINK_ID_WIDTH = 4,
    parameter [(C_TILELINK_ADDR_WIDTH*(C_NUM_SLAVES-1))-1:0] C_SLAVE_ADDRESSES = {
      32'h00001000
    },  //! Base addresses of mentioned slaves
    parameter [(C_TILELINK_ADDR_WIDTH*(C_NUM_SLAVES-1))-1:0] C_SLAVE_MASKS = {32'h00002000},
    localparam AW = C_TILELINK_ADDR_WIDTH,
    localparam DW = C_TILELINK_DATA_WIDTH,
    localparam ID = C_TILELINK_ID_WIDTH,
    localparam NS = C_NUM_SLAVES
) (
    input  wire                 tilelink_clock_i,
    input  wire                 tilelink_reset_i,
    input  wire [          2:0] master_a_opcode,
    input  wire [          2:0] master_a_param,
    input  wire [          2:0] master_a_size,
    input  wire [       ID-1:0] master_a_source,
    input  wire [       AW-1:0] master_a_address,
    input  wire [     DW/8-1:0] master_a_mask,
    input  wire [       DW-1:0] master_a_data,
    input  wire                 master_a_corrupt,
    input  wire                 master_a_valid,
    output wire                 master_a_ready,
    output wire [          2:0] master_d_opcode,
    output wire [          1:0] master_d_param,
    output wire [          2:0] master_d_size,
    output wire [       ID-1:0] master_d_source,
    output wire                 master_d_denied,
    output wire [       DW-1:0] master_d_data,
    output wire                 master_d_corrupt,
    output wire                 master_d_valid,
    input  wire                 master_d_ready,
    output wire [   3*(NS)-1:0] slave_a_opcode,
    output wire [   3*(NS)-1:0] slave_a_param,
    output wire [   (NS*3)-1:0] slave_a_size,
    output wire [  (NS*ID)-1:0] slave_a_source,
    output wire [  (AW*NS)-1:0] slave_a_address,
    output wire [(NS*DW/8)-1:0] slave_a_mask,
    output wire [    NS*DW-1:0] slave_a_data,
    output wire [       NS-1:0] slave_a_corrupt,
    output wire [       NS-1:0] slave_a_valid,
    input  wire [       NS-1:0] slave_a_ready,
    input  wire [   (NS*3)-1:0] slave_d_opcode,
    input  wire [   (NS*2)-1:0] slave_d_param,
    input  wire [   (NS*3)-1:0] slave_d_size,
    input  wire [  (NS*ID)-1:0] slave_d_source,
    input  wire [       NS-1:0] slave_d_denied,
    input  wire [    NS*DW-1:0] slave_d_data,
    input  wire [       NS-1:0] slave_d_corrupt,
    input  wire [       NS-1:0] slave_d_valid,
    output wire [       NS-1:0] slave_d_ready
);
  // A channel is very simple, simple address decode and forward
  wire                 master_ready;
  wire [          2:0] working_master_a_opcode;
  wire [          2:0] working_master_a_param;
  wire [          2:0] working_master_a_size;
  wire [       ID-1:0] working_master_a_source;
  wire [       AW-1:0] working_master_a_address;
  wire [     DW/8-1:0] working_master_a_mask;
  wire [       DW-1:0] working_master_a_data;
  wire                 working_master_a_corrupt;
  wire                 working_master_a_valid;
  wire                 a_ready;
  reg  [   3*(NS)-1:0] slave_a_opcode_q;
  reg  [   3*(NS)-1:0] slave_a_param_q;
  reg  [   (NS*3)-1:0] slave_a_size_q;
  reg  [  (NS*ID)-1:0] slave_a_source_q;
  reg  [  (AW*NS)-1:0] slave_a_address_q;
  reg  [(NS*DW/8)-1:0] slave_a_mask_q;
  reg  [    NS*DW-1:0] slave_a_data_q;
  reg  [       NS-1:0] slave_a_corrupt_q;
  reg  [       NS-1:0] slave_a_valid_q;
  initial slave_a_valid_q = '0;
  assign master_a_ready = a_ready;
  tl_skdbf #(
      .DW(7 + DW / 8 + DW + 3 + ID + AW)
  ) skidbuffer (
      .clk_i(tilelink_clock_i),
      .rst_i(tilelink_reset_i),
      .combinational_ready_i(master_ready),
      .cycle_data_o({
        working_master_a_opcode,
        working_master_a_param,
        working_master_a_size,
        working_master_a_source,
        working_master_a_address,
        working_master_a_mask,
        working_master_a_data,
        working_master_a_corrupt
      }),
      .cycle_vld_o(working_master_a_valid),
      .registered_ready_o(a_ready),
      .registered_data_i({
        master_a_opcode,
        master_a_param,
        master_a_size,
        master_a_source,
        master_a_address,
        master_a_mask,
        master_a_data,
        master_a_corrupt
      }),
      .registered_vld_i(master_a_valid)
  );
  wire [NS-2:0] slave_decode;
  for (genvar x = 0; x < NS - 1; x++) begin : address_decode
    assign slave_decode[x] = (working_master_a_address & C_SLAVE_MASKS[(AW*(x+1))-1:(AW*x)])==C_SLAVE_ADDRESSES[(AW*(x+1))-1:(AW*x)];
  end
  wire [NS-1:0] slave_select;
  assign slave_select[NS-2:0] = slave_decode[NS-2:0];
  assign slave_select[NS-1] = ~(|slave_decode);
  assign master_ready = |(slave_select & slave_a_ready);

  for (genvar i = 0; i < NS; i++) begin : slaveRequest
    always_ff @(posedge tilelink_clock_i) begin : requestPrepare
      if (tilelink_reset_i) begin
        slave_a_valid_q[i] <= 1'b0;
      end else if (working_master_a_valid & (slave_a_ready[i]||!slave_a_valid[i]) & slave_select[i]) begin
        slave_a_address_q[(AW*(i+1))-1:AW*(i)]      <= working_master_a_address;
        slave_a_corrupt_q[i]                        <= working_master_a_corrupt;
        slave_a_data_q[(DW*(i+1))-1:DW*(i)]         <= working_master_a_data;
        slave_a_mask_q[((DW/8)*(i+1))-1:(DW/8)*(i)] <= working_master_a_mask;
        slave_a_opcode_q[3*(i+1)-1:3*i]             <= working_master_a_opcode;
        slave_a_param_q[3*(i+1)-1:3*i]              <= working_master_a_param;
        slave_a_size_q[3*(i+1)-1:3*i]               <= working_master_a_size;
        slave_a_source_q[ID*(i+1)-1:ID*i]           <= working_master_a_source;
        slave_a_valid_q[i]                          <= 1'b1;
      end else if (slave_a_ready[i]) begin
        slave_a_valid_q[i] <= 1'b0;
      end
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
  wire [NS-1:0] slaveResponseOk;
  wire [   2:0] working_slave_d_opcode [NS-1:0];
  wire [   1:0] working_slave_d_param  [NS-1:0];
  wire [   2:0] working_slave_d_size   [NS-1:0];
  wire [ID-1:0] working_slave_d_source [NS-1:0];
  wire          working_slave_d_denied [NS-1:0];
  wire [DW-1:0] working_slave_d_data   [NS-1:0];
  wire          working_slave_d_corrupt[NS-1:0];
  wire [NS-1:0] working_slave_d_valid;

  for (genvar i = 0; i < NS; i++) begin : gen0
    tl_skdbf #(
        .DW(3 + 2 + 3 + DW + ID + 1 + 1)
    ) slave_skidbuffers (
        tilelink_clock_i,
        tilelink_reset_i,
        slaveResponseOk[i],
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
        slave_d_ready[i],
        {
          slave_d_opcode[((i+1)*3)-1:(i)*3],
          slave_d_param[((i+1)*2)-1:(i)*2],
          slave_d_size[((i+1)*3)-1:(i)*3],
          slave_d_source[((i+1)*ID)-1:(i)*ID],
          slave_d_denied[i],
          slave_d_data[((i+1)*DW)-1:(i)*DW],
          slave_d_corrupt[i]
        },
        slave_d_valid[i]
    );
  end

  reg lock_active_q;
  reg [NS-1:0] lock_q;
  logic [NS-1:0] bus_grant;
  reg [4:0] burst_count;
  initial begin
    lock_active_q = '0;
    lock_q = '0;
  end

  logic [   2:0] arb_opcode;
  logic [   1:0] arb_param;
  logic [   2:0] arb_size;
  logic [ID-1:0] arb_id;
  logic [DW-1:0] arb_data;
  logic          arb_denied;
  logic          arb_corrupt;
  generate
    if (C_ARBITRATION_SCHEME == 0) begin : g_fxp
      always_comb begin
        bus_grant   = '0;
        arb_opcode  = 'x;
        arb_param   = 'x;
        arb_size    = 'x;
        arb_id      = 'x;
        arb_data    = 'x;
        arb_denied  = 'x;
        arb_corrupt = 'x;
        for (integer i = 0; i < NS; i++) begin
          if (working_slave_d_valid[i] & ((lock_q[i] & lock_active_q) || !lock_active_q)) begin
            bus_grant   = 1'd1 << i;
            arb_opcode  = working_slave_d_opcode[i];
            arb_param   = working_slave_d_param[i];
            arb_size    = working_slave_d_size[i];
            arb_id      = working_slave_d_source[i];
            arb_data    = working_slave_d_data[i];
            arb_denied  = working_slave_d_denied[i];
            arb_corrupt = working_slave_d_corrupt[i];
          end
        end
      end
    end else if (C_ARBITRATION_SCHEME == 1) begin : g_rr
      reg [NS-1:0] pref_q;
      initial begin
        pref_q[0] = '1;
        pref_q[NS-1:1] = '0;
      end
      always_ff @(posedge tilelink_clock_i) begin
        if (tilelink_reset_i) begin
          pref_q[0] <= 1'b1;
          pref_q[NS-1:1] <= '0;
        end else if (!lock_active_q && (master_d_ready || !master_d_valid)) begin
          pref_q <= bus_grant != working_slave_d_valid ? working_slave_d_valid&~bus_grant : pref_q; // Double check this
        end
      end
      always_comb begin
        bus_grant   = '0;
        arb_opcode  = 'x;
        arb_param   = 'x;
        arb_size    = 'x;
        arb_id      = 'x;
        arb_data    = 'x;
        arb_denied  = 'x;
        arb_corrupt = 'x;
        for (integer i = 0; i < NS; i++) begin
          if (working_slave_d_valid[i] & ((lock_q[i] & lock_active_q) || (!lock_active_q&pref_q[i]))) begin
            bus_grant   = 1'd1 << i;
            arb_opcode  = working_slave_d_opcode[i];
            arb_param   = working_slave_d_param[i];
            arb_size    = working_slave_d_size[i];
            arb_id      = working_slave_d_source[i];
            arb_data    = working_slave_d_data[i];
            arb_denied  = working_slave_d_denied[i];
            arb_corrupt = working_slave_d_corrupt[i];
          end
        end
      end
    end
  endgenerate

  genvar i;
  for (i = 0; i < NS; i++) begin
    assign slaveResponseOk[i] = bus_grant[i] & master_d_ready;
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
        number_to_write = DW >= 64 ? 5'd0 : (128 / DW) - 2;
      end
      3'd5: begin  // 32 bytes
        number_to_write = DW >= 128 ? 5'd0 : (256 / DW) - 2;
      end
      3'd6: begin  // 64 bytes
        number_to_write = (512 / DW) - 2;
      end
      3'd7: begin  // 128 bytes
        number_to_write = (1024 / DW) - 2;
      end
    endcase
  end

  always_ff @(posedge tilelink_clock_i)
    if (tilelink_reset_i) lock_active_q <= 1'b0;
    else if (lock_active_q)
      lock_active_q <= !((burst_count == 0) && (master_d_ready || !master_d_valid) && (|bus_grant));
    else if ((|bus_grant) & (master_d_ready || !master_d_valid))
      lock_active_q <= (arb_size > $clog2(DW / 8)) && (arb_opcode != 0);

  always_ff @(posedge tilelink_clock_i)
    if (tilelink_reset_i) lock_q <= '0;
    else if (!lock_active_q) lock_q <= bus_grant;

  always_ff @(posedge tilelink_clock_i)
    if (tilelink_reset_i) burst_count <= '0;
    else if (lock_active_q) begin
      if ((master_d_ready || !master_d_valid) && (|bus_grant))
        if (burst_count != 0) burst_count <= burst_count - 1;
    end else burst_count <= number_to_write;

  reg [   2:0] master_d_opcode_q;
  reg [   1:0] master_d_param_q;
  reg [   2:0] master_d_size_q;
  reg [ID-1:0] master_d_source_q;
  reg          master_d_denied_q;
  reg [DW-1:0] master_d_data_q;
  reg          master_d_corrupt_q;
  reg          master_d_valid_q;
  initial master_d_valid_q = '0;
  always_ff @(posedge tilelink_clock_i) begin
    if (tilelink_reset_i) begin
      master_d_valid_q <= 1'b0;
    end else if ((|bus_grant) & (master_d_ready || !master_d_valid)) begin
      master_d_valid_q   <= 1'b1;
      master_d_corrupt_q <= arb_corrupt;
      master_d_data_q    <= arb_data;
      master_d_denied_q  <= arb_denied;
      master_d_opcode_q  <= arb_opcode;
      master_d_param_q   <= arb_param;
      master_d_size_q    <= arb_size;
      master_d_source_q  <= arb_id;
    end else if (master_d_ready) begin
      master_d_valid_q <= 1'b0;
    end
  end

  assign master_d_opcode  = master_d_opcode_q;
  assign master_d_param   = master_d_param_q;
  assign master_d_size    = master_d_size_q;
  assign master_d_source  = master_d_source_q;
  assign master_d_denied  = master_d_denied_q;
  assign master_d_data    = master_d_data_q;
  assign master_d_corrupt = master_d_corrupt_q;
  assign master_d_valid   = master_d_valid_q;
endmodule
/* verilator lint_on WIDTHEXPAND */
/* verilator lint_on WIDTHTRUNC */
