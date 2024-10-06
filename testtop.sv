module testtop (
    input   wire logic          clk,
    
    output  wire logic          callenv,
    output  wire logic [127:0]  state_o
);

wire logic [2:0]                dcache_a_opcode;
wire logic [2:0]                dcache_a_param;
wire logic [3:0]                dcache_a_size;
wire logic [31:0]               dcache_a_address;
wire logic [3:0]                dcache_a_mask;
wire logic [31:0]               dcache_a_data;
wire logic                      dcache_a_corrupt;
wire logic                      dcache_a_valid;
wire logic                      dcache_a_ready;
wire logic [2:0]                dcache_d_opcode;
wire logic [1:0]                dcache_d_param;
wire logic [3:0]                dcache_d_size;
wire logic                      dcache_d_denied;
wire logic [31:0]               dcache_d_data;
wire logic                      dcache_d_corrupt;
wire logic                      dcache_d_valid;
wire logic                      dcache_d_ready;
wire logic [2:0]                icache_a_opcode;
wire logic [2:0]                icache_a_param;
wire logic [3:0]                icache_a_size;
wire logic [31:0]               icache_a_address;
wire logic [3:0]                icache_a_mask;
wire logic [31:0]               icache_a_data;
wire logic                      icache_a_corrupt;
wire logic                      icache_a_valid;
wire logic                      icache_a_ready;
wire logic [2:0]                icache_d_opcode;
wire logic [1:0]                icache_d_param;
wire logic [3:0]                icache_d_size;
wire logic                      icache_d_denied;
wire logic [31:0]               icache_d_data;
wire logic                      icache_d_corrupt;
wire logic                      icache_d_valid;
wire logic                      icache_d_ready;
wire logic [2:0]                acp_a_opcode;
wire logic [2:0]                acp_a_param;
wire logic [3:0]                acp_a_size;
wire logic [31:0]               acp_a_address;
wire logic [3:0]                acp_a_mask;
wire logic [31:0]               acp_a_data;
wire logic                      acp_a_corrupt;
wire logic                      acp_a_valid;
wire logic                      acp_a_ready;
wire logic [2:0]                acp_d_opcode;
wire logic [1:0]                acp_d_param;
wire logic [3:0]                acp_d_size;
wire logic                      acp_d_denied;
wire logic [31:0]               acp_d_data;
wire logic                      acp_d_corrupt;
wire logic                      acp_d_valid;
wire logic                      acp_d_ready;

wire logic                      dcache_a_source = 0;



wire logic                      icache_a_source = 0;



wire logic                      acp_a_source = 0;


wire logic                      icache_d_source;
wire logic                      dcache_d_source;
wire logic                      acp_d_source;
wire logic                      ioside_d_source;
wire logic                      memside_d_source;
wire logic [2:0]                memside_a_opcode;
wire logic [2:0]                memside_a_param;
wire logic [3:0]                memside_a_size;
wire logic                      memside_a_source;
wire logic [31:0]               memside_a_address;
wire logic [3:0]                memside_a_mask;
wire logic [31:0]               memside_a_data;
wire logic                      memside_a_corrupt;
wire logic                      memside_a_valid;
wire logic                      memside_a_ready;

wire logic [2:0]                memside_d_opcode;
wire logic [1:0]                memside_d_param;
wire logic [3:0]                memside_d_size;
wire logic                      memside_d_denied;
wire logic [31:0]               memside_d_data;
wire logic                      memside_d_corrupt;
wire logic                      memside_d_valid;
wire logic                      memside_d_ready;

wire logic [2:0]                ioside_a_opcode;
wire logic [2:0]                ioside_a_param;
wire logic [3:0]                ioside_a_size;
wire logic                      ioside_a_source;
wire logic [31:0]               ioside_a_address;
wire logic [3:0]                ioside_a_mask;
wire logic [31:0]               ioside_a_data;
wire logic                      ioside_a_corrupt;
wire logic                      ioside_a_valid;
wire logic                      ioside_a_ready;

wire logic [2:0]                ioside_d_opcode;
wire logic [1:0]                ioside_d_param;
wire logic [3:0]                ioside_d_size;
wire logic                      ioside_d_denied;
wire logic [31:0]               ioside_d_data;
wire logic                      ioside_d_corrupt;
wire logic                      ioside_d_valid;
wire logic                      ioside_d_ready;

biriq #(32'h00004000, 128, 1, 32, 1, 0, 10) cpu0 (clk,1'b0,icache_a_opcode,
icache_a_param,
icache_a_size,
icache_a_address,
icache_a_mask,
icache_a_data,
icache_a_corrupt,
icache_a_valid,
icache_a_ready,
icache_d_opcode,
icache_d_param,
icache_d_size,
icache_d_denied,
icache_d_data,
icache_d_corrupt,
icache_d_valid,
icache_d_ready,
dcache_a_opcode,
dcache_a_param,
dcache_a_size,
dcache_a_address,
dcache_a_mask,
dcache_a_data,
dcache_a_corrupt,
dcache_a_valid,
dcache_a_ready,
dcache_d_opcode,
dcache_d_param,
dcache_d_size,
dcache_d_denied,
dcache_d_data,
dcache_d_corrupt,
dcache_d_valid,
dcache_d_ready,
acp_a_opcode,
acp_a_param,
acp_a_size,
acp_a_source,
acp_a_address,
acp_a_mask,
acp_a_data,
acp_a_valid,
acp_a_ready,
acp_d_opcode,
acp_d_param,
acp_d_size,
acp_d_source,
acp_d_denied,
acp_d_data,
acp_d_corrupt,
acp_d_valid,
acp_d_ready,
3'b000
);
TileLink1toN #(2,  {
    32'h80000000
}, {
    32'hFFFFFFFF
},32, 32, 1, 4) iomultiplex (clk, 1'b0, dcache_a_opcode,dcache_a_param,dcache_a_size,1'b0,dcache_a_address,dcache_a_mask,dcache_a_data,
dcache_a_corrupt,dcache_a_valid,dcache_a_ready,dcache_d_opcode,dcache_d_param,dcache_d_size,dcache_d_source, dcache_d_denied,dcache_d_data,dcache_d_corrupt,dcache_d_valid,
dcache_d_ready, 
{memside_a_opcode,ioside_a_opcode},
{memside_a_param, ioside_a_param},
{memside_a_size, ioside_a_size},
{memside_a_source, ioside_a_source},
{memside_a_address, ioside_a_address},
{memside_a_mask, ioside_a_mask},
{memside_a_data, ioside_a_data},
{memside_a_corrupt, ioside_a_corrupt},
{memside_a_valid, ioside_a_valid},
{memside_a_ready, ioside_a_ready},
{memside_d_opcode, ioside_d_opcode},
{memside_d_param, ioside_d_param},
{memside_d_size, ioside_d_size},
{memside_d_source, ioside_d_source},
{memside_d_denied, ioside_d_denied},
{memside_d_data, ioside_d_data},
{memside_d_corrupt, ioside_d_corrupt},
{memside_d_valid, ioside_d_valid},
{memside_d_ready, ioside_d_ready});
wire logic [2:0]                    sram_a_opcode;
wire logic [2:0]                    sram_a_param;
wire logic [3:0]                    sram_a_size;
wire logic [1:0]                    sram_a_source;
wire logic [31:0]                   sram_a_address;
wire logic [3:0]                    sram_a_mask;
wire logic [31:0]                   sram_a_data;
wire logic                          sram_a_corrupt;
wire logic                          sram_a_valid;
wire logic                          sram_a_ready;
wire logic [2:0]                    sram_d_opcode;
wire logic [1:0]                    sram_d_param;
wire logic [3:0]                    sram_d_size;
wire logic [1:0]                    sram_d_source;
wire logic                          sram_d_denied;
wire logic [31:0]                   sram_d_data;
wire logic                          sram_d_corrupt;
wire logic                          sram_d_valid;
wire logic                          sram_d_ready;
openPolarisSRAM #(2, 24, 1, "test.mem") sram0 (
    clk, 1'b0, sram_a_opcode,
    sram_a_param,
    sram_a_size,
    sram_a_source,
    sram_a_address[23:0],
    sram_a_mask,
    sram_a_data,
    sram_a_corrupt,
    sram_a_valid,
    sram_a_ready,
    sram_d_opcode,
    sram_d_param,
    sram_d_size,
    sram_d_source,
    sram_d_denied,
    sram_d_data,
    sram_d_corrupt,
    sram_d_valid,
    sram_d_ready
);
TileLinkMtoN #(2, 1, 32, 32, 1, 4, {
    32'h00000000
}, {
    32'h20000000
}) memoryInterconnect (clk, 1'b0, 
{icache_a_opcode, memside_a_opcode}, 
{icache_a_param, memside_a_param},
{icache_a_size, memside_a_size},
{icache_a_source,  memside_a_source},
{icache_a_address, memside_a_address},
{icache_a_mask, memside_a_mask},
{icache_a_data, memside_a_data},
{icache_a_corrupt, memside_a_corrupt},
{icache_a_valid, memside_a_valid},
{icache_a_ready, memside_a_ready},
{icache_d_opcode, memside_d_opcode}, 
{icache_d_param, memside_d_param},
{icache_d_size,  memside_d_size},
{icache_d_source, memside_d_source},
{icache_d_denied, memside_d_denied},
{icache_d_data,    memside_d_data},
{icache_d_corrupt, memside_d_corrupt},
{icache_d_valid, memside_d_valid},
{icache_d_ready, memside_d_ready},
sram_a_opcode, 
sram_a_param,  
sram_a_size,   
sram_a_source, 
sram_a_address,
sram_a_mask,   
sram_a_data,   
sram_a_corrupt,
sram_a_valid,  
sram_a_ready,  
sram_d_opcode, 
sram_d_param,  
sram_d_size,   
sram_d_source, 
sram_d_denied, 
sram_d_data,   
sram_d_corrupt,
sram_d_valid,  
sram_d_ready
);

debug #(1) debugmodule (clk, 1'b0, ioside_a_opcode,
ioside_a_param,
ioside_a_size,
ioside_a_source,
ioside_a_address[4:0],
ioside_a_mask,
ioside_a_data,
ioside_a_corrupt,
ioside_a_valid,
ioside_a_ready,
ioside_d_opcode,
ioside_d_param,
ioside_d_size,
ioside_d_source,
ioside_d_denied,
ioside_d_data,
ioside_d_corrupt,
ioside_d_valid,
ioside_d_ready, callenv, state_o);
endmodule
