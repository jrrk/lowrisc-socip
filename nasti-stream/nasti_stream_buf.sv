 module nasti_stream_buf # (
   ID_WIDTH   = 1,             // id width
   DEST_WIDTH = 1,             // destination width
   USER_WIDTH = 1,             // width of user
   DATA_WIDTH = 64,            // width of data
   BUF_SIZE   = 8              // size of buffer
) (
   input  aclk,
   input  aresetn,
   nasti_stream_channel.slave  src,
   nasti_stream_channel.master dest
);

localparam BUF_WIDTH = BUF_SIZE > 1 ? $clog2(BUF_SIZE) : 1;

// Ring buffer constructs
logic [DATA_WIDTH-1:0]   data_buf [0:BUF_SIZE-1];
logic [DATA_WIDTH/8-1:0] strb_buf [0:BUF_SIZE-1];
logic [DATA_WIDTH/8-1:0] keep_buf [0:BUF_SIZE-1];
logic                    last_buf [0:BUF_SIZE-1];
logic [ID_WIDTH-1:0]     id_buf   [0:BUF_SIZE-1];
logic [DEST_WIDTH-1:0]   dest_buf [0:BUF_SIZE-1];
logic [USER_WIDTH-1:0]   user_buf [0:BUF_SIZE-1];

logic [BUF_WIDTH-1:0] readptr, writeptr;
logic [BUF_WIDTH-1:0] readptr_new, writeptr_new;

// Internal status
logic full, empty;
logic r_fire, w_fire;

// Function to move ring buffer pointer to next location
function [BUF_WIDTH-1:0] incr(input [BUF_WIDTH-1:0] ptr);
   incr = ptr == BUF_SIZE - 1 ? 0 : ptr + 1;
endfunction

assign r_fire = dest.t_ready && dest.t_valid;
assign w_fire = src.t_ready && src.t_valid;

assign readptr_new = r_fire ? incr(readptr) : readptr;
assign writeptr_new = w_fire ? incr(writeptr) : writeptr;

assign dest.t_valid = !empty;
assign src.t_ready = !full;

always_ff @(posedge aclk or negedge aresetn)
   if (!aresetn) begin
      readptr <= 0;
      writeptr <= 0;
      full  <= 0;
      empty <= 1;
   end
   else begin
      readptr  <= readptr_new;
      writeptr <= writeptr_new;

      // Update empty & full from pointer
      if (readptr_new == writeptr_new) begin
         if (r_fire) begin
            empty <= 1;
            full  <= 0;
         end else if (w_fire) begin
            empty <= 0;
            full  <= 1;
         end
      end
      else begin
         empty <= 0;
         full <= 0;
      end

      if (w_fire && writeptr == readptr_new) begin
         // Writing without buffer remaining
         // Pipe it to output directly
         dest.t_data <= src.t_data;
         dest.t_strb <= src.t_strb;
         dest.t_keep <= src.t_keep;
         dest.t_last <= src.t_last;
         dest.t_id   <= src.t_id  ;
         dest.t_dest <= src.t_dest;
         dest.t_user <= src.t_user;
      end
      else begin
         // Fetch read data from buffer
         dest.t_data <= data_buf[readptr_new];
         dest.t_strb <= strb_buf[readptr_new];
         dest.t_keep <= keep_buf[readptr_new];
         dest.t_last <= last_buf[readptr_new];
         dest.t_id   <= id_buf  [readptr_new];
         dest.t_dest <= dest_buf[readptr_new];
         dest.t_user <= user_buf[readptr_new];
      end

      // Write into buffer
      if (w_fire) begin
         data_buf[writeptr] <= src.t_data;
         strb_buf[writeptr] <= src.t_strb;
         keep_buf[writeptr] <= src.t_keep;
         last_buf[writeptr] <= src.t_last;
         id_buf  [writeptr] <= src.t_id  ;
         dest_buf[writeptr] <= src.t_dest;
         user_buf[writeptr] <= src.t_user;
      end
   end

endmodule
