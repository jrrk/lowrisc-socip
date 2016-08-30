module nasti_stream_narrower # (
   ID_WIDTH   = 1,             // id width
   DEST_WIDTH = 1,             // slaveination width
   USER_WIDTH = 1,             // width of user
   MASTER_DATA_WIDTH = 128,    // width of data
   SLAVE_DATA_WIDTH  = 64
) (
   input  aclk,
   input  aresetn,
   nasti_stream_channel.slave  master,
   nasti_stream_channel.master slave
);

   localparam MULTIPLE = MASTER_DATA_WIDTH / SLAVE_DATA_WIDTH;
   localparam CNT_WIDTH = $clog2(MULTIPLE + 1);

   initial assert(MULTIPLE * SLAVE_DATA_WIDTH == MASTER_DATA_WIDTH) else $error("NASTI-Stream Narrower: Master data width is not multiple of slave data width");
   initial assert(MULTIPLE > 1) else $error("NASTI-Stream Narrower: Master data width is greater than slave data width");

   logic [CNT_WIDTH-1:0] cnt;

   logic [MULTIPLE-1:0][SLAVE_DATA_WIDTH-1:0]   data;
   logic [MULTIPLE-1:0][SLAVE_DATA_WIDTH/8-1:0] strb;
   logic [MULTIPLE-1:0][SLAVE_DATA_WIDTH/8-1:0] keep;
   logic                                        last;
   logic [ID_WIDTH-1:0]                         id  ;
   logic [DEST_WIDTH-1:0]                       dest;
   logic [USER_WIDTH-1:0]                       user;

   // If buffer is empty, we can read. Otherwise, we can read if last byte is written
   assign master.t_ready = cnt == MULTIPLE ? 1 : cnt == MULTIPLE - 1 && slave.t_ready && slave.t_valid;

   assign slave.t_valid = cnt != MULTIPLE;

   assign slave.t_data = data[cnt];
   assign slave.t_strb = strb[cnt];
   assign slave.t_keep = keep[cnt];
   assign slave.t_last = cnt == MULTIPLE - 1 ? last : 0;
   assign slave.t_id   = id;
   assign slave.t_dest = dest;
   assign slave.t_user = user;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         cnt <= MULTIPLE;
      end else begin
         if (master.t_valid && master.t_ready) begin
            cnt <= 0;
            data <= master.t_data;
            strb <= master.t_strb;
            keep <= master.t_keep;
            last <= master.t_last;
            id   <= master.t_id  ;
            dest <= master.t_dest;
            user <= master.t_user;
         end else if (slave.t_valid && slave.t_ready) begin
            cnt <= cnt + 1;
         end
      end
   end

endmodule
