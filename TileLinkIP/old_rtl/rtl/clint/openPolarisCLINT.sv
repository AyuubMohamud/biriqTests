// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module openPolarisCLINT #(
    parameter TL_RS = 4
) (
    input wire logic clint_clock_i,
    input wire logic clint_reset_i,

    // Slave interface
    input  wire logic [      2:0] clint_a_opcode,
    input  wire logic [      2:0] clint_a_param,
    input  wire logic [      3:0] clint_a_size,
    input  wire logic [TL_RS-1:0] clint_a_source,
    input  wire logic [     15:0] clint_a_address,
    input  wire logic [      3:0] clint_a_mask,
    input  wire logic [     31:0] clint_a_data,
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire logic             clint_a_corrupt,
    /* verilator lint_on UNUSEDSIGNAL */
    input  wire logic             clint_a_valid,
    output wire logic             clint_a_ready,

    output logic      [      2:0] clint_d_opcode,
    output logic      [      1:0] clint_d_param,
    output logic      [      3:0] clint_d_size,
    output logic      [TL_RS-1:0] clint_d_source,
    output logic                  clint_d_denied,
    output logic      [     31:0] clint_d_data,
    output logic                  clint_d_corrupt,
    output logic                  clint_d_valid,
    input  wire logic             clint_d_ready,

    output wire logic msip_o,
    output wire logic mtip_o
);
  wire clint_busy;
  wire [TL_RS-1:0] working_source;
  wire [3:0] working_size;
  wire [31:0] working_data;
  wire [3:0] working_mask;
  wire [2:0] working_opcode;
  wire [15:0] working_address;
  wire [2:0] working_param;
  wire working_valid;
  skdbf #(TL_RS + 4 + 39 + 17 + 2) skidbuffer (
      clint_clock_i,
      clint_reset_i,
      ~clint_d_ready,
      {
        working_source,
        working_size,
        working_data,
        working_mask,
        working_opcode,
        working_param,
        working_address
      },
      working_valid,
      clint_busy,
      {
        clint_a_source,
        clint_a_size,
        clint_a_data,
        clint_a_mask,
        clint_a_opcode,
        clint_a_param,
        clint_a_address
      },
      clint_a_valid
  );
  assign clint_a_ready = ~clint_busy;

  localparam CSR_MTIMEL = 16'hBFF8;
  localparam CSR_MTIMEH = 16'hBFFC;


  reg msip_r = 0;

  reg [31:0] mtimecmpl = 0;
  reg [31:0] mtimecmph = 0;

  reg [63:0] mtime = 0;
  always_ff @(posedge clint_clock_i) begin
    if (clint_reset_i) begin
      mtime <= 64'h0000000000000000;
    end
        else if (working_valid&clint_d_ready&(
            working_opcode==0
            ||working_opcode==1
            )&(working_address==16'hBFF8||working_address==16'hBFFC)) begin
      mtime[31:0]  <= working_address == 16'hBFF8 ? write_value_machine : mtime[31:0];
      mtime[63:32] <= working_address == 16'hBFFC ? write_value_machine : mtime[63:32];
    end else begin
      mtime <= mtime + 1'b1;
    end
  end
  wire msip_accessed = working_address < 16'h4000;
  logic [31:0] read_machine;
  always_comb begin
    case (working_address)
      CSR_MTIMEL: read_machine = mtime[31:0];
      CSR_MTIMEH: read_machine = mtime[63:32];
      default: begin
        if (msip_accessed) begin
          read_machine = {31'h00000000, msip_r};
        end else begin
          read_machine = working_address[2] ? mtimecmph : mtimecmpl;
        end
      end
    endcase
  end
  logic [31:0] write_value_machine;
  always_comb begin
    case (working_opcode)
      3'd0: begin
        write_value_machine = working_data;
      end
      3'd3: begin
        if (working_param == 3'd0) begin
          write_value_machine = read_machine ^ working_data;
        end else if (working_param == 3'd1) begin
          write_value_machine = read_machine | working_data;
        end else if (working_param == 3'd2) begin
          write_value_machine = read_machine & working_data;
        end else begin
          write_value_machine = working_data;
        end
      end
      default: begin
        write_value_machine = 32'h00000000;
      end
    endcase
  end

  always_ff @(posedge clint_clock_i) begin
    if (working_valid & clint_d_ready & (working_opcode == 0 || working_opcode == 1)) begin
      if (msip_accessed) begin
        msip_r <= write_value_machine[0];
      end else if (working_address < 16'hBFF8) begin
        mtimecmph <= working_address[3] ? write_value_machine : mtimecmph;
        mtimecmpl <= !working_address[3] ? write_value_machine : mtimecmpl;
      end
    end
  end

  always_ff @(posedge clint_clock_i) begin
    if (working_valid & clint_d_ready) begin
      clint_d_data <= read_machine;
      clint_d_opcode <= {2'b00, working_opcode == 4};
      clint_d_size <= working_size;
      clint_d_source <= working_source;
      clint_d_param <= 2'b0;
      clint_d_denied <= 0;
      clint_d_corrupt <= 1'b0;
      clint_d_valid <= 1'b1;
    end else if (!working_valid & clint_d_ready) begin
      clint_d_valid <= 1'b0;
    end
  end
  assign msip_o = msip_r;
  reg mtip_r = 0;
  always_ff @(posedge clint_clock_i) begin
    mtip_r <= mtime >= {mtimecmph, mtimecmpl};
  end
  assign mtip_o = mtip_r;
endmodule
