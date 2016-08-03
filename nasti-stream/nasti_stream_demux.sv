module nasti_stream_demux # (
   N_PORT = 1,                 // number of nasti stream ports
   DEST_WIDTH = $clog2(N_PORT)
) (
   input aclk,
   input aresetn,
   nasti_stream_channel.slave  master,
   nasti_stream_channel.master slave
);

logic enable_latch;
logic [DEST_WIDTH-1:0] select_latch;

always_ff @(posedge aclk or negedge aresetn) begin
   if (!aresetn) begin
      enable_latch <= 0;
      select_latch <= 0;
   end
   else begin
      if (!enable_latch) begin
         if (master.t_valid) begin
            enable_latch <= 1;
            select_latch <= master.t_dest;
         end
      end
      else begin
         // Transfer finished
         if (master.t_last && master.t_valid && master.t_ready) begin
            enable_latch <= 0;
            select_latch <= 0;
         end
      end
   end
end

genvar i;
generate
   for (i = 0; i < N_PORT; i++) begin: slave_wiring
      assign slave.t_data[i]  = master.t_data;
      assign slave.t_strb[i]  = master.t_strb;
      assign slave.t_keep[i]  = master.t_keep;
      assign slave.t_last[i]  = master.t_last;
      assign slave.t_id  [i]  = master.t_id;
      assign slave.t_dest[i]  = master.t_dest;
      assign slave.t_user[i]  = master.t_user;
      assign slave.t_valid[i] = enable_latch && select_latch == i ? master.t_valid : 0;
   end
endgenerate

assign master.t_ready = enable_latch ? slave.t_ready[select_latch] : 0;

endmodule
