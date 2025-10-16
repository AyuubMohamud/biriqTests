module openPolarisSPIFlash #(
    parameter TL_RS = 3
) (
    input wire logic flash_clock_i,
    input wire logic flash_reset_i,

    input  wire logic [      3:0] flash_a_size,
    input  wire logic [TL_RS-1:0] flash_a_source,
    input  wire logic [     23:0] flash_a_address,
    input  wire logic             flash_a_valid,
    output wire logic             flash_a_ready,

    output logic      [      2:0] flash_d_opcode,
    output logic      [      3:0] flash_d_size,
    output logic      [TL_RS-1:0] flash_d_source,
    output logic                  flash_d_denied,
    output logic      [     31:0] flash_d_data,
    output logic                  flash_d_corrupt,
    output logic                  flash_d_valid,
    input  wire logic             flash_d_ready,

    output logic      flash_cs_n,
    output logic      flash_mosi,
    input  wire logic flash_miso,
    output logic      flash_sck
);
  initial flash_cs_n = 1;
  initial flash_sck = 0;
  initial flash_mosi = 0;
  wire flash_busy;
  reg taking_request = 0;
  reg [TL_RS-1:0] saved_source = 0;
  reg [3:0] saved_size = 0;
  wire [TL_RS-1:0] working_source;
  wire [3:0] working_size;
  wire [23:0] working_address;
  wire working_valid;
  skdbf #(TL_RS + 28) skidbuffer (
      flash_clock_i,
      flash_reset_i,
      ~flash_d_ready | taking_request,
      {working_source, working_size, working_address},
      working_valid,
      flash_busy,
      {flash_a_source, flash_a_size, flash_a_address},
      flash_a_valid
  );
  assign flash_a_ready = ~flash_busy;

  wire tx, enqueue, busy;
  wire [31:0] data;
  flashphy genericFlash (
      flash_clock_i,
      tx,
      working_address,
      working_size,
      busy,
      enqueue,
      data,
      flash_cs_n,
      flash_mosi,
      flash_miso,
      flash_sck
  );
  assign tx = working_valid & !busy & !taking_request;
  wire full, read, empty;
  wire [31:0] fifo_data;
  wire underflow, overflow;
  assign read = !empty & flash_d_ready;
  sfifo #(
      .FW(128),
      .DW(32)
  ) flashfifo (
      flash_clock_i,
      flash_reset_i,
      enqueue,
      data,
      full,
      read,
      fifo_data,
      empty,
      underflow,
      overflow
  );
  always_ff @(posedge flash_clock_i) begin
    taking_request <= taking_request ? !(empty & !busy) : working_valid & !busy;
    if (working_valid & !taking_request) begin
      saved_size   <= working_size;
      saved_source <= working_source;
    end
  end
  always_ff @(posedge flash_clock_i) begin
    if (flash_reset_i) begin
      flash_d_valid <= 0;
    end else if (!empty & flash_d_ready) begin
      flash_d_valid <= 1;
      flash_d_size <= saved_size;
      flash_d_source <= saved_source;
      flash_d_data <= fifo_data;
      flash_d_corrupt <= 0;
      flash_d_opcode <= 1;
      flash_d_denied <= 0;
    end else if (empty & flash_d_ready) begin
      flash_d_valid <= 0;
    end
  end

endmodule
