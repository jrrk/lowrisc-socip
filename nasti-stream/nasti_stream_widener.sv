module nasti_stream_widener # (
   ID_WIDTH   = 1,             // id width
   DEST_WIDTH = 1,             // destination width
   USER_WIDTH = 1,             // width of user
   MASTER_DATA_WIDTH = 64,     // width of data
   SLAVE_DATA_WIDTH  = 128
) (
   input  aclk,
   input  aresetn,
   nasti_stream_channel.slave  master,
   nasti_stream_channel.master slave
);

   localparam MULTIPLE = SLAVE_DATA_WIDTH / MASTER_DATA_WIDTH;
   localparam CNT_WIDTH = $clog2(MULTIPLE + 1);

   initial assert(MULTIPLE * MASTER_DATA_WIDTH == SLAVE_DATA_WIDTH) else $error("NASTI-Stream Widener: Slave data width is not multiple of master data width");
   initial assert(MULTIPLE > 1) else $error("NASTI-Stream Widener: Slave data width is not greater than master data width");

   logic [CNT_WIDTH-1:0] cnt;

   logic [MULTIPLE-1:0][MASTER_DATA_WIDTH-1:0]   data;
   logic [MULTIPLE-1:0][MASTER_DATA_WIDTH/8-1:0] strb;
   logic [MULTIPLE-1:0][MASTER_DATA_WIDTH/8-1:0] keep;
   logic                                         last;
   logic [ID_WIDTH-1:0]                          id  ;
   logic [DEST_WIDTH-1:0]                        dest;
   logic [USER_WIDTH-1:0]                        user;

   // If buffer is not empty, we can read. Otherwise, we can read if the data is written
   assign master.t_ready = cnt == MULTIPLE ? slave.t_ready && slave.t_valid : 1;

   assign slave.t_valid = cnt == MULTIPLE;

   assign slave.t_data = data;
   assign slave.t_strb = strb;
   assign slave.t_keep = keep;
   assign slave.t_last = last;
   assign slave.t_id   = id  ;
   assign slave.t_dest = dest;
   assign slave.t_user = user;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         cnt <= 0;
      end else begin
         if (slave.t_valid && slave.t_ready) begin
            cnt <= 0;
            if (master.t_valid && master.t_ready) begin
               data[0] <= master.t_data;
               strb[0] <= master.t_strb;
               keep[0] <= master.t_keep;
               assert(!master.t_last) else $error("NASTI-Stream Widener: Unexpected end of packet when waiting for input");
               cnt <= 1;
            end else begin
               cnt <= 0;
            end
         end else if (master.t_valid && master.t_ready) begin
            data[cnt] <= master.t_data;
            strb[cnt] <= master.t_strb;
            keep[cnt] <= master.t_keep;
            if (cnt == MULTIPLE - 1) begin
               last <= master.t_last;
               id   <= master.t_id  ;
               dest <= master.t_dest;
               user <= master.t_user;
            end else begin
               assert(!master.t_last) else $error("NASTI-Stream Widener: Unexpected end of packet when waiting for input");
            end
            cnt <= cnt + 1;
         end
      end
   end

endmodule
