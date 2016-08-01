module nasti_stream_slicer # (
   parameter N_PORT = 1
) (
   nasti_stream_channel.slave  master,
   nasti_stream_channel.master slave_0, slave_1, slave_2, slave_3
);

generate
   if(N_PORT > 0) begin
      assign slave_0.t_valid   = master.t_valid[0];
      assign slave_0.t_data    = master.t_data [0];
      assign slave_0.t_strb    = master.t_strb [0];
      assign slave_0.t_keep    = master.t_keep [0];
      assign slave_0.t_last    = master.t_last [0];
      assign slave_0.t_id      = master.t_id   [0];
      assign slave_0.t_dest    = master.t_dest [0];
      assign slave_0.t_user    = master.t_user [0];
      assign master.t_ready[0] = slave_0.t_ready;
   end

   if(N_PORT > 1) begin
      assign slave_1.t_valid   = master.t_valid[1];
      assign slave_1.t_data    = master.t_data [1];
      assign slave_1.t_strb    = master.t_strb [1];
      assign slave_1.t_keep    = master.t_keep [1];
      assign slave_1.t_last    = master.t_last [1];
      assign slave_1.t_id      = master.t_id   [1];
      assign slave_1.t_dest    = master.t_dest [1];
      assign slave_1.t_user    = master.t_user [1];
      assign master.t_ready[1] = slave_1.t_ready;
   end

   if(N_PORT > 2) begin
      assign slave_2.t_valid   = master.t_valid[2];
      assign slave_2.t_data    = master.t_data [2];
      assign slave_2.t_strb    = master.t_strb [2];
      assign slave_2.t_keep    = master.t_keep [2];
      assign slave_2.t_last    = master.t_last [2];
      assign slave_2.t_id      = master.t_id   [2];
      assign slave_2.t_dest    = master.t_dest [2];
      assign slave_2.t_user    = master.t_user [2];
      assign master.t_ready[2] = slave_2.t_ready;
   end

   if(N_PORT > 3) begin
      assign slave_3.t_valid   = master.t_valid[3];
      assign slave_3.t_data    = master.t_data [3];
      assign slave_3.t_strb    = master.t_strb [3];
      assign slave_3.t_keep    = master.t_keep [3];
      assign slave_3.t_last    = master.t_last [3];
      assign slave_3.t_id      = master.t_id   [3];
      assign slave_3.t_dest    = master.t_dest [3];
      assign slave_3.t_user    = master.t_user [3];
      assign master.t_ready[3] = slave_3.t_ready;
    end
endgenerate

endmodule
