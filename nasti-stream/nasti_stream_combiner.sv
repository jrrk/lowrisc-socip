module nasti_stream_combiner # (
   parameter N_PORT = 1
) (
   nasti_stream_channel.slave  master_0, master_1, master_2, master_3, master_4, master_5, master_6, master_7,
   nasti_stream_channel.master slave
);

generate
   if(N_PORT > 0) begin
      assign slave.t_valid[0] = master_0.t_valid;
      assign slave.t_data [0] = master_0.t_data;
      assign slave.t_strb [0] = master_0.t_strb;
      assign slave.t_keep [0] = master_0.t_keep;
      assign slave.t_last [0] = master_0.t_last;
      assign slave.t_id   [0] = master_0.t_id;
      assign slave.t_dest [0] = master_0.t_dest;
      assign slave.t_user [0] = master_0.t_user;
      assign master_0.t_ready = slave.t_ready[0];
   end

   if(N_PORT > 1) begin
      assign slave.t_valid[1] = master_1.t_valid;
      assign slave.t_data [1] = master_1.t_data;
      assign slave.t_strb [1] = master_1.t_strb;
      assign slave.t_keep [1] = master_1.t_keep;
      assign slave.t_last [1] = master_1.t_last;
      assign slave.t_id   [1] = master_1.t_id;
      assign slave.t_dest [1] = master_1.t_dest;
      assign slave.t_user [1] = master_1.t_user;
      assign master_1.t_ready = slave.t_ready[1];
   end

   if(N_PORT > 2) begin
      assign slave.t_valid[2] = master_2.t_valid;
      assign slave.t_data [2] = master_2.t_data;
      assign slave.t_strb [2] = master_2.t_strb;
      assign slave.t_keep [2] = master_2.t_keep;
      assign slave.t_last [2] = master_2.t_last;
      assign slave.t_id   [2] = master_2.t_id;
      assign slave.t_dest [2] = master_2.t_dest;
      assign slave.t_user [2] = master_2.t_user;
      assign master_2.t_ready = slave.t_ready[2];
   end

   if(N_PORT > 3) begin
      assign slave.t_valid[3] = master_3.t_valid;
      assign slave.t_data [3] = master_3.t_data;
      assign slave.t_strb [3] = master_3.t_strb;
      assign slave.t_keep [3] = master_3.t_keep;
      assign slave.t_last [3] = master_3.t_last;
      assign slave.t_id   [3] = master_3.t_id;
      assign slave.t_dest [3] = master_3.t_dest;
      assign slave.t_user [3] = master_3.t_user;
      assign master_3.t_ready = slave.t_ready[3];
   end

   if(N_PORT > 4) begin
      assign slave.t_valid[4] = master_4.t_valid;
      assign slave.t_data [4] = master_4.t_data;
      assign slave.t_strb [4] = master_4.t_strb;
      assign slave.t_keep [4] = master_4.t_keep;
      assign slave.t_last [4] = master_4.t_last;
      assign slave.t_id   [4] = master_4.t_id;
      assign slave.t_dest [4] = master_4.t_dest;
      assign slave.t_user [4] = master_4.t_user;
      assign master_4.t_ready = slave.t_ready[4];
   end

   if(N_PORT > 5) begin
      assign slave.t_valid[5] = master_5.t_valid;
      assign slave.t_data [5] = master_5.t_data;
      assign slave.t_strb [5] = master_5.t_strb;
      assign slave.t_keep [5] = master_5.t_keep;
      assign slave.t_last [5] = master_5.t_last;
      assign slave.t_id   [5] = master_5.t_id;
      assign slave.t_dest [5] = master_5.t_dest;
      assign slave.t_user [5] = master_5.t_user;
      assign master_5.t_ready = slave.t_ready[5];
   end

   if(N_PORT > 6) begin
      assign slave.t_valid[6] = master_6.t_valid;
      assign slave.t_data [6] = master_6.t_data;
      assign slave.t_strb [6] = master_6.t_strb;
      assign slave.t_keep [6] = master_6.t_keep;
      assign slave.t_last [6] = master_6.t_last;
      assign slave.t_id   [6] = master_6.t_id;
      assign slave.t_dest [6] = master_6.t_dest;
      assign slave.t_user [6] = master_6.t_user;
      assign master_6.t_ready = slave.t_ready[6];
   end

   if(N_PORT > 7) begin
      assign slave.t_valid[7] = master_7.t_valid;
      assign slave.t_data [7] = master_7.t_data;
      assign slave.t_strb [7] = master_7.t_strb;
      assign slave.t_keep [7] = master_7.t_keep;
      assign slave.t_last [7] = master_7.t_last;
      assign slave.t_id   [7] = master_7.t_id;
      assign slave.t_dest [7] = master_7.t_dest;
      assign slave.t_user [7] = master_7.t_user;
      assign master_7.t_ready = slave.t_ready[7];
   end
endgenerate

endmodule
