// Copyright (C) Ayuub Mohamud, 2024
// Licensed under CERN-OHL-P version 2
/* verilator lint_off WIDTHEXPAND */
/* verilator lint_off WIDTHTRUNC */
module TileLinkMtoNUH #(
    parameter  C_ARBITRATION_SCHEME  = 1,
    parameter  C_NUM_MASTERS         = 2,
    parameter  C_NUM_SLAVES         = 2,
    parameter  C_TILELINK_DATA_WIDTH = 32,
    parameter  C_TILELINK_ADDR_WIDTH = 32,
    parameter  C_TILELINK_ID_WIDTH   = 4,
    parameter [(C_TILELINK_ADDR_WIDTH*(C_NUM_SLAVES))-1:0] C_SLAVE_ADDRESSES = {
      32'h00001000
    },  //! Base addresses of mentioned slaves
    parameter [(C_TILELINK_ADDR_WIDTH*(C_NUM_SLAVES))-1:0] C_SLAVE_MASKS = {32'h00002000}
) (
    input   wire logic                              tilelink_clock_i,
    input   wire logic                              tilelink_reset_i,

    input   wire logic [3*(C_NUM_MASTERS)-1:0]                  master_a_opcode,
    input   wire logic [3*(C_NUM_MASTERS)-1:0]                  master_a_param,
    input   wire logic [(C_NUM_MASTERS*3)-1:0]              master_a_size,
    input   wire logic [(C_NUM_MASTERS*C_TILELINK_ID_WIDTH)-1:0]              master_a_source,
    input   wire logic [(C_TILELINK_ADDR_WIDTH*C_NUM_MASTERS)-1:0]              master_a_address,
    input   wire logic [(C_NUM_MASTERS*C_TILELINK_DATA_WIDTH/8)-1:0]            master_a_mask,
    input   wire logic [C_NUM_MASTERS*C_TILELINK_DATA_WIDTH-1:0]                master_a_data,
    input   wire logic [C_NUM_MASTERS-1:0]                      master_a_corrupt,
    input   wire logic [C_NUM_MASTERS-1:0]                      master_a_valid,
    output  wire logic [C_NUM_MASTERS-1:0]                      master_a_ready,

    output       logic [(C_NUM_MASTERS*3)-1:0]                  master_d_opcode,
    output       logic [(C_NUM_MASTERS*2)-1:0]                  master_d_param,
    output       logic [(C_NUM_MASTERS*3)-1:0]              master_d_size,
    output       logic [(C_NUM_MASTERS*C_TILELINK_ID_WIDTH)-1:0]              master_d_source,
    output       logic [C_NUM_MASTERS-1:0]                      master_d_denied,
    output       logic [C_NUM_MASTERS*C_TILELINK_DATA_WIDTH-1:0]                master_d_data,
    output       logic [C_NUM_MASTERS-1:0]                      master_d_corrupt,
    output       logic [C_NUM_MASTERS-1:0]                      master_d_valid,
    input   wire logic [C_NUM_MASTERS-1:0]                      master_d_ready,

    output       logic [3*(C_NUM_SLAVES)-1:0]                  slave_a_opcode,
    output       logic [3*(C_NUM_SLAVES)-1:0]                  slave_a_param,
    output       logic [(C_NUM_SLAVES*3)-1:0]              slave_a_size,
    output       logic [(C_NUM_SLAVES*(C_TILELINK_ID_WIDTH+$clog2(C_NUM_MASTERS)))-1:0]  slave_a_source,
    output       logic [(C_TILELINK_ADDR_WIDTH*C_NUM_SLAVES)-1:0]              slave_a_address,
    output       logic [(C_NUM_SLAVES*C_TILELINK_DATA_WIDTH/8)-1:0]            slave_a_mask,
    output       logic [C_NUM_SLAVES*C_TILELINK_DATA_WIDTH-1:0]                slave_a_data,
    output       logic [C_NUM_SLAVES-1:0]                      slave_a_corrupt,
    output       logic [C_NUM_SLAVES-1:0]                      slave_a_valid,
    input   wire logic [C_NUM_SLAVES-1:0]                      slave_a_ready,

    input   wire logic [(C_NUM_SLAVES*3)-1:0]                  slave_d_opcode,
    input   wire logic [(C_NUM_SLAVES*2)-1:0]                  slave_d_param,
    input   wire logic [(C_NUM_SLAVES*3)-1:0]              slave_d_size,
    input   wire logic [(C_NUM_SLAVES*(C_TILELINK_ID_WIDTH+$clog2(C_NUM_MASTERS)))-1:0]  slave_d_source,
    input   wire logic [C_NUM_SLAVES-1:0]                      slave_d_denied,
    input   wire logic [C_NUM_SLAVES*C_TILELINK_DATA_WIDTH-1:0]                slave_d_data,
    input   wire logic [C_NUM_SLAVES-1:0]                      slave_d_corrupt,
    input   wire logic [C_NUM_SLAVES-1:0]                      slave_d_valid,
    output  wire logic [C_NUM_SLAVES-1:0]                      slave_d_ready
);
    wire [3*(C_NUM_SLAVES+1)-1:0]                  interconnect_slave_a_opcode [0:C_NUM_MASTERS-1];
    wire [3*(C_NUM_SLAVES+1)-1:0]                  interconnect_slave_a_param [0:C_NUM_MASTERS-1];
    wire [((C_NUM_SLAVES+1)*3)-1:0]            interconnect_slave_a_size[0:C_NUM_MASTERS-1];
    wire [((C_NUM_SLAVES+1)*C_TILELINK_ID_WIDTH)-1:0]            interconnect_slave_a_source[0:C_NUM_MASTERS-1];
    wire [(C_TILELINK_ADDR_WIDTH*(C_NUM_SLAVES+1))-1:0]            interconnect_slave_a_address[0:C_NUM_MASTERS-1];
    wire [((C_NUM_SLAVES+1)*C_TILELINK_DATA_WIDTH/8)-1:0]          interconnect_slave_a_mask[0:C_NUM_MASTERS-1];
    wire [(C_NUM_SLAVES+1)*C_TILELINK_DATA_WIDTH-1:0]              interconnect_slave_a_data[0:C_NUM_MASTERS-1];
    wire [C_NUM_SLAVES:0]                          interconnect_slave_a_corrupt[0:C_NUM_MASTERS-1];
    wire [C_NUM_SLAVES:0]                          interconnect_slave_a_valid[0:C_NUM_MASTERS-1];
    wire [C_NUM_SLAVES:0]                          interconnect_slave_a_ready[0:C_NUM_MASTERS-1];
    wire [((C_NUM_SLAVES+1)*3)-1:0]                interconnect_slave_d_opcode[0:C_NUM_MASTERS-1];
    wire [((C_NUM_SLAVES+1)*2)-1:0]                interconnect_slave_d_param[0:C_NUM_MASTERS-1];
    wire [((C_NUM_SLAVES+1)*3)-1:0]            interconnect_slave_d_size[0:C_NUM_MASTERS-1];
    wire [((C_NUM_SLAVES+1)*C_TILELINK_ID_WIDTH)-1:0]            interconnect_slave_d_source[0:C_NUM_MASTERS-1];
    wire [C_NUM_SLAVES:0]                          interconnect_slave_d_denied[0:C_NUM_MASTERS-1];
    wire [(C_NUM_SLAVES+1)*C_TILELINK_DATA_WIDTH-1:0]              interconnect_slave_d_data[0:C_NUM_MASTERS-1];
    wire [C_NUM_SLAVES:0]                          interconnect_slave_d_corrupt[0:C_NUM_MASTERS-1];
    wire [C_NUM_SLAVES:0]                          interconnect_slave_d_valid[0:C_NUM_MASTERS-1];
    wire [C_NUM_SLAVES:0]                          interconnect_slave_d_ready[0:C_NUM_MASTERS-1];
    for (genvar i = 0; i < C_NUM_MASTERS; i++) begin : generate1toNLinks
        TileLink1toNUH #(C_ARBITRATION_SCHEME, C_NUM_SLAVES+1,
        C_TILELINK_DATA_WIDTH,C_TILELINK_ADDR_WIDTH,C_TILELINK_ID_WIDTH,C_SLAVE_ADDRESSES, C_SLAVE_MASKS) tilelink1toN (tilelink_clock_i, tilelink_reset_i,
            master_a_opcode[3*(i+1)-1:3*i], master_a_param[3*(i+1)-1:3*i], master_a_size[3*(i+1)-1:3*i],
            master_a_source[C_TILELINK_ID_WIDTH*(i+1)-1:C_TILELINK_ID_WIDTH*i], master_a_address[C_TILELINK_ADDR_WIDTH*(i+1)-1:C_TILELINK_ADDR_WIDTH*i], master_a_mask[(C_TILELINK_DATA_WIDTH/8)*(i+1)-1:(C_TILELINK_DATA_WIDTH/8)*i],
            master_a_data[C_TILELINK_DATA_WIDTH*(i+1)-1:C_TILELINK_DATA_WIDTH*i], master_a_corrupt[i], master_a_valid[i], master_a_ready[i], master_d_opcode[3*(i+1)-1:3*i], 
            master_d_param[2*(i+1)-1:2*i], master_d_size[3*(i+1)-1:3*i], master_d_source[C_TILELINK_ID_WIDTH*(i+1)-1:C_TILELINK_ID_WIDTH*i],
            master_d_denied[i], master_d_data[C_TILELINK_DATA_WIDTH*(i+1)-1:C_TILELINK_DATA_WIDTH*i], master_d_corrupt[i], master_d_valid[i], master_d_ready[i],
            interconnect_slave_a_opcode[i], interconnect_slave_a_param[i], interconnect_slave_a_size[i], interconnect_slave_a_source[i],
            interconnect_slave_a_address[i], interconnect_slave_a_mask[i], interconnect_slave_a_data[i], interconnect_slave_a_corrupt[i], interconnect_slave_a_valid[i], interconnect_slave_a_ready[i],
            interconnect_slave_d_opcode[i], interconnect_slave_d_param[i], interconnect_slave_d_size[i], interconnect_slave_d_source[i], interconnect_slave_d_denied[i], interconnect_slave_d_data[i],
            interconnect_slave_d_corrupt[i], interconnect_slave_d_valid[i], interconnect_slave_d_ready[i]);
    end

    // Now we have generated 1 to C_NUM_SLAVES links, we must transform them and turn them into C_NUM_MASTERS to 1 links
    wire [3*(C_NUM_MASTERS)-1:0]              interconnect_master_a_opcode [0:C_NUM_SLAVES];
    wire [3*(C_NUM_MASTERS)-1:0]              interconnect_master_a_param [0:C_NUM_SLAVES];
    wire [(C_NUM_MASTERS*3)-1:0]          interconnect_master_a_size[0:C_NUM_SLAVES];
    wire [(C_NUM_MASTERS*C_TILELINK_ID_WIDTH)-1:0]          interconnect_master_a_source[0:C_NUM_SLAVES];
    wire [(C_TILELINK_ADDR_WIDTH*C_NUM_MASTERS)-1:0]          interconnect_master_a_address[0:C_NUM_SLAVES];
    wire [(C_NUM_MASTERS*C_TILELINK_DATA_WIDTH/8)-1:0]        interconnect_master_a_mask[0:C_NUM_SLAVES];
    wire [C_NUM_MASTERS*C_TILELINK_DATA_WIDTH-1:0]            interconnect_master_a_data[0:C_NUM_SLAVES];
    wire [C_NUM_MASTERS-1:0]                  interconnect_master_a_corrupt[0:C_NUM_SLAVES];
    wire [C_NUM_MASTERS-1:0]                  interconnect_master_a_valid[0:C_NUM_SLAVES];
    wire [C_NUM_MASTERS-1:0]                  interconnect_master_a_ready[0:C_NUM_SLAVES];
    wire [(C_NUM_MASTERS*3)-1:0]              interconnect_master_d_opcode[0:C_NUM_SLAVES];
    wire [(C_NUM_MASTERS*2)-1:0]              interconnect_master_d_param[0:C_NUM_SLAVES];
    wire [(C_NUM_MASTERS*3)-1:0]          interconnect_master_d_size[0:C_NUM_SLAVES];
    wire [(C_NUM_MASTERS*C_TILELINK_ID_WIDTH)-1:0]          interconnect_master_d_source[0:C_NUM_SLAVES];
    wire [C_NUM_MASTERS-1:0]                  interconnect_master_d_denied[0:C_NUM_SLAVES];
    wire [C_NUM_MASTERS*C_TILELINK_DATA_WIDTH-1:0]            interconnect_master_d_data[0:C_NUM_SLAVES];
    wire [C_NUM_MASTERS-1:0]                  interconnect_master_d_corrupt[0:C_NUM_SLAVES];
    wire [C_NUM_MASTERS-1:0]                  interconnect_master_d_valid[0:C_NUM_SLAVES];
    wire [C_NUM_MASTERS-1:0]                  interconnect_master_d_ready[0:C_NUM_SLAVES];
    for (genvar x = 0; x < C_NUM_MASTERS; x++) begin : transform_x
        for (genvar y = 0; y < C_NUM_SLAVES+1; y++) begin : tranform_y
            assign interconnect_master_a_opcode[y][3*(x+1)-1:x*3] = interconnect_slave_a_opcode[x][3*(y+1)-1:y*3];
            assign interconnect_master_a_param[y][3*(x+1)-1:x*3] = interconnect_slave_a_param[x][3*(y+1)-1:y*3];
            assign interconnect_master_a_size[y][3*(x+1)-1:x*3] = interconnect_slave_a_size[x][3*(y+1)-1:y*3];
            assign interconnect_master_a_source[y][C_TILELINK_ID_WIDTH*(x+1)-1:x*C_TILELINK_ID_WIDTH] = interconnect_slave_a_source[x][C_TILELINK_ID_WIDTH*(y+1)-1:y*C_TILELINK_ID_WIDTH];
            assign interconnect_master_a_address[y][C_TILELINK_ADDR_WIDTH*(x+1)-1:x*C_TILELINK_ADDR_WIDTH] = interconnect_slave_a_address[x][C_TILELINK_ADDR_WIDTH*(y+1)-1:y*C_TILELINK_ADDR_WIDTH];
            assign interconnect_master_a_mask[y][(C_TILELINK_DATA_WIDTH/8)*(x+1)-1:(C_TILELINK_DATA_WIDTH/8)*x] = interconnect_slave_a_mask[x][(C_TILELINK_DATA_WIDTH/8)*(y+1)-1:(C_TILELINK_DATA_WIDTH/8)*y];
            assign interconnect_master_a_data[y][(C_TILELINK_DATA_WIDTH)*(x+1)-1:(C_TILELINK_DATA_WIDTH)*x] = interconnect_slave_a_data[x][(C_TILELINK_DATA_WIDTH)*(y+1)-1:(C_TILELINK_DATA_WIDTH)*y];
            assign interconnect_master_a_corrupt[y][x] = interconnect_slave_a_corrupt[x][y];
            assign interconnect_master_a_valid[y][x] = interconnect_slave_a_valid[x][y];
            assign interconnect_slave_a_ready[x][y] = interconnect_master_a_ready[y][x];
            assign interconnect_slave_d_corrupt[x][y] = interconnect_master_d_corrupt[y][x];
            assign interconnect_slave_d_data[x][(C_TILELINK_DATA_WIDTH)*(y+1)-1:(C_TILELINK_DATA_WIDTH)*y] = interconnect_master_d_data[y][(C_TILELINK_DATA_WIDTH)*(x+1)-1:(C_TILELINK_DATA_WIDTH)*x];
            assign interconnect_slave_d_denied[x][y] = interconnect_master_d_denied[y][x];
            assign interconnect_slave_d_opcode[x][3*(y+1)-1:y*3] = interconnect_master_d_opcode[y][3*(x+1)-1:x*3];
            assign interconnect_slave_d_param[x][2*(y+1)-1:y*2] = interconnect_master_d_param[y][2*(x+1)-1:x*2];
            assign interconnect_slave_d_size[x][3*(y+1)-1:y*3] = interconnect_master_d_size[y][3*(x+1)-1:x*3];
            assign interconnect_slave_d_source[x][C_TILELINK_ID_WIDTH*(y+1)-1:y*C_TILELINK_ID_WIDTH] = interconnect_master_d_source[y][C_TILELINK_ID_WIDTH*(x+1)-1:x*C_TILELINK_ID_WIDTH];
            assign interconnect_slave_d_valid[x][y] = interconnect_master_d_valid[y][x];
            assign interconnect_master_d_ready[y][x] = interconnect_slave_d_ready[x][y];
        end
    end
    for (genvar i = 0; i < C_NUM_SLAVES; i++) begin : generateMto1Links
        TileLinkMto1UH #(C_ARBITRATION_SCHEME, C_NUM_MASTERS, C_TILELINK_DATA_WIDTH, C_TILELINK_ADDR_WIDTH, C_TILELINK_ID_WIDTH) tilelinkMto1 (
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
            slave_a_opcode[3*(i+1)-1:3*i], slave_a_param[3*(i+1)-1:3*i], slave_a_size[3*(i+1)-1:3*i],
            slave_a_source[($clog2(C_NUM_MASTERS)+C_TILELINK_ID_WIDTH)*(i+1)-1:($clog2(C_NUM_MASTERS)+C_TILELINK_ID_WIDTH)*i], slave_a_address[C_TILELINK_ADDR_WIDTH*(i+1)-1:C_TILELINK_ADDR_WIDTH*i], slave_a_mask[(C_TILELINK_DATA_WIDTH/8)*(i+1)-1:(C_TILELINK_DATA_WIDTH/8)*i],
            slave_a_data[C_TILELINK_DATA_WIDTH*(i+1)-1:C_TILELINK_DATA_WIDTH*i], slave_a_corrupt[i], slave_a_valid[i], slave_a_ready[i], slave_d_opcode[3*(i+1)-1:3*i], 
            slave_d_param[2*(i+1)-1:2*i], slave_d_size[3*(i+1)-1:3*i], slave_d_source[($clog2(C_NUM_MASTERS)+C_TILELINK_ID_WIDTH)*(i+1)-1:($clog2(C_NUM_MASTERS)+C_TILELINK_ID_WIDTH)*i],
            slave_d_denied[i], slave_d_data[C_TILELINK_DATA_WIDTH*(i+1)-1:C_TILELINK_DATA_WIDTH*i], slave_d_corrupt[i], slave_d_valid[i], slave_d_ready[i]
        );
    end
    TileLinkMto1UH #(C_NUM_MASTERS, C_TILELINK_DATA_WIDTH, C_TILELINK_ADDR_WIDTH, C_TILELINK_ID_WIDTH, 3) denialMto1 (
        tilelink_clock_i, tilelink_reset_i, 
        interconnect_master_a_opcode[C_NUM_SLAVES],
        interconnect_master_a_param[C_NUM_SLAVES],
        interconnect_master_a_size[C_NUM_SLAVES],
        interconnect_master_a_source[C_NUM_SLAVES],
        interconnect_master_a_address[C_NUM_SLAVES],
        interconnect_master_a_mask[C_NUM_SLAVES],
        interconnect_master_a_data[C_NUM_SLAVES],
        interconnect_master_a_corrupt[C_NUM_SLAVES],
        interconnect_master_a_valid[C_NUM_SLAVES],
        interconnect_master_a_ready[C_NUM_SLAVES],
        interconnect_master_d_opcode[C_NUM_SLAVES],
        interconnect_master_d_param[C_NUM_SLAVES],
        interconnect_master_d_size[C_NUM_SLAVES],
        interconnect_master_d_source[C_NUM_SLAVES],
        interconnect_master_d_denied[C_NUM_SLAVES],
        interconnect_master_d_data[C_NUM_SLAVES],
        interconnect_master_d_corrupt[C_NUM_SLAVES],
        interconnect_master_d_valid[C_NUM_SLAVES],
        interconnect_master_d_ready[C_NUM_SLAVES],
        denial_a_opcode, denial_a_param, denial_a_size, denial_a_source, denial_a_address, denial_a_mask, denial_a_data, denial_a_corrupt,
        denial_a_valid, denial_a_ready, denial_d_opcode, denial_d_param, denial_d_size, denial_d_source, denial_d_denied, denial_d_data, denial_d_corrupt, denial_d_valid,
        denial_d_ready 
    );
    wire logic [2:0]                    denial_a_opcode;
    wire logic [2:0]                    denial_a_param;
    wire logic [3:0]                    denial_a_size;
    wire logic [(C_TILELINK_ID_WIDTH+$clog2(C_NUM_MASTERS))-1:0]  denial_a_source;
    wire logic [C_TILELINK_ADDR_WIDTH-1:0]              denial_a_address;
    wire logic [(C_TILELINK_DATA_WIDTH/8) - 1:0]        denial_a_mask;
    wire logic [C_TILELINK_DATA_WIDTH-1:0]              denial_a_data;
    wire logic                          denial_a_corrupt;
    wire logic                          denial_a_valid;
    wire logic                          denial_a_ready;
    wire logic [2:0]                    denial_d_opcode;
    wire logic [1:0]                    denial_d_param;
    wire logic [2:0]                    denial_d_size;
    wire logic [(C_TILELINK_ID_WIDTH+$clog2(C_NUM_MASTERS))-1:0]  denial_d_source;
    wire logic                          denial_d_denied;
    wire logic [C_TILELINK_DATA_WIDTH-1:0]              denial_d_data;
    wire logic                          denial_d_corrupt;
    wire logic                          denial_d_valid;
    wire logic                          denial_d_ready;
    denial #(((C_TILELINK_ID_WIDTH+$clog2(C_NUM_MASTERS))), C_TILELINK_ADDR_WIDTH, C_TILELINK_DATA_WIDTH) denial0 (
        tilelink_clock_i, tilelink_reset_i, denial_a_opcode, denial_a_param, denial_a_size, denial_a_source, denial_a_address, denial_a_mask, denial_a_data, denial_a_corrupt,
        denial_a_valid, denial_a_ready, denial_d_opcode, denial_d_param, denial_d_size, denial_d_source, denial_d_denied, denial_d_data, denial_d_corrupt, denial_d_valid,
        denial_d_ready 
    );
endmodule
