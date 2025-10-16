
localparam [2:0] Get = 3'd4;
localparam [2:0] PutFullData = 3'd0;
localparam [2:0] PutPartialData = 3'd1;
localparam [2:0] ArithmeticData = 3'd2;
localparam [2:0] LogicalData = 3'd3;
localparam [2:0] AMOXOR = 3'd0;
localparam [2:0] AMOOR = 3'd1;
localparam [2:0] AMOAND = 3'd2;
localparam [2:0] AMOSWAP = 3'd3;
localparam [2:0] AMOMIN = 3'd0;
localparam [2:0] AMOMAX = 3'd1;
localparam [2:0] AMOMINU = 3'd2;
localparam [2:0] AMOMAXU = 3'd3;
localparam [2:0] AMOADD = 3'd4;

function automatic TL_isWriteTo(input [AW-1:0] address, input [AW-1:0] address_t);
  TL_isWriteTo = (address == address_t) && a_valid && (d_ready || !d_valid_q) && (a_opcode==PutFullData || a_opcode==PutPartialData || a_opcode==ArithmeticData || a_opcode==LogicalData);
endfunction
function automatic TL_isReadTo(input [AW-1:0] address, input [AW-1:0] address_t);
  TL_isReadTo = (address == address_t) && a_valid && (d_ready || !d_valid_q) && (a_opcode == Get || a_opcode==ArithmeticData || a_opcode==LogicalData);
endfunction
function automatic [2:0] TL_RetCode();
  TL_RetCode = (a_opcode == PutFullData || a_opcode == PutPartialData) ? 3'd0 : 3'd1;
endfunction
