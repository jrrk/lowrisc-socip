module nasti_stream_combiner # (
   parameter N_PORT = 1
) (
   nasti_stream_channel.slave  master_0, master_1, master_2, master_3,
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
endgenerate

endmodule
