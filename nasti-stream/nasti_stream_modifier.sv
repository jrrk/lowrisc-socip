module nasti_stream_modifier (
   nasti_stream_channel.slave  master,
   nasti_stream_channel        slave
);
   assign slave.t_valid   = master.t_valid;
   assign slave.t_data    = master.t_data;
   assign slave.t_strb    = master.t_strb;
   assign slave.t_keep    = master.t_keep;
   assign slave.t_last    = master.t_last;
   assign slave.t_id      = master.t_id;
   assign slave.t_user    = master.t_user;
   assign master.t_ready  = slave.t_ready;
endmodule
