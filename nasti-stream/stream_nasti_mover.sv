module stream_nasti_mover # (
   parameter ADDR_WIDTH = 64,
   parameter DATA_WIDTH = 64,
   parameter MAX_BURST_LENGTH = 8
) (
   input  aclk,
   input  aresetn,
   nasti_stream_channel.slave src,
   // Do not use modport here, we are not using all of master connections
   nasti_channel dest,
   input  [ADDR_WIDTH-1:0] r_dest,
   input  r_valid,
   output logic r_ready
);

   localparam DATA_BYTE_CNT = DATA_WIDTH / 8;
   localparam ADDR_SHIFT    = $clog2(DATA_BYTE_CNT);
   localparam BUF_SHIFT     = $clog2(MAX_BURST_LENGTH);

   // Buffer
   logic [DATA_WIDTH-1:0] buffer [0:MAX_BURST_LENGTH-1];
   logic [BUF_SHIFT:0] length, length_new, length_latch, ptr, ptr_new;

   // Current destination address, auto-incremented
   logic [63:0] dest_addr;
   logic last_burst, last_burst_delay;

   // States
   enum {
      STATE_IDLE,
      STATE_ADDRESS,
      STATE_WRITE,
      STATE_RESP
   } state;

   // Channel fire status
   logic aw_fire, w_fire, b_fire, t_fire;

   // Unused fields, connect to constants
   assign dest.aw_id    = 0;
   assign dest.aw_size  = 3'b011;
   assign dest.aw_burst = 2'b01;
   assign dest.aw_cache = 4'b0;
   assign dest.aw_prot  = 3'b0;
   assign dest.aw_lock  = 1'b0;

   // Note: if data mover is only used in one direction
   // Use the following code to make sure the device
   // will not be affected by x's
   //
   // assign dest.ar_valid = 0;
   // assign dest.r_ready  = 0;

   assign dest.w_strb = {DATA_BYTE_CNT{1'b1}};

   assign aw_fire = dest.aw_ready & dest.aw_valid;
   assign w_fire  = dest.w_ready & dest.w_valid;
   assign b_fire  = dest.b_ready & dest.b_valid;
   assign t_fire  = src.t_ready & src.t_valid;

   assign length_new = t_fire && src.t_keep ? length + 1 : length;
   assign ptr_new    = w_fire ? ptr + 1 : ptr;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         r_ready <= 1;

         src.t_ready   <= 0;
         dest.aw_valid <= 0;
         dest.w_valid  <= 0;
         dest.b_ready  <= 0;
      end
      else if (r_ready) begin
         if (r_valid) begin
            assert((r_dest & (DATA_BYTE_CNT - 1)) == 0) else $error("NASTI-Stream to NASTI Data Mover: Request must be aligned");

            dest_addr  <= {r_dest[ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};
            r_ready    <= 0;

            last_burst       <= 0;
            last_burst_delay <= 0;

            // Clear buffer
            length   <= 0;
            ptr      <= 0;

            state       <= STATE_IDLE;
            src.t_ready <= 1;
         end
      end
      else begin
         case (state)
            STATE_IDLE: begin
               if (t_fire || last_burst_delay || length == MAX_BURST_LENGTH) begin
                  // Data byte, write to buffer
                  if (t_fire && src.t_keep) begin
                     assert(&src.t_keep) else $error("NASTI-Stream to NASTI Data Mover: Mixed byte type not supported");
                     assert(&src.t_strb) else $error("NASTI-Stream to NASTI Data Mover: Position byte not supported");

                     // Append to buffer
                     buffer[length] <= src.t_data;
                  end

                  if (last_burst_delay || t_fire && src.t_last) last_burst <= 1;

                  if (length_new == MAX_BURST_LENGTH || last_burst_delay || t_fire && src.t_last) begin
                     // Stop receiving inputs
                     src.t_ready <= 0;

                     // Last null byte
                     if (length_new == 0)
                        r_ready <= 1;
                     else begin
                        assert (length_new == MAX_BURST_LENGTH) else $warning("NASTI-Stream to NASTI Data Mover: Partial burst causes error in NASTI/TileLink converter");

                        // Send a write request
                        dest.aw_valid <= 1;
                        dest.aw_addr  <= dest_addr;
                        dest.aw_len   <= length;

                        // Latch original length
                        // and set length = 0
                        // which will be used in write state
                        length_latch  <= length_new;
                        length        <= 0;

                        // Update internal destination address
                        dest_addr     <= dest_addr + (length_new << ADDR_SHIFT);

                        // Switch state, stop receiving more data from src.t
                        state         <= STATE_ADDRESS;
                     end
                  end
                  else
                     length <= length_new;
               end
            end
            STATE_ADDRESS: begin
               if (aw_fire) begin
                  // Send first unit of data
                  dest.w_valid  <= 1;
                  dest.w_data   <= buffer[0];
                  dest.w_last   <= length_latch == 1;
                  ptr           <= 1;

                  // Switch state
                  state         <= STATE_WRITE;
                  dest.aw_valid <= 0;
                  src.t_ready   <= 1;
               end
            end
            STATE_WRITE: begin
               if (w_fire) begin
                  // Finish writing all data
                  if (ptr == length_latch) begin
                     dest.w_valid <= 0;
                     dest.b_ready <= 1;
                     state        <= STATE_RESP;
                  end
                  else begin
                     dest.w_data <= buffer[ptr];
                     dest.w_last <= ptr_new == length_latch;
                     ptr         <= ptr_new;
                  end
               end

               // Set t_ready if we are continuing in STATE_WRITE
               // we have enough space, and when the package is not finished
               if (t_fire && src.t_last || last_burst_delay || last_burst)
                  src.t_ready <= 0;
               else if (w_fire && ptr == length_latch)
                  src.t_ready <= 0;
               else
                  src.t_ready <= length_new != ptr_new;

               if (t_fire) begin
                  if (src.t_keep) begin
                     assert(&src.t_keep) else $error("NASTI-Stream to NASTI Data Mover: Mixed byte type not supported");
                     assert(&src.t_strb) else $error("NASTI-Stream to NASTI Data Mover: Position byte not supported");

                     // Append to buffer
                     buffer[length] <= src.t_data;

                     length <= length_new;
                  end

                  if (src.t_last) begin
                     last_burst_delay <= 1;
                  end
               end
            end
            STATE_RESP: begin
               if (b_fire) begin
                  dest.b_ready <= 0;
                  if (last_burst)
                     r_ready <= 1;
                  else begin
                     // Start next buffer-and-write cycle
                     state       <= STATE_IDLE;
                     src.t_ready <= length != MAX_BURST_LENGTH && !last_burst_delay;
                  end
               end
            end
            default:
               assert(0) else $error("NASTI-Stream to NASTI Data Mover: Unexpected state");
         endcase
      end
   end

endmodule
