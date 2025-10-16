// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
module openPolarisGPIO #(
    parameter TL_RS = 4,
    parameter [5:0] NGPIO = 16,
    parameter rise_interrupts = 1,
    parameter fall_interrupts = 1
) (
    input wire logic gpio_clock_i,
    input wire logic gpio_reset_i,

    // Slave interface
    input  wire logic [      2:0] gpio_a_opcode,
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire logic [      2:0] gpio_a_param,
    input  wire logic [      3:0] gpio_a_size,
    input  wire logic [TL_RS-1:0] gpio_a_source,
    input  wire logic [      4:0] gpio_a_address,
    input  wire logic [      3:0] gpio_a_mask,
    input  wire logic [     31:0] gpio_a_data,
    input  wire logic             gpio_a_corrupt,
    /* verilator lint_on UNUSEDSIGNAL */
    input  wire logic             gpio_a_valid,
    output wire logic             gpio_a_ready,

    output logic      [      2:0] gpio_d_opcode,
    output logic      [      1:0] gpio_d_param,
    output logic      [      3:0] gpio_d_size,
    output logic      [TL_RS-1:0] gpio_d_source,
    output logic                  gpio_d_denied,
    output logic      [     31:0] gpio_d_data,
    output logic                  gpio_d_corrupt,
    output logic                  gpio_d_valid,
    input  wire logic             gpio_d_ready,

    output wire logic [NGPIO-1:0] outputs_o,
    output wire logic [NGPIO-1:0] t_o,
    input  wire logic [NGPIO-1:0] inputs_i
);
  wire gpio_busy;
  wire [TL_RS-1:0] working_source;
  wire [3:0] working_size;
  wire [31:0] working_data;
  wire [3:0] working_mask;
  wire [2:0] working_opcode;
  wire [4:0] working_address;
  wire working_valid;
  skdbf #(TL_RS + 4 + 39 + 5) skidbuffer (
      gpio_clock_i,
      gpio_reset_i,
      ~gpio_d_ready,
      {working_source, working_size, working_data, working_mask, working_opcode, working_address},
      working_valid,
      gpio_busy,
      {gpio_a_source, gpio_a_size, gpio_a_data, gpio_a_mask, gpio_a_opcode, gpio_a_address},
      gpio_a_valid
  );
  assign gpio_a_ready = ~gpio_busy;

  reg [NGPIO-1:0] outputs;
  initial outputs = 0;
  reg [NGPIO-1:0] t_state;
  initial t_state = {{NGPIO[5:0]} {1'b1}};
  always_ff @(posedge gpio_clock_i) begin
    if (gpio_reset_i) begin
      outputs <= 0;
    end
        else if (working_valid&gpio_d_ready&(working_address[4:2]==3'b001)&(working_opcode==3'd0||working_opcode==3'd1)) begin
      outputs <= working_data[NGPIO-1:0];
    end
  end
  always_ff @(posedge gpio_clock_i) begin
    if (gpio_reset_i) begin
      t_state <= {{NGPIO[5:0]} {1'b1}};
    end
        else if (working_valid&gpio_d_ready&(working_address[4:2]==3'b010)&(working_opcode==3'd0||working_opcode==3'd1)) begin
      t_state <= working_data[NGPIO-1:0];
    end
  end
  reg [NGPIO-1:0] inputs_x = 0;
  reg [NGPIO-1:0] inputs_y = 0;
  reg [NGPIO-1:0] inputs_edge = 0;
  reg [NGPIO-1:0] gen_fall_edge_interrupt = 0;
  reg [NGPIO-1:0] gen_fall_en = 0;
  reg [NGPIO-1:0] gen_rise_edge_interrupt = 0;
  reg [NGPIO-1:0] gen_rise_en = 0;
  always_ff @(posedge gpio_clock_i) begin
    {inputs_edge, inputs_y, inputs_x} <= {inputs_y, inputs_x, inputs_i};
  end
  generate
    if (fall_interrupts)
      always_ff @(posedge gpio_clock_i) begin
        for (integer i = 0; i < NGPIO; i++) begin
          if (!(working_valid&gpio_d_ready&(working_address[4:2]==3'b100)&&(working_opcode==3'd0||working_opcode==3'd1)&&gpio_a_data[i])) begin
            gen_fall_edge_interrupt[i] <= 0;
          end else if (gen_fall_en[i]) begin
            gen_fall_edge_interrupt[i] <= gen_fall_edge_interrupt[i]|(inputs_edge[i]&!inputs_y[i]);
          end else if (!gen_fall_en[i]) begin
            gen_fall_edge_interrupt <= 0;
          end
        end
        if (working_valid&gpio_d_ready&(working_address[4:2]==3'b100)&&(working_opcode==3'd0||working_opcode==3'd1)) begin
          gen_rise_en <= working_data[NGPIO-1:0];
        end
      end
  endgenerate
  generate
    if (rise_interrupts)
      always_ff @(posedge gpio_clock_i) begin
        for (integer i = 0; i < NGPIO; i++) begin
          if (!(working_valid&gpio_d_ready&(working_address[4:2]==3'b110)&&(working_opcode==3'd0||working_opcode==3'd1)&&gpio_a_data[i])) begin
            gen_rise_edge_interrupt[i] <= 0;
          end else if (gen_rise_en[i]) begin
            gen_rise_edge_interrupt[i] <= gen_rise_edge_interrupt[i]|(!inputs_edge[i]&inputs_y[i]);
          end else if (!gen_rise_en[i]) begin
            gen_rise_edge_interrupt <= 0;
          end
        end
        if (working_valid&gpio_d_ready&(working_address[4:2]==3'b110)&&(working_opcode==3'd0||working_opcode==3'd1)) begin
          gen_rise_en <= working_data[NGPIO-1:0];
        end
      end
  endgenerate
  always_ff @(posedge gpio_clock_i) begin
    if (gpio_reset_i) begin
      gpio_d_valid <= 0;
    end else if (working_valid & gpio_d_ready) begin
      gpio_d_valid <= 1;
      gpio_d_source <= working_source;
      gpio_d_size <= working_size;
      gpio_d_denied <= 0;
      gpio_d_corrupt <= 0;
      gpio_d_opcode <= 0;
      gpio_d_param <= 0;
      case (working_address[4:2])
        3'b000: begin
          gpio_d_data <= {{{6'd32 - NGPIO[5:0]} {1'b0}}, inputs_y};
        end
        3'b001: begin
          gpio_d_data <= {{{6'd32 - NGPIO[5:0]} {1'b0}}, outputs};
        end
        3'b010: begin
          gpio_d_data <= {{{6'd32 - NGPIO[5:0]} {1'b0}}, t_state};
        end
        3'b011: begin
          gpio_d_data <= {{{6'd32 - NGPIO[5:0]} {1'b0}}, t_state};
        end
        3'b100: begin
          gpio_d_data <= {{{6'd32 - NGPIO[5:0]} {1'b0}}, gen_fall_en};
        end
        3'b101: begin
          gpio_d_data <= {{{6'd32 - NGPIO[5:0]} {1'b0}}, gen_fall_edge_interrupt};
        end
        3'b110: begin
          gpio_d_data <= {{{6'd32 - NGPIO[5:0]} {1'b0}}, gen_rise_en};
        end
        3'b111: begin
          gpio_d_data <= {{{6'd32 - NGPIO[5:0]} {1'b0}}, gen_rise_edge_interrupt};
        end
      endcase
    end else if (!working_valid & gpio_d_ready) begin
      gpio_d_valid <= 0;
    end
  end

  assign outputs_o = outputs;
  assign t_o = t_state;
`ifdef FORMAL
  wire [TL_RS:0] outstanding;
  tlul_slave_formal #(
      .AW (1),
      .RS (TL_RS),
      .MAX(2)
  ) formal (
      gpio_clock_i,
      gpio_reset_i,
      gpio_a_opcode,
      gpio_a_param,
      gpio_a_size,
      gpio_a_source,
      gpio_a_address,
      gpio_a_mask,
      gpio_a_data,
      gpio_a_corrupt,
      gpio_a_valid,
      gpio_a_ready,
      gpio_d_opcode,
      gpio_d_param,
      gpio_d_size,
      gpio_d_source,
      gpio_d_denied,
      gpio_d_data,
      gpio_d_corrupt,
      gpio_d_valid,
      gpio_d_ready,
      outstanding
  );
`endif
endmodule
