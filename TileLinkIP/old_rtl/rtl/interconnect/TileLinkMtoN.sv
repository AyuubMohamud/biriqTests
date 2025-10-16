// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off WIDTHTRUNC */
module TileLinkMtoN #(
    parameter M = 2,
    parameter N = 2,
    parameter TL_DW = 32,
    parameter TL_AW = 32,
    parameter TL_RS = 4,
    parameter TL_SZ = 4,
    parameter [(TL_AW*N)-1:0] slave_addresses = {
        32'h00001000,
        32'h00002000
    }, //! Base addresses of mentioned slaves
    parameter [(TL_AW*N)-1:0] slave_end_addresses = {
        32'h00002000,
        32'h10000000
    }
) (
    input   wire logic                              tilelink_clock_i,
    input   wire logic                              tilelink_reset_i,

    input   wire logic [3*(M)-1:0]                  master_a_opcode,
    input   wire logic [3*(M)-1:0]                  master_a_param,
    input   wire logic [(M*TL_SZ)-1:0]              master_a_size,
    input   wire logic [(M*TL_RS)-1:0]              master_a_source,
    input   wire logic [(TL_AW*M)-1:0]              master_a_address,
    input   wire logic [(M*TL_DW/8)-1:0]            master_a_mask,
    input   wire logic [M*TL_DW-1:0]                master_a_data,
    input   wire logic [M-1:0]                      master_a_corrupt,
    input   wire logic [M-1:0]                      master_a_valid,
    output  wire logic [M-1:0]                      master_a_ready,

    output       logic [(M*3)-1:0]                  master_d_opcode,
    output       logic [(M*2)-1:0]                  master_d_param,
    output       logic [(M*TL_SZ)-1:0]              master_d_size,
    output       logic [(M*TL_RS)-1:0]              master_d_source,
    output       logic [M-1:0]                      master_d_denied,
    output       logic [M*TL_DW-1:0]                master_d_data,
    output       logic [M-1:0]                      master_d_corrupt,
    output       logic [M-1:0]                      master_d_valid,
    input   wire logic [M-1:0]                      master_d_ready,

    output       logic [3*(N)-1:0]                  slave_a_opcode,
    output       logic [3*(N)-1:0]                  slave_a_param,
    output       logic [(N*TL_SZ)-1:0]              slave_a_size,
    output       logic [(N*(TL_RS+$clog2(M)))-1:0]  slave_a_source,
    output       logic [(TL_AW*N)-1:0]              slave_a_address,
    output       logic [(N*TL_DW/8)-1:0]            slave_a_mask,
    output       logic [N*TL_DW-1:0]                slave_a_data,
    output       logic [N-1:0]                      slave_a_corrupt,
    output       logic [N-1:0]                      slave_a_valid,
    input   wire logic [N-1:0]                      slave_a_ready,

    input   wire logic [(N*3)-1:0]                  slave_d_opcode,
    input   wire logic [(N*2)-1:0]                  slave_d_param,
    input   wire logic [(N*TL_SZ)-1:0]              slave_d_size,
    input   wire logic [(N*(TL_RS+$clog2(M)))-1:0]  slave_d_source,
    input   wire logic [N-1:0]                      slave_d_denied,
    input   wire logic [N*TL_DW-1:0]                slave_d_data,
    input   wire logic [N-1:0]                      slave_d_corrupt,
    input   wire logic [N-1:0]                      slave_d_valid,
    output  wire logic [N-1:0]                      slave_d_ready
);
    wire [3*(N+1)-1:0]                  interconnect_slave_a_opcode [0:M-1];
    wire [3*(N+1)-1:0]                  interconnect_slave_a_param [0:M-1];
    wire [((N+1)*TL_SZ)-1:0]            interconnect_slave_a_size[0:M-1];
    wire [((N+1)*TL_RS)-1:0]            interconnect_slave_a_source[0:M-1];
    wire [(TL_AW*(N+1))-1:0]            interconnect_slave_a_address[0:M-1];
    wire [((N+1)*TL_DW/8)-1:0]          interconnect_slave_a_mask[0:M-1];
    wire [(N+1)*TL_DW-1:0]              interconnect_slave_a_data[0:M-1];
    wire [N:0]                          interconnect_slave_a_corrupt[0:M-1];
    wire [N:0]                          interconnect_slave_a_valid[0:M-1];
    wire [N:0]                          interconnect_slave_a_ready[0:M-1];
    wire [((N+1)*3)-1:0]                interconnect_slave_d_opcode[0:M-1];
    wire [((N+1)*2)-1:0]                interconnect_slave_d_param[0:M-1];
    wire [((N+1)*TL_SZ)-1:0]            interconnect_slave_d_size[0:M-1];
    wire [((N+1)*TL_RS)-1:0]            interconnect_slave_d_source[0:M-1];
    wire [N:0]                          interconnect_slave_d_denied[0:M-1];
    wire [(N+1)*TL_DW-1:0]              interconnect_slave_d_data[0:M-1];
    wire [N:0]                          interconnect_slave_d_corrupt[0:M-1];
    wire [N:0]                          interconnect_slave_d_valid[0:M-1];
    wire [N:0]                          interconnect_slave_d_ready[0:M-1];
    for (genvar i = 0; i < M; i++) begin : generate1toNLinks
        TileLink1toN #(N+1, slave_addresses, slave_end_addresses,
        TL_DW,TL_AW,TL_RS, TL_SZ) tilelink1toN (tilelink_clock_i, tilelink_reset_i,
            master_a_opcode[3*(i+1)-1:3*i], master_a_param[3*(i+1)-1:3*i], master_a_size[TL_SZ*(i+1)-1:TL_SZ*i],
            master_a_source[TL_RS*(i+1)-1:TL_RS*i], master_a_address[TL_AW*(i+1)-1:TL_AW*i], master_a_mask[(TL_DW/8)*(i+1)-1:(TL_DW/8)*i],
            master_a_data[TL_DW*(i+1)-1:TL_DW*i], master_a_corrupt[i], master_a_valid[i], master_a_ready[i], master_d_opcode[3*(i+1)-1:3*i], 
            master_d_param[2*(i+1)-1:2*i], master_d_size[TL_SZ*(i+1)-1:TL_SZ*i], master_d_source[TL_RS*(i+1)-1:TL_RS*i],
            master_d_denied[i], master_d_data[TL_DW*(i+1)-1:TL_DW*i], master_d_corrupt[i], master_d_valid[i], master_d_ready[i],
            interconnect_slave_a_opcode[i], interconnect_slave_a_param[i], interconnect_slave_a_size[i], interconnect_slave_a_source[i],
            interconnect_slave_a_address[i], interconnect_slave_a_mask[i], interconnect_slave_a_data[i], interconnect_slave_a_corrupt[i], interconnect_slave_a_valid[i], interconnect_slave_a_ready[i],
            interconnect_slave_d_opcode[i], interconnect_slave_d_param[i], interconnect_slave_d_size[i], interconnect_slave_d_source[i], interconnect_slave_d_denied[i], interconnect_slave_d_data[i],
            interconnect_slave_d_corrupt[i], interconnect_slave_d_valid[i], interconnect_slave_d_ready[i]);
    end

    // Now we have generated 1 to N links, we must transform them and turn them into M to 1 links
    wire [3*(M)-1:0]              interconnect_master_a_opcode [0:N];
    wire [3*(M)-1:0]              interconnect_master_a_param [0:N];
    wire [(M*TL_SZ)-1:0]          interconnect_master_a_size[0:N];
    wire [(M*TL_RS)-1:0]          interconnect_master_a_source[0:N];
    wire [(TL_AW*M)-1:0]          interconnect_master_a_address[0:N];
    wire [(M*TL_DW/8)-1:0]        interconnect_master_a_mask[0:N];
    wire [M*TL_DW-1:0]            interconnect_master_a_data[0:N];
    wire [M-1:0]                  interconnect_master_a_corrupt[0:N];
    wire [M-1:0]                  interconnect_master_a_valid[0:N];
    wire [M-1:0]                  interconnect_master_a_ready[0:N];
    wire [(M*3)-1:0]              interconnect_master_d_opcode[0:N];
    wire [(M*2)-1:0]              interconnect_master_d_param[0:N];
    wire [(M*TL_SZ)-1:0]          interconnect_master_d_size[0:N];
    wire [(M*TL_RS)-1:0]          interconnect_master_d_source[0:N];
    wire [M-1:0]                  interconnect_master_d_denied[0:N];
    wire [M*TL_DW-1:0]            interconnect_master_d_data[0:N];
    wire [M-1:0]                  interconnect_master_d_corrupt[0:N];
    wire [M-1:0]                  interconnect_master_d_valid[0:N];
    wire [M-1:0]                  interconnect_master_d_ready[0:N];
    for (genvar x = 0; x < M; x++) begin : transform_x
        for (genvar y = 0; y < N+1; y++) begin : tranform_y
            assign interconnect_master_a_opcode[y][3*(x+1)-1:x*3] = interconnect_slave_a_opcode[x][3*(y+1)-1:y*3];
            assign interconnect_master_a_param[y][3*(x+1)-1:x*3] = interconnect_slave_a_param[x][3*(y+1)-1:y*3];
            assign interconnect_master_a_size[y][TL_SZ*(x+1)-1:x*TL_SZ] = interconnect_slave_a_size[x][TL_SZ*(y+1)-1:y*TL_SZ];
            assign interconnect_master_a_source[y][TL_RS*(x+1)-1:x*TL_RS] = interconnect_slave_a_source[x][TL_RS*(y+1)-1:y*TL_RS];
            assign interconnect_master_a_address[y][TL_AW*(x+1)-1:x*TL_AW] = interconnect_slave_a_address[x][TL_AW*(y+1)-1:y*TL_AW];
            assign interconnect_master_a_mask[y][(TL_DW/8)*(x+1)-1:(TL_DW/8)*x] = interconnect_slave_a_mask[x][(TL_DW/8)*(y+1)-1:(TL_DW/8)*y];
            assign interconnect_master_a_data[y][(TL_DW)*(x+1)-1:(TL_DW)*x] = interconnect_slave_a_data[x][(TL_DW)*(y+1)-1:(TL_DW)*y];
            assign interconnect_master_a_corrupt[y][x] = interconnect_slave_a_corrupt[x][y];
            assign interconnect_master_a_valid[y][x] = interconnect_slave_a_valid[x][y];
            assign interconnect_slave_a_ready[x][y] = interconnect_master_a_ready[y][x];
            assign interconnect_slave_d_corrupt[x][y] = interconnect_master_d_corrupt[y][x];
            assign interconnect_slave_d_data[x][(TL_DW)*(y+1)-1:(TL_DW)*y] = interconnect_master_d_data[y][(TL_DW)*(x+1)-1:(TL_DW)*x];
            assign interconnect_slave_d_denied[x][y] = interconnect_master_d_denied[y][x];
            assign interconnect_slave_d_opcode[x][3*(y+1)-1:y*3] = interconnect_master_d_opcode[y][3*(x+1)-1:x*3];
            assign interconnect_slave_d_param[x][2*(y+1)-1:y*2] = interconnect_master_d_param[y][2*(x+1)-1:x*2];
            assign interconnect_slave_d_size[x][TL_SZ*(y+1)-1:y*TL_SZ] = interconnect_master_d_size[y][TL_SZ*(x+1)-1:x*TL_SZ];
            assign interconnect_slave_d_source[x][TL_RS*(y+1)-1:y*TL_RS] = interconnect_master_d_source[y][TL_RS*(x+1)-1:x*TL_RS];
            assign interconnect_slave_d_valid[x][y] = interconnect_master_d_valid[y][x];
            assign interconnect_master_d_ready[y][x] = interconnect_slave_d_ready[x][y];
        end
    end
    for (genvar i = 0; i < N; i++) begin : generateMto1Links
        TileLinkMto1 #(M, TL_DW, TL_AW, TL_RS, TL_SZ) tilelinkMto1 (
            tilelink_clock_i, tilelink_reset_i, 
            interconnect_master_a_opcode[i],
            interconnect_master_a_param[i],
            interconnect_master_a_size[i],
            interconnect_master_a_source[i],
            interconnect_master_a_address[i],
            interconnect_master_a_mask[i],
            interconnect_master_a_data[i],
            interconnect_master_a_corrupt[i],
            interconnect_master_a_valid[i],
            interconnect_master_a_ready[i],
            interconnect_master_d_opcode[i],
            interconnect_master_d_param[i],
            interconnect_master_d_size[i],
            interconnect_master_d_source[i],
            interconnect_master_d_denied[i],
            interconnect_master_d_data[i],
            interconnect_master_d_corrupt[i],
            interconnect_master_d_valid[i],
            interconnect_master_d_ready[i],
            slave_a_opcode[3*(i+1)-1:3*i], slave_a_param[3*(i+1)-1:3*i], slave_a_size[TL_SZ*(i+1)-1:TL_SZ*i],
            slave_a_source[($clog2(M)+TL_RS)*(i+1)-1:($clog2(M)+TL_RS)*i], slave_a_address[TL_AW*(i+1)-1:TL_AW*i], slave_a_mask[(TL_DW/8)*(i+1)-1:(TL_DW/8)*i],
            slave_a_data[TL_DW*(i+1)-1:TL_DW*i], slave_a_corrupt[i], slave_a_valid[i], slave_a_ready[i], slave_d_opcode[3*(i+1)-1:3*i], 
            slave_d_param[2*(i+1)-1:2*i], slave_d_size[TL_SZ*(i+1)-1:TL_SZ*i], slave_d_source[($clog2(M)+TL_RS)*(i+1)-1:($clog2(M)+TL_RS)*i],
            slave_d_denied[i], slave_d_data[TL_DW*(i+1)-1:TL_DW*i], slave_d_corrupt[i], slave_d_valid[i], slave_d_ready[i]
        );
    end
    TileLinkMto1 #(M, TL_DW, TL_AW, TL_RS, TL_SZ) denialMto1 (
        tilelink_clock_i, tilelink_reset_i, 
        interconnect_master_a_opcode[N],
        interconnect_master_a_param[N],
        interconnect_master_a_size[N],
        interconnect_master_a_source[N],
        interconnect_master_a_address[N],
        interconnect_master_a_mask[N],
        interconnect_master_a_data[N],
        interconnect_master_a_corrupt[N],
        interconnect_master_a_valid[N],
        interconnect_master_a_ready[N],
        interconnect_master_d_opcode[N],
        interconnect_master_d_param[N],
        interconnect_master_d_size[N],
        interconnect_master_d_source[N],
        interconnect_master_d_denied[N],
        interconnect_master_d_data[N],
        interconnect_master_d_corrupt[N],
        interconnect_master_d_valid[N],
        interconnect_master_d_ready[N],
        denial_a_opcode, denial_a_param, denial_a_size, denial_a_source, denial_a_address, denial_a_mask, denial_a_data, denial_a_corrupt,
        denial_a_valid, denial_a_ready, denial_d_opcode, denial_d_param, denial_d_size, denial_d_source, denial_d_denied, denial_d_data, denial_d_corrupt, denial_d_valid,
        denial_d_ready 
    );
    wire logic [2:0]                    denial_a_opcode;
    wire logic [2:0]                    denial_a_param;
    wire logic [3:0]                    denial_a_size;
    wire logic [(TL_RS+$clog2(M))-1:0]  denial_a_source;
    wire logic [TL_AW-1:0]              denial_a_address;
    wire logic [(TL_DW/8) - 1:0]        denial_a_mask;
    wire logic [TL_DW-1:0]              denial_a_data;
    wire logic                          denial_a_corrupt;
    wire logic                          denial_a_valid;
    wire logic                          denial_a_ready;
    wire logic [2:0]                    denial_d_opcode;
    wire logic [1:0]                    denial_d_param;
    wire logic [3:0]                    denial_d_size;
    wire logic [(TL_RS+$clog2(M))-1:0]  denial_d_source;
    wire logic                          denial_d_denied;
    wire logic [TL_DW-1:0]              denial_d_data;
    wire logic                          denial_d_corrupt;
    wire logic                          denial_d_valid;
    wire logic                          denial_d_ready;
    denial #(((TL_RS+$clog2(M))), TL_AW, TL_DW) denial0 (
        tilelink_clock_i, tilelink_reset_i, denial_a_opcode, denial_a_param, denial_a_size, denial_a_source, denial_a_address, denial_a_mask, denial_a_data, denial_a_corrupt,
        denial_a_valid, denial_a_ready, denial_d_opcode, denial_d_param, denial_d_size, denial_d_source, denial_d_denied, denial_d_data, denial_d_corrupt, denial_d_valid,
        denial_d_ready 
    );
endmodule
