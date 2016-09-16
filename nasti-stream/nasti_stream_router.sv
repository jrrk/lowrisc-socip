module nasti_stream_router # (
   DEST_WIDTH = 1
) (
   input aclk,
   input aresetn,
   input [DEST_WIDTH-1:0] dest,
   nasti_stream_channel.slave  master,
   nasti_stream_channel        slave
);

   logic latched;
   logic [DEST_WIDTH-1:0] dest_latch;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         latched    <= 0;
         dest_latch <= 0;
      end
      else begin
         if (!latched) begin
            // Start latching dest when a new packet starts
            if (master.t_valid) begin
               latched    <= 1;
               dest_latch <= dest;
            end
         end
         else begin
            // End of packet, stop latching dest
            if (master.t_last && master.t_valid && master.t_ready) begin
               latched    <= 0;
               dest_latch <= 0;
            end
         end
      end
   end

   assign slave.t_valid   = master.t_valid;
   assign slave.t_data    = master.t_data;
   assign slave.t_strb    = master.t_strb;
   assign slave.t_keep    = master.t_keep;
   assign slave.t_last    = master.t_last;
   assign slave.t_id      = master.t_id;
   assign slave.t_dest    = latched ? dest_latch : dest;
   assign slave.t_user    = master.t_user;

   assign master.t_ready  = slave.t_ready;

endmodule
