module nasti_stream_mux # (
   N_PORT = 1,                 // number of nasti stream ports
   DEST_WIDTH = $clog2(N_PORT),
   DEST_ID = 0
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
         foreach (master.t_valid[i]) begin
            if (master.t_valid[i] && master.t_dest[i] == DEST_ID) begin
               enable_latch <= 1;
               select_latch <= i;
               break;
            end
         end
      end
      else begin
         // Transfer finished
         if (slave.t_last && slave.t_valid && slave.t_ready) begin
            enable_latch <= 0;
            select_latch <= 0;
         end
      end
   end
end

genvar i;
generate
   for (i = 0; i < N_PORT; i++) begin: master_wiring
      assign master.t_ready[i] = enable_latch && select_latch == i ? slave.t_ready : 0;
   end
endgenerate

assign slave.t_data  = master.t_data[select_latch];
assign slave.t_strb  = master.t_strb[select_latch];
assign slave.t_keep  = master.t_keep[select_latch];
assign slave.t_last  = master.t_last[select_latch];
assign slave.t_id    = master.t_id  [select_latch];
assign slave.t_dest  = master.t_dest[select_latch];
assign slave.t_user  = master.t_user[select_latch];
assign slave.t_valid = enable_latch ? master.t_valid[select_latch] : 0; 

endmodule
