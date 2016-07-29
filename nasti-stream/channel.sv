// See LICENSE for license details.

// Define the SV interfaces for NASTI-Stream channels

interface nasti_stream_channel #(
   ID_WIDTH = 1,               // id width
   DEST_WIDTH = 1,             // destination width
   USER_WIDTH = 1,             // width of user
   DATA_WIDTH = 8              // width of data
);
   logic                    t_valid;
   logic                    t_ready;
   logic [DATA_WIDTH-1:0]   t_data;
   logic [DATA_WIDTH/8-1:0] t_strb;
   logic [DATA_WIDTH/8-1:0] t_keep;
   logic                    t_last;
   logic [ID_WIDTH-1:0]     t_id;
   logic [DEST_WIDTH-1:0]   t_dest;
   logic [USER_WIDTH-1:0]   t_user;

   modport master (
      output t_valid,
      input  t_ready,
      output t_data,
      output t_strb,
      output t_keep,
      output t_last,
      output t_id,
      output t_dest,
      output t_user
   );

   modport slave (
      input  t_valid,
      output t_ready,
      input  t_data,
      input  t_strb,
      input  t_keep,
      input  t_last,
      input  t_id,
      input  t_dest,
      input  t_user
   );

endinterface // nasti_channel

