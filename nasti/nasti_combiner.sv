// See LICENSE for license details.

module nasti_channel_combiner
  #(
    N_PORT = 1                 // number of nasti ports to be combined, maximal 8
    )
   (
    nasti_channel.slave master_0, master_1, master_2, master_3, master_4, master_5, master_6, master_7,
    nasti_channel.master slave
    );

   // much easier if Vivado support array of interfaces
   generate
      if(N_PORT > 0) begin
         assign slave.aw_id[0]     = master_0.aw_id;
         assign slave.aw_addr[0]   = master_0.aw_addr;
         assign slave.aw_len[0]    = master_0.aw_len;
         assign slave.aw_size[0]   = master_0.aw_size;
         assign slave.aw_burst[0]  = master_0.aw_burst;
         assign slave.aw_lock[0]   = master_0.aw_lock;
         assign slave.aw_cache[0]  = master_0.aw_cache;
         assign slave.aw_prot[0]   = master_0.aw_prot;
         assign slave.aw_qos[0]    = master_0.aw_qos;
         assign slave.aw_region[0] = master_0.aw_region;
         assign slave.aw_user[0]   = master_0.aw_user;
         assign slave.aw_valid[0]  = master_0.aw_valid;
         assign slave.ar_id[0]     = master_0.ar_id;
         assign slave.ar_addr[0]   = master_0.ar_addr;
         assign slave.ar_len[0]    = master_0.ar_len;
         assign slave.ar_size[0]   = master_0.ar_size;
         assign slave.ar_burst[0]  = master_0.ar_burst;
         assign slave.ar_lock[0]   = master_0.ar_lock;
         assign slave.ar_cache[0]  = master_0.ar_cache;
         assign slave.ar_prot[0]   = master_0.ar_prot;
         assign slave.ar_qos[0]    = master_0.ar_qos;
         assign slave.ar_region[0] = master_0.ar_region;
         assign slave.ar_user[0]   = master_0.ar_user;
         assign slave.ar_valid[0]  = master_0.ar_valid;
         assign slave.w_data[0]    = master_0.w_data;
         assign slave.w_strb[0]    = master_0.w_strb;
         assign slave.w_last[0]    = master_0.w_last;
         assign slave.w_user[0]    = master_0.w_user;
         assign slave.w_valid[0]   = master_0.w_valid;
         assign slave.b_ready[0]   = master_0.b_ready;
         assign slave.r_ready[0]   = master_0.r_ready;
         assign master_0.aw_ready  = slave.aw_ready[0];
         assign master_0.ar_ready  = slave.ar_ready[0];
         assign master_0.w_ready   = slave.w_ready[0];
         assign master_0.b_id      = slave.b_id[0];
         assign master_0.b_resp    = slave.b_resp[0];
         assign master_0.b_user    = slave.b_user[0];
         assign master_0.b_valid   = slave.b_valid[0];
         assign master_0.r_data    = slave.r_data[0];
         assign master_0.r_last    = slave.r_last[0];
         assign master_0.r_id      = slave.r_id[0];
         assign master_0.r_resp    = slave.r_resp[0];
         assign master_0.r_user    = slave.r_user[0];
         assign master_0.r_valid   = slave.r_valid[0];
      end

      if(N_PORT > 1) begin
         assign slave.aw_id[1]     = master_1.aw_id;
         assign slave.aw_addr[1]   = master_1.aw_addr;
         assign slave.aw_len[1]    = master_1.aw_len;
         assign slave.aw_size[1]   = master_1.aw_size;
         assign slave.aw_burst[1]  = master_1.aw_burst;
         assign slave.aw_lock[1]   = master_1.aw_lock;
         assign slave.aw_cache[1]  = master_1.aw_cache;
         assign slave.aw_prot[1]   = master_1.aw_prot;
         assign slave.aw_qos[1]    = master_1.aw_qos;
         assign slave.aw_region[1] = master_1.aw_region;
         assign slave.aw_user[1]   = master_1.aw_user;
         assign slave.aw_valid[1]  = master_1.aw_valid;
         assign slave.ar_id[1]     = master_1.ar_id;
         assign slave.ar_addr[1]   = master_1.ar_addr;
         assign slave.ar_len[1]    = master_1.ar_len;
         assign slave.ar_size[1]   = master_1.ar_size;
         assign slave.ar_burst[1]  = master_1.ar_burst;
         assign slave.ar_lock[1]   = master_1.ar_lock;
         assign slave.ar_cache[1]  = master_1.ar_cache;
         assign slave.ar_prot[1]   = master_1.ar_prot;
         assign slave.ar_qos[1]    = master_1.ar_qos;
         assign slave.ar_region[1] = master_1.ar_region;
         assign slave.ar_user[1]   = master_1.ar_user;
         assign slave.ar_valid[1]  = master_1.ar_valid;
         assign slave.w_data[1]    = master_1.w_data;
         assign slave.w_strb[1]    = master_1.w_strb;
         assign slave.w_last[1]    = master_1.w_last;
         assign slave.w_user[1]    = master_1.w_user;
         assign slave.w_valid[1]   = master_1.w_valid;
         assign slave.b_ready[1]   = master_1.b_ready;
         assign slave.r_ready[1]   = master_1.r_ready;
         assign master_1.aw_ready  = slave.aw_ready[1];
         assign master_1.ar_ready  = slave.ar_ready[1];
         assign master_1.w_ready   = slave.w_ready[1];
         assign master_1.b_id      = slave.b_id[1];
         assign master_1.b_resp    = slave.b_resp[1];
         assign master_1.b_user    = slave.b_user[1];
         assign master_1.b_valid   = slave.b_valid[1];
         assign master_1.r_data    = slave.r_data[1];
         assign master_1.r_last    = slave.r_last[1];
         assign master_1.r_id      = slave.r_id[1];
         assign master_1.r_resp    = slave.r_resp[1];
         assign master_1.r_user    = slave.r_user[1];
         assign master_1.r_valid   = slave.r_valid[1];
      end

      if(N_PORT > 2) begin
         assign slave.aw_id[2]     = master_2.aw_id;
         assign slave.aw_addr[2]   = master_2.aw_addr;
         assign slave.aw_len[2]    = master_2.aw_len;
         assign slave.aw_size[2]   = master_2.aw_size;
         assign slave.aw_burst[2]  = master_2.aw_burst;
         assign slave.aw_lock[2]   = master_2.aw_lock;
         assign slave.aw_cache[2]  = master_2.aw_cache;
         assign slave.aw_prot[2]   = master_2.aw_prot;
         assign slave.aw_qos[2]    = master_2.aw_qos;
         assign slave.aw_region[2] = master_2.aw_region;
         assign slave.aw_user[2]   = master_2.aw_user;
         assign slave.aw_valid[2]  = master_2.aw_valid;
         assign slave.ar_id[2]     = master_2.ar_id;
         assign slave.ar_addr[2]   = master_2.ar_addr;
         assign slave.ar_len[2]    = master_2.ar_len;
         assign slave.ar_size[2]   = master_2.ar_size;
         assign slave.ar_burst[2]  = master_2.ar_burst;
         assign slave.ar_lock[2]   = master_2.ar_lock;
         assign slave.ar_cache[2]  = master_2.ar_cache;
         assign slave.ar_prot[2]   = master_2.ar_prot;
         assign slave.ar_qos[2]    = master_2.ar_qos;
         assign slave.ar_region[2] = master_2.ar_region;
         assign slave.ar_user[2]   = master_2.ar_user;
         assign slave.ar_valid[2]  = master_2.ar_valid;
         assign slave.w_data[2]    = master_2.w_data;
         assign slave.w_strb[2]    = master_2.w_strb;
         assign slave.w_last[2]    = master_2.w_last;
         assign slave.w_user[2]    = master_2.w_user;
         assign slave.w_valid[2]   = master_2.w_valid;
         assign slave.b_ready[2]   = master_2.b_ready;
         assign slave.r_ready[2]   = master_2.r_ready;
         assign master_2.aw_ready  = slave.aw_ready[2];
         assign master_2.ar_ready  = slave.ar_ready[2];
         assign master_2.w_ready   = slave.w_ready[2];
         assign master_2.b_id      = slave.b_id[2];
         assign master_2.b_resp    = slave.b_resp[2];
         assign master_2.b_user    = slave.b_user[2];
         assign master_2.b_valid   = slave.b_valid[2];
         assign master_2.r_data    = slave.r_data[2];
         assign master_2.r_last    = slave.r_last[2];
         assign master_2.r_id      = slave.r_id[2];
         assign master_2.r_resp    = slave.r_resp[2];
         assign master_2.r_user    = slave.r_user[2];
         assign master_2.r_valid   = slave.r_valid[2];
      end

      if(N_PORT > 3) begin
         assign slave.aw_id[3]     = master_3.aw_id;
         assign slave.aw_addr[3]   = master_3.aw_addr;
         assign slave.aw_len[3]    = master_3.aw_len;
         assign slave.aw_size[3]   = master_3.aw_size;
         assign slave.aw_burst[3]  = master_3.aw_burst;
         assign slave.aw_lock[3]   = master_3.aw_lock;
         assign slave.aw_cache[3]  = master_3.aw_cache;
         assign slave.aw_prot[3]   = master_3.aw_prot;
         assign slave.aw_qos[3]    = master_3.aw_qos;
         assign slave.aw_region[3] = master_3.aw_region;
         assign slave.aw_user[3]   = master_3.aw_user;
         assign slave.aw_valid[3]  = master_3.aw_valid;
         assign slave.ar_id[3]     = master_3.ar_id;
         assign slave.ar_addr[3]   = master_3.ar_addr;
         assign slave.ar_len[3]    = master_3.ar_len;
         assign slave.ar_size[3]   = master_3.ar_size;
         assign slave.ar_burst[3]  = master_3.ar_burst;
         assign slave.ar_lock[3]   = master_3.ar_lock;
         assign slave.ar_cache[3]  = master_3.ar_cache;
         assign slave.ar_prot[3]   = master_3.ar_prot;
         assign slave.ar_qos[3]    = master_3.ar_qos;
         assign slave.ar_region[3] = master_3.ar_region;
         assign slave.ar_user[3]   = master_3.ar_user;
         assign slave.ar_valid[3]  = master_3.ar_valid;
         assign slave.w_data[3]    = master_3.w_data;
         assign slave.w_strb[3]    = master_3.w_strb;
         assign slave.w_last[3]    = master_3.w_last;
         assign slave.w_user[3]    = master_3.w_user;
         assign slave.w_valid[3]   = master_3.w_valid;
         assign slave.b_ready[3]   = master_3.b_ready;
         assign slave.r_ready[3]   = master_3.r_ready;
         assign master_3.aw_ready  = slave.aw_ready[3];
         assign master_3.ar_ready  = slave.ar_ready[3];
         assign master_3.w_ready   = slave.w_ready[3];
         assign master_3.b_id      = slave.b_id[3];
         assign master_3.b_resp    = slave.b_resp[3];
         assign master_3.b_user    = slave.b_user[3];
         assign master_3.b_valid   = slave.b_valid[3];
         assign master_3.r_data    = slave.r_data[3];
         assign master_3.r_last    = slave.r_last[3];
         assign master_3.r_id      = slave.r_id[3];
         assign master_3.r_resp    = slave.r_resp[3];
         assign master_3.r_user    = slave.r_user[3];
         assign master_3.r_valid   = slave.r_valid[3];
      end

      if(N_PORT > 4) begin
         assign slave.aw_id[4]     = master_4.aw_id;
         assign slave.aw_addr[4]   = master_4.aw_addr;
         assign slave.aw_len[4]    = master_4.aw_len;
         assign slave.aw_size[4]   = master_4.aw_size;
         assign slave.aw_burst[4]  = master_4.aw_burst;
         assign slave.aw_lock[4]   = master_4.aw_lock;
         assign slave.aw_cache[4]  = master_4.aw_cache;
         assign slave.aw_prot[4]   = master_4.aw_prot;
         assign slave.aw_qos[4]    = master_4.aw_qos;
         assign slave.aw_region[4] = master_4.aw_region;
         assign slave.aw_user[4]   = master_4.aw_user;
         assign slave.aw_valid[4]  = master_4.aw_valid;
         assign slave.ar_id[4]     = master_4.ar_id;
         assign slave.ar_addr[4]   = master_4.ar_addr;
         assign slave.ar_len[4]    = master_4.ar_len;
         assign slave.ar_size[4]   = master_4.ar_size;
         assign slave.ar_burst[4]  = master_4.ar_burst;
         assign slave.ar_lock[4]   = master_4.ar_lock;
         assign slave.ar_cache[4]  = master_4.ar_cache;
         assign slave.ar_prot[4]   = master_4.ar_prot;
         assign slave.ar_qos[4]    = master_4.ar_qos;
         assign slave.ar_region[4] = master_4.ar_region;
         assign slave.ar_user[4]   = master_4.ar_user;
         assign slave.ar_valid[4]  = master_4.ar_valid;
         assign slave.w_data[4]    = master_4.w_data;
         assign slave.w_strb[4]    = master_4.w_strb;
         assign slave.w_last[4]    = master_4.w_last;
         assign slave.w_user[4]    = master_4.w_user;
         assign slave.w_valid[4]   = master_4.w_valid;
         assign slave.b_ready[4]   = master_4.b_ready;
         assign slave.r_ready[4]   = master_4.r_ready;
         assign master_4.aw_ready  = slave.aw_ready[4];
         assign master_4.ar_ready  = slave.ar_ready[4];
         assign master_4.w_ready   = slave.w_ready[4];
         assign master_4.b_id      = slave.b_id[4];
         assign master_4.b_resp    = slave.b_resp[4];
         assign master_4.b_user    = slave.b_user[4];
         assign master_4.b_valid   = slave.b_valid[4];
         assign master_4.r_data    = slave.r_data[4];
         assign master_4.r_last    = slave.r_last[4];
         assign master_4.r_id      = slave.r_id[4];
         assign master_4.r_resp    = slave.r_resp[4];
         assign master_4.r_user    = slave.r_user[4];
         assign master_4.r_valid   = slave.r_valid[4];
      end

      if(N_PORT > 5) begin
         assign slave.aw_id[5]     = master_5.aw_id;
         assign slave.aw_addr[5]   = master_5.aw_addr;
         assign slave.aw_len[5]    = master_5.aw_len;
         assign slave.aw_size[5]   = master_5.aw_size;
         assign slave.aw_burst[5]  = master_5.aw_burst;
         assign slave.aw_lock[5]   = master_5.aw_lock;
         assign slave.aw_cache[5]  = master_5.aw_cache;
         assign slave.aw_prot[5]   = master_5.aw_prot;
         assign slave.aw_qos[5]    = master_5.aw_qos;
         assign slave.aw_region[5] = master_5.aw_region;
         assign slave.aw_user[5]   = master_5.aw_user;
         assign slave.aw_valid[5]  = master_5.aw_valid;
         assign slave.ar_id[5]     = master_5.ar_id;
         assign slave.ar_addr[5]   = master_5.ar_addr;
         assign slave.ar_len[5]    = master_5.ar_len;
         assign slave.ar_size[5]   = master_5.ar_size;
         assign slave.ar_burst[5]  = master_5.ar_burst;
         assign slave.ar_lock[5]   = master_5.ar_lock;
         assign slave.ar_cache[5]  = master_5.ar_cache;
         assign slave.ar_prot[5]   = master_5.ar_prot;
         assign slave.ar_qos[5]    = master_5.ar_qos;
         assign slave.ar_region[5] = master_5.ar_region;
         assign slave.ar_user[5]   = master_5.ar_user;
         assign slave.ar_valid[5]  = master_5.ar_valid;
         assign slave.w_data[5]    = master_5.w_data;
         assign slave.w_strb[5]    = master_5.w_strb;
         assign slave.w_last[5]    = master_5.w_last;
         assign slave.w_user[5]    = master_5.w_user;
         assign slave.w_valid[5]   = master_5.w_valid;
         assign slave.b_ready[5]   = master_5.b_ready;
         assign slave.r_ready[5]   = master_5.r_ready;
         assign master_5.aw_ready  = slave.aw_ready[5];
         assign master_5.ar_ready  = slave.ar_ready[5];
         assign master_5.w_ready   = slave.w_ready[5];
         assign master_5.b_id      = slave.b_id[5];
         assign master_5.b_resp    = slave.b_resp[5];
         assign master_5.b_user    = slave.b_user[5];
         assign master_5.b_valid   = slave.b_valid[5];
         assign master_5.r_data    = slave.r_data[5];
         assign master_5.r_last    = slave.r_last[5];
         assign master_5.r_id      = slave.r_id[5];
         assign master_5.r_resp    = slave.r_resp[5];
         assign master_5.r_user    = slave.r_user[5];
         assign master_5.r_valid   = slave.r_valid[5];
      end

      if(N_PORT > 6) begin
         assign slave.aw_id[6]     = master_6.aw_id;
         assign slave.aw_addr[6]   = master_6.aw_addr;
         assign slave.aw_len[6]    = master_6.aw_len;
         assign slave.aw_size[6]   = master_6.aw_size;
         assign slave.aw_burst[6]  = master_6.aw_burst;
         assign slave.aw_lock[6]   = master_6.aw_lock;
         assign slave.aw_cache[6]  = master_6.aw_cache;
         assign slave.aw_prot[6]   = master_6.aw_prot;
         assign slave.aw_qos[6]    = master_6.aw_qos;
         assign slave.aw_region[6] = master_6.aw_region;
         assign slave.aw_user[6]   = master_6.aw_user;
         assign slave.aw_valid[6]  = master_6.aw_valid;
         assign slave.ar_id[6]     = master_6.ar_id;
         assign slave.ar_addr[6]   = master_6.ar_addr;
         assign slave.ar_len[6]    = master_6.ar_len;
         assign slave.ar_size[6]   = master_6.ar_size;
         assign slave.ar_burst[6]  = master_6.ar_burst;
         assign slave.ar_lock[6]   = master_6.ar_lock;
         assign slave.ar_cache[6]  = master_6.ar_cache;
         assign slave.ar_prot[6]   = master_6.ar_prot;
         assign slave.ar_qos[6]    = master_6.ar_qos;
         assign slave.ar_region[6] = master_6.ar_region;
         assign slave.ar_user[6]   = master_6.ar_user;
         assign slave.ar_valid[6]  = master_6.ar_valid;
         assign slave.w_data[6]    = master_6.w_data;
         assign slave.w_strb[6]    = master_6.w_strb;
         assign slave.w_last[6]    = master_6.w_last;
         assign slave.w_user[6]    = master_6.w_user;
         assign slave.w_valid[6]   = master_6.w_valid;
         assign slave.b_ready[6]   = master_6.b_ready;
         assign slave.r_ready[6]   = master_6.r_ready;
         assign master_6.aw_ready  = slave.aw_ready[6];
         assign master_6.ar_ready  = slave.ar_ready[6];
         assign master_6.w_ready   = slave.w_ready[6];
         assign master_6.b_id      = slave.b_id[6];
         assign master_6.b_resp    = slave.b_resp[6];
         assign master_6.b_user    = slave.b_user[6];
         assign master_6.b_valid   = slave.b_valid[6];
         assign master_6.r_data    = slave.r_data[6];
         assign master_6.r_last    = slave.r_last[6];
         assign master_6.r_id      = slave.r_id[6];
         assign master_6.r_resp    = slave.r_resp[6];
         assign master_6.r_user    = slave.r_user[6];
         assign master_6.r_valid   = slave.r_valid[6];
      end

      if(N_PORT > 7) begin
         assign slave.aw_id[7]     = master_7.aw_id;
         assign slave.aw_addr[7]   = master_7.aw_addr;
         assign slave.aw_len[7]    = master_7.aw_len;
         assign slave.aw_size[7]   = master_7.aw_size;
         assign slave.aw_burst[7]  = master_7.aw_burst;
         assign slave.aw_lock[7]   = master_7.aw_lock;
         assign slave.aw_cache[7]  = master_7.aw_cache;
         assign slave.aw_prot[7]   = master_7.aw_prot;
         assign slave.aw_qos[7]    = master_7.aw_qos;
         assign slave.aw_region[7] = master_7.aw_region;
         assign slave.aw_user[7]   = master_7.aw_user;
         assign slave.aw_valid[7]  = master_7.aw_valid;
         assign slave.ar_id[7]     = master_7.ar_id;
         assign slave.ar_addr[7]   = master_7.ar_addr;
         assign slave.ar_len[7]    = master_7.ar_len;
         assign slave.ar_size[7]   = master_7.ar_size;
         assign slave.ar_burst[7]  = master_7.ar_burst;
         assign slave.ar_lock[7]   = master_7.ar_lock;
         assign slave.ar_cache[7]  = master_7.ar_cache;
         assign slave.ar_prot[7]   = master_7.ar_prot;
         assign slave.ar_qos[7]    = master_7.ar_qos;
         assign slave.ar_region[7] = master_7.ar_region;
         assign slave.ar_user[7]   = master_7.ar_user;
         assign slave.ar_valid[7]  = master_7.ar_valid;
         assign slave.w_data[7]    = master_7.w_data;
         assign slave.w_strb[7]    = master_7.w_strb;
         assign slave.w_last[7]    = master_7.w_last;
         assign slave.w_user[7]    = master_7.w_user;
         assign slave.w_valid[7]   = master_7.w_valid;
         assign slave.b_ready[7]   = master_7.b_ready;
         assign slave.r_ready[7]   = master_7.r_ready;
         assign master_7.aw_ready  = slave.aw_ready[7];
         assign master_7.ar_ready  = slave.ar_ready[7];
         assign master_7.w_ready   = slave.w_ready[7];
         assign master_7.b_id      = slave.b_id[7];
         assign master_7.b_resp    = slave.b_resp[7];
         assign master_7.b_user    = slave.b_user[7];
         assign master_7.b_valid   = slave.b_valid[7];
         assign master_7.r_data    = slave.r_data[7];
         assign master_7.r_last    = slave.r_last[7];
         assign master_7.r_id      = slave.r_id[7];
         assign master_7.r_resp    = slave.r_resp[7];
         assign master_7.r_user    = slave.r_user[7];
         assign master_7.r_valid   = slave.r_valid[7];
      end
   endgenerate

endmodule // nasti_channel_combiner
