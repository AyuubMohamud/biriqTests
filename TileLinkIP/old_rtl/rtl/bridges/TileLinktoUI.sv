// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module TileLinktoUI #(
    parameter TL_RS = 4
) (
    input wire logic tilelink_clock_i,
    input wire logic tilelink_reset_i,

    // Slave interface
    input  wire logic [      2:0] ddr3_a_opcode,
    input  wire logic [      2:0] ddr3_a_param,
    input  wire logic [      3:0] ddr3_a_size,
    input  wire logic [TL_RS-1:0] ddr3_a_source,
    input  wire logic [     27:0] ddr3_a_address,
    input  wire logic [      3:0] ddr3_a_mask,
    input  wire logic [     31:0] ddr3_a_data,
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire logic             ddr3_a_corrupt,
    /* verilator lint_on UNUSEDSIGNAL */
    input  wire logic             ddr3_a_valid,
    output wire logic             ddr3_a_ready,

    output logic      [      2:0] ddr3_d_opcode,
    output logic      [      1:0] ddr3_d_param,
    output logic      [      3:0] ddr3_d_size,
    output logic      [TL_RS-1:0] ddr3_d_source,
    output logic                  ddr3_d_denied,
    output logic      [     31:0] ddr3_d_data,
    output logic                  ddr3_d_corrupt,
    output logic                  ddr3_d_valid,
    input  wire logic             ddr3_d_ready,
    // DDR3
    output logic      [      2:0] app_cmd,
    output logic      [     27:0] app_addr,
    output logic                  app_en,
    input  wire logic             app_rdy,

    input wire logic [127:0] app_rd_data,
    /* verilator lint_off UNUSEDSIGNAL */
    input wire logic         app_rd_data_end,   // no relevance
    /* verilator lint_on UNUSEDSIGNAL */
    input wire logic         app_rd_data_valid,

    input  wire logic         app_wdf_rdy,
    output logic              app_wdf_wren,
    output logic      [127:0] app_wdf_data,
    output logic      [ 15:0] app_wdf_mask,
    output logic              app_wdf_end
);
  wire ddr3_busy;
  wire bridge_busy;
  wire [TL_RS-1:0] working_source;
  wire [3:0] working_size;
  wire [31:0] working_data;
  /* verilator lint_off UNUSEDSIGNAL */
  wire [3:0] working_mask;
  /* verilator lint_on UNUSEDSIGNAL */
  wire [2:0] working_opcode;
  wire [27:0] working_address;
  /* verilator lint_off UNUSEDSIGNAL */
  wire [2:0] working_param;
  /* verilator lint_on UNUSEDSIGNAL */
  wire working_valid;
  localparam bridge_idle = 3'b000;
  localparam bridge_read = 3'b001;
  localparam bridge_write = 3'b010;
  reg [2:0] conversion_fsm = bridge_idle;

  skdbf #(TL_RS + 4 + 42 + 28) skidbuffer (
      tilelink_clock_i,
      tilelink_reset_i,
      ddr3_busy,
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
      bridge_busy,
      {
        ddr3_a_source,
        ddr3_a_size,
        ddr3_a_data,
        ddr3_a_mask,
        ddr3_a_opcode,
        ddr3_a_address,
        ddr3_a_param
      },
      ddr3_a_valid
  );
  assign ddr3_busy = (!(app_rdy&&app_wdf_rdy)) || (conversion_fsm!=bridge_idle) || !ddr3_d_ready;
  assign ddr3_a_ready = ~bridge_busy;
  reg [TL_RS-1:0] source;
  reg [3:0] size;
  reg [3:0] low_order;

  wire [3:0] mask = working_size==0 ? {working_address[1:0]==3, working_address[1:0]==2, 
    working_address[1:0]==1, working_address[1:0]==0} : working_size==1 ? {working_address[1], working_address[1], ~working_address[0], ~working_address[0]} :
    4'hF;
  wire [15:0] full_mask = working_address[3:2]==0 ? {12'h000, mask} : working_address[3:2]==1 ? 
    {8'h00, mask, 4'h0} : working_address[3:2]==2 ? {4'h0, mask, 8'h00} : {mask, 12'h000};
  wire [31:0] data = working_size==4'd0 ? (working_address[1:0]==0 ? {24'h000000, working_data[7:0]} :
    working_address[1:0]==1 ? {16'h0000, working_data[7:0], 8'h00} : working_address[1:0]==2 ? {8'h00, working_data[7:0], 16'h0000} :
    {working_data[7:0], 24'h000000} ) : (working_size==4'd1 ? (working_address[1:0]==0 ? {16'h0000, working_data[15:0]} : {working_data[15:0], 16'h0000})
    : working_data);
  wire [127:0] full_data = working_address[3:2] == 0 ? {96'd0, data} : working_address[3:2]==1 ? {64'd0, data, 32'd0} : working_address[3:2]==2 ?
    {32'd0, data, 64'd0} : {data, 96'd0};

  logic [7:0] amount_to_push_tl;
  always_comb begin
    case (working_size)
      4'd3: begin
        amount_to_push_tl = 1;
      end
      4'd4: begin
        amount_to_push_tl = 3;
      end
      4'd5: begin
        amount_to_push_tl = 7;
      end
      4'd6: begin
        amount_to_push_tl = 15;
      end
      4'd7: begin
        amount_to_push_tl = 31;
      end
      4'd8: begin
        amount_to_push_tl = 63;
      end
      4'd9: begin
        amount_to_push_tl = 127;
      end
      4'd10: begin
        amount_to_push_tl = 255;
      end
      default: begin
        amount_to_push_tl = 0;
      end
    endcase
  end
  logic [7:0] amount_to_push_ui;
  always_comb begin
    case (working_size)
      4'd3: begin
        amount_to_push_ui = 0;
      end
      4'd4: begin
        amount_to_push_ui = 0;
      end
      4'd5: begin
        amount_to_push_ui = 1;
      end
      4'd6: begin
        amount_to_push_ui = 3;
      end
      4'd7: begin
        amount_to_push_ui = 7;
      end
      4'd8: begin
        amount_to_push_ui = 15;
      end
      4'd9: begin
        amount_to_push_ui = 31;
      end
      4'd10: begin
        amount_to_push_ui = 63;
      end
      default: begin
        amount_to_push_ui = 0;
      end
    endcase
  end
  wire write_fifo_pushed = app_wdf_rdy & app_wdf_wren;
  wire cmd_fifo_pushed = app_en & app_rdy;
  reg [7:0] ui_bursts = 0;
  reg [7:0] tl_bursts = 0;
  wire full, empty, overflow, underflow, read;
  wire [127:0] read_data;
  wire reset = conversion_fsm == bridge_idle;
  sfifo #(
      .DW(128),
      .FW(32)
  ) convert_fifo (
      tilelink_clock_i,
      reset,
      app_rd_data_valid,
      app_rd_data,
      full,
      read,
      read_data,
      empty,
      underflow,
      overflow
  );
  reg [1:0] internal_burst = 0;
  assign read = ((internal_burst == 3) && ddr3_d_ready);
  wire [7:0] byte_select = low_order==0 ? read_data[7:0] : low_order==1 ? read_data[15:8] :
    low_order==2 ? read_data[23:16] : low_order==3 ? read_data[31:24] : low_order==4 ? read_data[39:32]
    : low_order==5 ? read_data[47:40] : low_order==6 ? read_data[55:48] : low_order==7 ?
    read_data[63:56] : low_order==8 ? read_data[71:64] : low_order==9 ? read_data[79:72]
    : low_order==10 ? read_data[87:80] : low_order==11 ? read_data[95:88] : low_order==12 ? 
    read_data[103:96] : low_order==13 ? read_data[111:104] : low_order==14 ? read_data[119:112]:
    read_data[127:120];
  wire [15:0] hw_select = low_order==0 ? read_data[15:0] : low_order==2 ? read_data[31:16]:
    low_order==4 ? read_data[47:32] : low_order==6 ? read_data[63:48] : low_order==8 ? read_data[79:64]:
    low_order==10 ? read_data[95:80] : low_order==12 ? read_data[111:96] :read_data[127:112];
  wire [31:0] word_select = low_order==0 ? read_data[31:0] : low_order==4 ? read_data[63:32] :
    low_order==8 ? read_data[95:64] : read_data[127:96];
  always_ff @(posedge tilelink_clock_i) begin
    case (conversion_fsm)
      bridge_idle: begin
        if (working_valid && app_rdy && app_wdf_rdy && ddr3_d_ready) begin
          size <= working_size;
          source <= working_source;
          app_addr <= {working_address[27:4], 4'b0000};
          app_en <= 1;
          low_order <= working_address[3:0];
          if (working_opcode == 3'd4) begin
            app_cmd <= 1;
            conversion_fsm <= bridge_read;
            internal_burst <= size == 4'd3 ? {working_address[3], 1'b0} : 0;
          end else if (((working_opcode == 3'd1) || (working_opcode == 3'd0))) begin
            app_cmd <= 0;
            app_wdf_data <= full_data;
            app_wdf_mask <= ~full_mask;
            app_wdf_wren <= 1;
            app_wdf_end <= 1; // ignore what xilinx says about this signal, this is tied to app_wdf_wren
            conversion_fsm <= bridge_write;
          end
          ui_bursts <= amount_to_push_ui;
          tl_bursts <= amount_to_push_tl;

        end
        if (ddr3_d_ready) begin
          ddr3_d_valid <= 0;
        end
      end
      bridge_read: begin
        if (cmd_fifo_pushed) begin
          // check if we need to push another read command
          if (ui_bursts == 0) begin
            app_en <= 0;
          end else begin
            app_addr  <= app_addr + 28'h0000010;
            ui_bursts <= ui_bursts - 1;
          end
        end

        if (!empty & ddr3_d_ready) begin
          if (size <= 4'd2) begin
            ddr3_d_data <= size==4'd0 ? {24'h0,byte_select} : size==4'd1 ? {16'h0,hw_select} : word_select;
            conversion_fsm <= bridge_idle;
          end else begin
            ddr3_d_data <= internal_burst==0 ? read_data[31:0] : internal_burst==1 ? read_data[63:32] :
                        internal_burst==2 ? read_data[95:64] : read_data[127:96];
            if ((tl_bursts == 0)) begin
              internal_burst <= 0;
              conversion_fsm <= bridge_idle;
            end else begin
              internal_burst <= internal_burst + 1;
              tl_bursts <= tl_bursts - 1;
            end
          end
          ddr3_d_valid <= 1;
          ddr3_d_size <= size;
          ddr3_d_source <= source;
          ddr3_d_corrupt <= 0;
          ddr3_d_denied <= 0;
          ddr3_d_param <= 0;
          ddr3_d_opcode <= 1;
        end else if (empty) begin
          ddr3_d_valid <= ddr3_d_ready ? 1'b0 : ddr3_d_valid;
        end
      end
      bridge_write: begin
        if (app_rdy) begin
          app_en <= 0;
        end
        if (app_wdf_rdy) begin
          app_wdf_wren <= 0;
          app_wdf_end  <= 0;
        end
        if (!app_wdf_wren & !app_en) begin
          conversion_fsm <= bridge_idle;
          ddr3_d_valid <= 1;
          ddr3_d_opcode <= 0;
          ddr3_d_size <= size;
          ddr3_d_source <= source;
          ddr3_d_corrupt <= 0;
          ddr3_d_denied <= 0;
          ddr3_d_param <= 0;
        end
      end
      default: begin

      end
    endcase
  end
endmodule
