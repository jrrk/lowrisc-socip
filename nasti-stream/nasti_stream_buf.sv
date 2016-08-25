 module nasti_stream_buf # (
   ID_WIDTH   = 1,             // id width
   DEST_WIDTH = 1,             // destination width
   USER_WIDTH = 1,             // width of user
   DATA_WIDTH = 64,            // width of data
   BUF_SIZE   = 8              // size of buffer
) (
   input  aclk,
   input  aresetn,
   nasti_stream_channel.slave  src,
   nasti_stream_channel.master dest
);

typedef struct packed unsigned {
   logic [DATA_WIDTH-1:0]   data;
   logic [DATA_WIDTH/8-1:0] strb;
   logic [DATA_WIDTH/8-1:0] keep;
   logic                    last;
   logic [ID_WIDTH-1:0]     id  ;
   logic [DEST_WIDTH-1:0]   dest;
   logic [USER_WIDTH-1:0]   user;
} Unit;

localparam BUF_WIDTH = BUF_SIZE > 1 ? $clog2(BUF_SIZE) : 1;

logic full, empty;
Unit read_unit, write_unit;

fifo # (
   .WIDTH (($bits(Unit)+7)/8*8),
   .DEPTH (BUF_WIDTH)
) fifo (
   .aclk    (aclk          ),
   .aresetn (aresetn       ),
   .w_en    (src.t_valid   ),
   .w_data  (write_unit    ),
   .r_en    (dest.t_ready  ),
   .r_data  (read_unit     ),
   .full    (full          ),
   .empty   (empty         )
);

assign write_unit.data = src.t_data;
assign write_unit.strb = src.t_strb;
assign write_unit.keep = src.t_keep;
assign write_unit.last = src.t_last;
assign write_unit.id   = src.t_id  ;
assign write_unit.dest = src.t_dest;
assign write_unit.user = src.t_user;

assign dest.t_data = read_unit.data;
assign dest.t_strb = read_unit.strb;
assign dest.t_keep = read_unit.keep;
assign dest.t_last = read_unit.last;
assign dest.t_id   = read_unit.id  ;
assign dest.t_dest = read_unit.dest;
assign dest.t_user = read_unit.user;

assign dest.t_valid = !empty;
assign src.t_ready  = !full;

endmodule
