module nasti_stream_connector # (
   IDX_MASTER = 0,
   IDX_SLAVE = 0
) (
   nasti_stream_channel master,
   nasti_stream_channel slave
);

assign slave .t_valid[IDX_SLAVE ] = master.t_valid[IDX_MASTER];
assign slave .t_data [IDX_SLAVE ] = master.t_data [IDX_MASTER];
assign slave .t_strb [IDX_SLAVE ] = master.t_strb [IDX_MASTER];
assign slave .t_keep [IDX_SLAVE ] = master.t_keep [IDX_MASTER];
assign slave .t_last [IDX_SLAVE ] = master.t_last [IDX_MASTER];
assign slave .t_id   [IDX_SLAVE ] = master.t_id   [IDX_MASTER];
assign slave .t_dest [IDX_SLAVE ] = master.t_dest [IDX_MASTER];
assign slave .t_user [IDX_SLAVE ] = master.t_user [IDX_MASTER];
assign master.t_ready[IDX_MASTER] = slave .t_ready[IDX_SLAVE ];

endmodule

module nasti_stream_crossbar # (
   N_MASTER = 8,
   N_SLAVE  = 8,
   ID_WIDTH = 1,               // id width
   DEST_WIDTH = 1,             // destination width
   USER_WIDTH = 1,             // width of user
   DATA_WIDTH = 64
) (
   input aclk,
   input aresetn,
   nasti_stream_channel.slave  master,
   nasti_stream_channel.master slave
);

   nasti_stream_channel #(
      .N_PORT (8),
      .ID_WIDTH(ID_WIDTH),
      .DEST_WIDTH(DEST_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
   ) mx0(), mx1(), mx2(), mx3(), mx4(), mx5(), mx6(), mx7();

   nasti_stream_channel #(
      .ID_WIDTH(ID_WIDTH),
      .DEST_WIDTH(DEST_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
   ) m0(), m1(), m2(), m3(), m4(), m5(), m6(), m7();

   nasti_stream_demux #(
      .N_PORT (N_SLAVE),
      .DEST_WIDTH (DEST_WIDTH)
   )
   demux0 (.aclk (aclk), .aresetn (aresetn), .master (m0), .slave (mx0)),
   demux1 (.aclk (aclk), .aresetn (aresetn), .master (m1), .slave (mx1)),
   demux2 (.aclk (aclk), .aresetn (aresetn), .master (m2), .slave (mx2)),
   demux3 (.aclk (aclk), .aresetn (aresetn), .master (m3), .slave (mx3)),
   demux4 (.aclk (aclk), .aresetn (aresetn), .master (m4), .slave (mx4)),
   demux5 (.aclk (aclk), .aresetn (aresetn), .master (m5), .slave (mx5)),
   demux6 (.aclk (aclk), .aresetn (aresetn), .master (m6), .slave (mx6)),
   demux7 (.aclk (aclk), .aresetn (aresetn), .master (m7), .slave (mx7));

   nasti_stream_slicer # (.N_PORT(N_MASTER)) slicer (
      .master(master),
      .slave_0(m0),
      .slave_1(m1),
      .slave_2(m2),
      .slave_3(m3),
      .slave_4(m4),
      .slave_5(m5),
      .slave_6(m6),
      .slave_7(m7));

   nasti_stream_channel #(
      .N_PORT (8),
      .ID_WIDTH(ID_WIDTH),
      .DEST_WIDTH(DEST_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
   ) sx0(), sx1(), sx2(), sx3(), sx4(), sx5(), sx6(), sx7();

   nasti_stream_channel #(
      .ID_WIDTH(ID_WIDTH),
      .DEST_WIDTH(DEST_WIDTH),
      .USER_WIDTH(USER_WIDTH),
      .DATA_WIDTH(DATA_WIDTH)
   ) s0(), s1(), s2(), s3(), s4(), s5(), s6(), s7();

   nasti_stream_mux #(
      .N_PORT (N_SLAVE),
      .DEST_WIDTH (DEST_WIDTH)
   )
   mux0 (.aclk (aclk), .aresetn (aresetn), .master (sx0), .slave (s0)),
   mux1 (.aclk (aclk), .aresetn (aresetn), .master (sx1), .slave (s1)),
   mux2 (.aclk (aclk), .aresetn (aresetn), .master (sx2), .slave (s2)),
   mux3 (.aclk (aclk), .aresetn (aresetn), .master (sx3), .slave (s3)),
   mux4 (.aclk (aclk), .aresetn (aresetn), .master (sx4), .slave (s4)),
   mux5 (.aclk (aclk), .aresetn (aresetn), .master (sx5), .slave (s5)),
   mux6 (.aclk (aclk), .aresetn (aresetn), .master (sx6), .slave (s6)),
   mux7 (.aclk (aclk), .aresetn (aresetn), .master (sx7), .slave (s7));

   defparam mux0.DEST_ID = 0;
   defparam mux1.DEST_ID = 1;
   defparam mux2.DEST_ID = 2;
   defparam mux3.DEST_ID = 3;
   defparam mux4.DEST_ID = 4;
   defparam mux5.DEST_ID = 5;
   defparam mux6.DEST_ID = 6;
   defparam mux7.DEST_ID = 7;

   nasti_stream_combiner # (.N_PORT(N_SLAVE)) combiner (
      .master_0 (s0),
      .master_1 (s1),
      .master_2 (s2),
      .master_3 (s3),
      .master_4 (s4),
      .master_5 (s5),
      .master_6 (s6),
      .master_7 (s7),
      .slave (slave)
   );

   nasti_stream_connector # (.IDX_MASTER(0), .IDX_SLAVE(0)) conn00 (.master(mx0), .slave(sx0));
   nasti_stream_connector # (.IDX_MASTER(1), .IDX_SLAVE(0)) conn01 (.master(mx0), .slave(sx1));
   nasti_stream_connector # (.IDX_MASTER(2), .IDX_SLAVE(0)) conn02 (.master(mx0), .slave(sx2));
   nasti_stream_connector # (.IDX_MASTER(3), .IDX_SLAVE(0)) conn03 (.master(mx0), .slave(sx3));
   nasti_stream_connector # (.IDX_MASTER(4), .IDX_SLAVE(0)) conn04 (.master(mx0), .slave(sx4));
   nasti_stream_connector # (.IDX_MASTER(5), .IDX_SLAVE(0)) conn05 (.master(mx0), .slave(sx5));
   nasti_stream_connector # (.IDX_MASTER(6), .IDX_SLAVE(0)) conn06 (.master(mx0), .slave(sx6));
   nasti_stream_connector # (.IDX_MASTER(7), .IDX_SLAVE(0)) conn07 (.master(mx0), .slave(sx7));

   nasti_stream_connector # (.IDX_MASTER(0), .IDX_SLAVE(1)) conn10 (.master(mx1), .slave(sx0));
   nasti_stream_connector # (.IDX_MASTER(1), .IDX_SLAVE(1)) conn11 (.master(mx1), .slave(sx1));
   nasti_stream_connector # (.IDX_MASTER(2), .IDX_SLAVE(1)) conn12 (.master(mx1), .slave(sx2));
   nasti_stream_connector # (.IDX_MASTER(3), .IDX_SLAVE(1)) conn13 (.master(mx1), .slave(sx3));
   nasti_stream_connector # (.IDX_MASTER(4), .IDX_SLAVE(1)) conn14 (.master(mx1), .slave(sx4));
   nasti_stream_connector # (.IDX_MASTER(5), .IDX_SLAVE(1)) conn15 (.master(mx1), .slave(sx5));
   nasti_stream_connector # (.IDX_MASTER(6), .IDX_SLAVE(1)) conn16 (.master(mx1), .slave(sx6));
   nasti_stream_connector # (.IDX_MASTER(7), .IDX_SLAVE(1)) conn17 (.master(mx1), .slave(sx7));

   nasti_stream_connector # (.IDX_MASTER(0), .IDX_SLAVE(2)) conn20 (.master(mx2), .slave(sx0));
   nasti_stream_connector # (.IDX_MASTER(1), .IDX_SLAVE(2)) conn21 (.master(mx2), .slave(sx1));
   nasti_stream_connector # (.IDX_MASTER(2), .IDX_SLAVE(2)) conn22 (.master(mx2), .slave(sx2));
   nasti_stream_connector # (.IDX_MASTER(3), .IDX_SLAVE(2)) conn23 (.master(mx2), .slave(sx3));
   nasti_stream_connector # (.IDX_MASTER(4), .IDX_SLAVE(2)) conn24 (.master(mx2), .slave(sx4));
   nasti_stream_connector # (.IDX_MASTER(5), .IDX_SLAVE(2)) conn25 (.master(mx2), .slave(sx5));
   nasti_stream_connector # (.IDX_MASTER(6), .IDX_SLAVE(2)) conn26 (.master(mx2), .slave(sx6));
   nasti_stream_connector # (.IDX_MASTER(7), .IDX_SLAVE(2)) conn27 (.master(mx2), .slave(sx7));

   nasti_stream_connector # (.IDX_MASTER(0), .IDX_SLAVE(3)) conn30 (.master(mx3), .slave(sx0));
   nasti_stream_connector # (.IDX_MASTER(1), .IDX_SLAVE(3)) conn31 (.master(mx3), .slave(sx1));
   nasti_stream_connector # (.IDX_MASTER(2), .IDX_SLAVE(3)) conn32 (.master(mx3), .slave(sx2));
   nasti_stream_connector # (.IDX_MASTER(3), .IDX_SLAVE(3)) conn33 (.master(mx3), .slave(sx3));
   nasti_stream_connector # (.IDX_MASTER(4), .IDX_SLAVE(3)) conn34 (.master(mx3), .slave(sx4));
   nasti_stream_connector # (.IDX_MASTER(5), .IDX_SLAVE(3)) conn35 (.master(mx3), .slave(sx5));
   nasti_stream_connector # (.IDX_MASTER(6), .IDX_SLAVE(3)) conn36 (.master(mx3), .slave(sx6));
   nasti_stream_connector # (.IDX_MASTER(7), .IDX_SLAVE(3)) conn37 (.master(mx3), .slave(sx7));

   nasti_stream_connector # (.IDX_MASTER(0), .IDX_SLAVE(4)) conn40 (.master(mx4), .slave(sx0));
   nasti_stream_connector # (.IDX_MASTER(1), .IDX_SLAVE(4)) conn41 (.master(mx4), .slave(sx1));
   nasti_stream_connector # (.IDX_MASTER(2), .IDX_SLAVE(4)) conn42 (.master(mx4), .slave(sx2));
   nasti_stream_connector # (.IDX_MASTER(3), .IDX_SLAVE(4)) conn43 (.master(mx4), .slave(sx3));
   nasti_stream_connector # (.IDX_MASTER(4), .IDX_SLAVE(4)) conn44 (.master(mx4), .slave(sx4));
   nasti_stream_connector # (.IDX_MASTER(5), .IDX_SLAVE(4)) conn45 (.master(mx4), .slave(sx5));
   nasti_stream_connector # (.IDX_MASTER(6), .IDX_SLAVE(4)) conn46 (.master(mx4), .slave(sx6));
   nasti_stream_connector # (.IDX_MASTER(7), .IDX_SLAVE(4)) conn47 (.master(mx4), .slave(sx7));

   nasti_stream_connector # (.IDX_MASTER(0), .IDX_SLAVE(5)) conn50 (.master(mx5), .slave(sx0));
   nasti_stream_connector # (.IDX_MASTER(1), .IDX_SLAVE(5)) conn51 (.master(mx5), .slave(sx1));
   nasti_stream_connector # (.IDX_MASTER(2), .IDX_SLAVE(5)) conn52 (.master(mx5), .slave(sx2));
   nasti_stream_connector # (.IDX_MASTER(3), .IDX_SLAVE(5)) conn53 (.master(mx5), .slave(sx3));
   nasti_stream_connector # (.IDX_MASTER(4), .IDX_SLAVE(5)) conn54 (.master(mx5), .slave(sx4));
   nasti_stream_connector # (.IDX_MASTER(5), .IDX_SLAVE(5)) conn55 (.master(mx5), .slave(sx5));
   nasti_stream_connector # (.IDX_MASTER(6), .IDX_SLAVE(5)) conn56 (.master(mx5), .slave(sx6));
   nasti_stream_connector # (.IDX_MASTER(7), .IDX_SLAVE(5)) conn57 (.master(mx5), .slave(sx7));

   nasti_stream_connector # (.IDX_MASTER(0), .IDX_SLAVE(6)) conn60 (.master(mx6), .slave(sx0));
   nasti_stream_connector # (.IDX_MASTER(1), .IDX_SLAVE(6)) conn61 (.master(mx6), .slave(sx1));
   nasti_stream_connector # (.IDX_MASTER(2), .IDX_SLAVE(6)) conn62 (.master(mx6), .slave(sx2));
   nasti_stream_connector # (.IDX_MASTER(3), .IDX_SLAVE(6)) conn63 (.master(mx6), .slave(sx3));
   nasti_stream_connector # (.IDX_MASTER(4), .IDX_SLAVE(6)) conn64 (.master(mx6), .slave(sx4));
   nasti_stream_connector # (.IDX_MASTER(5), .IDX_SLAVE(6)) conn65 (.master(mx6), .slave(sx5));
   nasti_stream_connector # (.IDX_MASTER(6), .IDX_SLAVE(6)) conn66 (.master(mx6), .slave(sx6));
   nasti_stream_connector # (.IDX_MASTER(7), .IDX_SLAVE(6)) conn67 (.master(mx6), .slave(sx7));

   nasti_stream_connector # (.IDX_MASTER(0), .IDX_SLAVE(7)) conn70 (.master(mx7), .slave(sx0));
   nasti_stream_connector # (.IDX_MASTER(1), .IDX_SLAVE(7)) conn71 (.master(mx7), .slave(sx1));
   nasti_stream_connector # (.IDX_MASTER(2), .IDX_SLAVE(7)) conn72 (.master(mx7), .slave(sx2));
   nasti_stream_connector # (.IDX_MASTER(3), .IDX_SLAVE(7)) conn73 (.master(mx7), .slave(sx3));
   nasti_stream_connector # (.IDX_MASTER(4), .IDX_SLAVE(7)) conn74 (.master(mx7), .slave(sx4));
   nasti_stream_connector # (.IDX_MASTER(5), .IDX_SLAVE(7)) conn75 (.master(mx7), .slave(sx5));
   nasti_stream_connector # (.IDX_MASTER(6), .IDX_SLAVE(7)) conn76 (.master(mx7), .slave(sx6));
   nasti_stream_connector # (.IDX_MASTER(7), .IDX_SLAVE(7)) conn77 (.master(mx7), .slave(sx7));

endmodule
