module nasti_rw_combiner (
   nasti_channel.slave  read,
   nasti_channel.slave  write,
   nasti_channel.master slave
);

   // Read Address Channel
   assign read.ar_ready = slave.ar_ready;

   assign write.ar_ready = 0;

   assign slave.ar_id     = read.ar_id    ;
   assign slave.ar_addr   = read.ar_addr  ;
   assign slave.ar_len    = read.ar_len   ;
   assign slave.ar_size   = read.ar_size  ;
   assign slave.ar_burst  = read.ar_burst ;
   assign slave.ar_lock   = read.ar_lock  ;
   assign slave.ar_cache  = read.ar_cache ;
   assign slave.ar_prot   = read.ar_prot  ;
   assign slave.ar_qos    = read.ar_qos   ;
   assign slave.ar_region = read.ar_region;
   assign slave.ar_user   = read.ar_user  ;
   assign slave.ar_valid  = read.ar_valid ;

   // Read channel
   assign read.r_data  = slave.r_data ;
   assign read.r_last  = slave.r_last ;
   assign read.r_id    = slave.r_id   ;
   assign read.r_resp  = slave.r_resp ;
   assign read.r_user  = slave.r_user ;
   assign read.r_valid = slave.r_valid;

   assign write.r_data  = 0;
   assign write.r_last  = 0;
   assign write.r_id    = 0;
   assign write.r_resp  = 0;
   assign write.r_user  = 0;
   assign write.r_valid = 0;

   assign slave.r_ready = read.r_ready;

   // Write Address Channel
   assign read.aw_ready = 0;

   assign write.aw_ready = slave.aw_ready;

   assign slave.aw_id     = write.aw_id    ;
   assign slave.aw_addr   = write.aw_addr  ;
   assign slave.aw_len    = write.aw_len   ;
   assign slave.aw_size   = write.aw_size  ;
   assign slave.aw_burst  = write.aw_burst ;
   assign slave.aw_lock   = write.aw_lock  ;
   assign slave.aw_cache  = write.aw_cache ;
   assign slave.aw_prot   = write.aw_prot  ;
   assign slave.aw_qos    = write.aw_qos   ;
   assign slave.aw_region = write.aw_region;
   assign slave.aw_user   = write.aw_user  ;
   assign slave.aw_valid  = write.aw_valid ;

   // Write Channel
   assign read.w_ready = 0;

   assign write.w_ready = slave.w_ready;

   assign slave.w_data  = write.w_data ;
   assign slave.w_strb  = write.w_strb ;
   assign slave.w_last  = write.w_last ;
   assign slave.w_user  = write.w_user ;
   assign slave.w_valid = write.w_valid;

   // Write Response Channel
   assign read.b_id    = 0;
   assign read.b_resp  = 0;
   assign read.b_user  = 0;
   assign read.b_valid = 0;

   assign write.b_id    = slave.b_id   ;
   assign write.b_resp  = slave.b_resp ;
   assign write.b_user  = slave.b_user ;
   assign write.b_valid = slave.b_valid;

   assign slave.b_ready = write.b_ready;

endmodule
