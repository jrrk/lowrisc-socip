module nasti_stream_slicer # (
   parameter N_PORT = 1
) (
   nasti_stream_channel.slave  master,
   nasti_stream_channel.master slave_0, slave_1, slave_2, slave_3, slave_4, slave_5, slave_6, slave_7
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

   if(N_PORT > 4) begin
      assign slave_4.t_valid   = master.t_valid[4];
      assign slave_4.t_data    = master.t_data [4];
      assign slave_4.t_strb    = master.t_strb [4];
      assign slave_4.t_keep    = master.t_keep [4];
      assign slave_4.t_last    = master.t_last [4];
      assign slave_4.t_id      = master.t_id   [4];
      assign slave_4.t_dest    = master.t_dest [4];
      assign slave_4.t_user    = master.t_user [4];
      assign master.t_ready[4] = slave_4.t_ready;
   end

   if(N_PORT > 5) begin
      assign slave_5.t_valid   = master.t_valid[5];
      assign slave_5.t_data    = master.t_data [5];
      assign slave_5.t_strb    = master.t_strb [5];
      assign slave_5.t_keep    = master.t_keep [5];
      assign slave_5.t_last    = master.t_last [5];
      assign slave_5.t_id      = master.t_id   [5];
      assign slave_5.t_dest    = master.t_dest [5];
      assign slave_5.t_user    = master.t_user [5];
      assign master.t_ready[5] = slave_5.t_ready;
   end

   if(N_PORT > 6) begin
      assign slave_6.t_valid   = master.t_valid[6];
      assign slave_6.t_data    = master.t_data [6];
      assign slave_6.t_strb    = master.t_strb [6];
      assign slave_6.t_keep    = master.t_keep [6];
      assign slave_6.t_last    = master.t_last [6];
      assign slave_6.t_id      = master.t_id   [6];
      assign slave_6.t_dest    = master.t_dest [6];
      assign slave_6.t_user    = master.t_user [6];
      assign master.t_ready[6] = slave_6.t_ready;
   end

   if(N_PORT > 7) begin
      assign slave_7.t_valid   = master.t_valid[7];
      assign slave_7.t_data    = master.t_data [7];
      assign slave_7.t_strb    = master.t_strb [7];
      assign slave_7.t_keep    = master.t_keep [7];
      assign slave_7.t_last    = master.t_last [7];
      assign slave_7.t_id      = master.t_id   [7];
      assign slave_7.t_dest    = master.t_dest [7];
      assign slave_7.t_user    = master.t_user [7];
      assign master.t_ready[7] = slave_7.t_ready;
   end
endgenerate

endmodule
