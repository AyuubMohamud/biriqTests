// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
`define LT 0
`define MT 1
`define ME 2
`define LE 3
module fifo_sync #(
    parameter FW = 32,
    parameter DW = 32,
    parameter MD = `LT,
    parameter SYNC_RD = 1,
    localparam WT_W = $clog2(FW)-1
) (
    input   wire logic          clk_i,
    input   wire logic          reset_i,

    // Write channel
    input   wire logic          wr_en_i,
    input   wire logic [DW-1:0] wr_data_i,
    output  wire logic          full_o,

    // Read side
    input   wire logic          rd_i,
    output  logic      [DW-1:0] rd_data_o,
    output  wire logic          empty_o,
    // Error logic
    output  logic               underflow_o,
    output  logic               overflow_o,

    input   wire logic [WT_W:0] threshold_i,
    output  wire logic          threshold_o
);

    reg [DW-1:0] fifo [0:FW-1];
    reg [$clog2(FW):0] read_ptr;
    reg [$clog2(FW):0] write_ptr;

    initial begin
        for (integer i = 0; i < FW; i = i + 1) begin
            fifo[i] = 0;
        end
        write_ptr = 0;
        read_ptr = 0;
        underflow_o = 0;
        overflow_o = 0;
    end
    assign empty_o = (read_ptr == write_ptr);
    assign full_o = (write_ptr[$clog2(FW)] != read_ptr[$clog2(FW)]) & (read_ptr[$clog2(FW)-1:0] == write_ptr[$clog2(FW)-1:0]);
    
    // Logic to handle the pointers
    always_ff @(posedge clk_i) begin
        if (reset_i) begin
            read_ptr <= 0;
            write_ptr <= 0;
        end
        if (~reset_i & wr_en_i & ~full_o) begin
            write_ptr <= write_ptr + 1;
        end
        if (~reset_i & rd_i & ~empty_o) begin
            read_ptr <= read_ptr + 1;
        end
    end
    // Logic to handle memories
    always_ff @(posedge clk_i) begin
        if (~reset_i & wr_en_i & ~full_o) begin
            fifo[write_ptr[$clog2(FW)-1:0]] <= wr_data_i;
        end
        underflow_o <= empty_o & rd_i;
        overflow_o <= full_o & wr_en_i;
    end
    
    generate if (SYNC_RD) begin : __sfifo_if_synchronous_reads
        always_ff @(posedge clk_i) begin
            rd_data_o <= fifo[read_ptr[$clog2(FW)-1:0]];
        end
    end else begin : __sfifo_if_synchronous_reads
        assign rd_data_o = fifo[read_ptr[$clog2(FW)-1:0]];
    end endgenerate

    generate if (MD==`LT) begin : __sfifo_gen_lt
        assign threshold_o = (write_ptr[$clog2(FW)-1:0]-read_ptr[$clog2(FW)-1:0]) < threshold_i;
    end else if (MD==`MT) begin : __sfifo_gen_mt
        assign threshold_o = (write_ptr[$clog2(FW)-1:0]-read_ptr[$clog2(FW)-1:0]) > threshold_i;
    end else if (MD==`LE) begin : __sfifo_gen_le
        assign threshold_o = (write_ptr[$clog2(FW)-1:0]-read_ptr[$clog2(FW)-1:0]) <= threshold_i;
    end else if (MD==`ME) begin : __sfifo_gen_me
        assign threshold_o = (write_ptr[$clog2(FW)-1:0]-read_ptr[$clog2(FW)-1:0]) >= threshold_i;
    end endgenerate

`ifdef FORMAL

    reg p_valid;
    initial p_valid = 0;
    initial assume(!wr_en_i);
    initial assume(!rd_i);
    initial assume(!reset_i);
    initial assume(write_ptr == 0);
    initial assume(read_ptr == 0);

    always @* begin
        assert(empty_o == (write_ptr-read_ptr == 0));
        assert(full_o == ((write_ptr[$clog2(FW)] != read_ptr[$clog2(FW)]) & (read_ptr[$clog2(FW)-1:0] == write_ptr[$clog2(FW)-1:0]))); 
    end

    generate if (MD==`LT) begin : __gen_lt
        always @* begin
            assert(threshold_o == ((write_ptr[$clog2(FW)-1:0] - read_ptr[$clog2(FW)-1:0]) < threshold_i));
        end
    end else if (MD==`MT) begin : __gen_mt
        always @* begin
            assert(threshold_o == ((write_ptr[$clog2(FW)-1:0] - read_ptr[$clog2(FW)-1:0]) > threshold_i));
        end
    end else if (MD==`LE) begin : __gen_le
        always @* begin
            assert(threshold_o == ((write_ptr[$clog2(FW)-1:0] - read_ptr[$clog2(FW)-1:0]) >= threshold_i));
        end
    end else if (MD==`ME) begin : __gen_me
        always @* begin
            assert(threshold_o == ((write_ptr[$clog2(FW)-1:0] - read_ptr[$clog2(FW)-1:0]) >= threshold_i));
        end
    end endgenerate

    

    always @(posedge clk_i) begin
        p_valid <= 1;
    end

    always @(posedge clk_i) begin
        if ($past(wr_en_i) & $past(!reset_i) & $past(full_o) & p_valid) begin
            assert(overflow_o);
        end
        if ($past(rd_i) & $past(empty_o) & $past(!reset_i) & p_valid) begin
            assert(underflow_o);
        end
    end

    always @(posedge clk_i) begin
        if ($past(!reset_i) & $past(~full_o) & $past(wr_en_i) & p_valid) begin
            assert(write_ptr == ($past(write_ptr) + 1'b1));
        end
        if ($past(!reset_i) & $past(~empty_o) & $past(rd_i) & p_valid) begin
            assert(read_ptr == ($past(read_ptr) + 1'b1));
        end
        if ($past(!reset_i) & $past(full_o) & p_valid) begin
            assert($stable(write_ptr));
        end
        if ($past(!reset_i) & $past(empty_o) & p_valid) begin
            assert($stable(read_ptr));
        end
    end

    always @(posedge clk_i) begin
        if ($past(!reset_i) & ~($past(full_o)) & $past(wr_en_i) & p_valid) begin
            assert(fifo[$past(write_ptr[$clog2(FW)-1:0])] == $past(wr_data_i));
        end
    end
    generate if (SYNC_RD) begin : __test_sync
        always @(posedge clk_i) begin
            if ($past(!reset_i) & $past(~empty_o) & $past(rd_i) & p_valid) begin
                assert(rd_data_o == fifo[$past(read_ptr[$clog2(FW)-1:0])]);
            end
        end
    end else begin : __test_async
        always_comb begin
            assert(rd_data_o == fifo[read_ptr[$clog2(FW)-1:0]]);
        end
    end endgenerate

`endif
endmodule
