module stream_nasti_mover # (
   parameter ADDR_WIDTH = 64,
   parameter DATA_WIDTH = 64,
   parameter MAX_BURST_LENGTH = 8
) (
   input  aclk,
   input  aresetn,
   nasti_stream_channel.slave src,
   nasti_channel.master       dest,

   input  w_valid,
   input  [ADDR_WIDTH-1:0] w_addr,
   input  [ADDR_WIDTH-1:0] w_len,
   output logic w_ready
);

   localparam DATA_BYTE_CNT = DATA_WIDTH / 8;
   localparam ADDR_SHIFT    = $clog2(DATA_BYTE_CNT);
   localparam LEN_WIDTH     = ADDR_SHIFT + 16;
   localparam BUF_SHIFT     = $clog2(MAX_BURST_LENGTH);

   // Internal values to track the transfer
   logic [ADDR_WIDTH-1:0] addr;
   logic [ADDR_WIDTH-1:0] len;

   // Buffer
   logic [DATA_WIDTH-1:0]   buffer [0:MAX_BURST_LENGTH-1];
   logic [DATA_WIDTH/8-1:0] strobe [0:MAX_BURST_LENGTH-1];
   logic [BUF_SHIFT:0] length, length_new, length_latch, ptr, ptr_new;

   // Current destination address, auto-incremented
   logic last_burst, last_burst_delay;

   // States
   enum {
      STATE_IDLE,
      STATE_START,
      STATE_ADDRESS,
      STATE_WRITE,
      STATE_RESP,
      STATE_ACK
   } state;

   // Channel fire status
   logic aw_fire, w_fire, b_fire, t_fire;

   // Unused fields, connect to constants
   assign dest.aw_id     = 0;
   assign dest.aw_size   = 3'b011;
   assign dest.aw_burst  = 2'b01;
   assign dest.aw_cache  = 4'b0;
   assign dest.aw_prot   = 3'b0;
   assign dest.aw_lock   = 1'b0;
   assign dest.aw_qos    = 4'b0;
   assign dest.aw_region = 4'b0;
   assign dest.aw_user   = 0;
   assign dest.w_user    = 0;

   // Read channels, connect to zeros
   assign dest.ar_id     = 0;
   assign dest.ar_addr   = 0;
   assign dest.ar_len    = 0;
   assign dest.ar_size   = 0;
   assign dest.ar_burst  = 0;
   assign dest.ar_lock   = 0;
   assign dest.ar_cache  = 0;
   assign dest.ar_prot   = 0;
   assign dest.ar_qos    = 0;
   assign dest.ar_region = 0;
   assign dest.ar_user   = 0;
   assign dest.ar_valid  = 0;
   assign dest.r_ready   = 0;

   assign aw_fire = dest.aw_ready & dest.aw_valid;
   assign w_fire  = dest.w_ready & dest.w_valid;
   assign b_fire  = dest.b_ready & dest.b_valid;
   assign t_fire  = src.t_ready & src.t_valid;

   assign length_new = t_fire && src.t_keep ? length + 1 : length;
   assign ptr_new    = w_fire ? ptr + 1 : ptr;

   assign w_ready = state == STATE_ACK;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         state <= STATE_IDLE;

         src.t_ready   <= 0;
         dest.aw_valid <= 0;
         dest.w_valid  <= 0;
         dest.b_ready  <= 0;
      end else case (state)
         STATE_IDLE: begin
            // IDLE state
            // Waiting for w_valid, then we'll start actual DMA
            // We will not set w_ready to high until we've finished the request
            if (w_valid) begin
               addr <= {w_addr[ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};
               len  <= {w_len [ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};

               last_burst       <= 0;
               last_burst_delay <= 0;

               // Clear buffer
               length   <= 0;
               ptr      <= 0;

               state       <= STATE_START;
               src.t_ready <= 1;
            end
         end
         STATE_START: begin
            if (t_fire || last_burst_delay || length == MAX_BURST_LENGTH) begin
               // Data byte, write to buffer
               if (t_fire && src.t_keep) begin
                  assert(&src.t_keep) else $error("NASTI-Stream to NASTI Data Mover: Mixed byte type not supported");

                  // Append to buffer
                  buffer[length] <= src.t_data;
                  strobe[length] <= src.t_strb;
               end

               if (last_burst_delay || t_fire && src.t_last) last_burst <= 1;

               if (length_new == MAX_BURST_LENGTH || length_new == (len >> ADDR_SHIFT) ||
                   last_burst_delay || t_fire && src.t_last) begin
                  // Stop receiving inputs
                  src.t_ready <= 0;

                  // Last null byte
                  if (length_new == 0)
                     state <= STATE_ACK;
                  else begin
                     assert (length_new == MAX_BURST_LENGTH) else $warning("NASTI-Stream to NASTI Data Mover: Partial burst causes error in NASTI/TileLink converter");

                     // Send a write request
                     dest.aw_valid <= 1;
                     dest.aw_addr  <= addr;
                     dest.aw_len   <= length_new - 1;

                     // Latch original length
                     // and set length = 0
                     // which will be used in write state
                     length_latch  <= length_new;
                     length        <= 0;

                     // Update internal destination address
                     addr          <= addr + (length_new << ADDR_SHIFT);
                     len           <= len  - (length_new << ADDR_SHIFT);

                     // Switch state, stop receiving more data from src.t
                     state        <= STATE_ADDRESS;
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
               dest.w_strb   <= strobe[0];
               dest.w_last   <= length_latch == 1;
               ptr           <= 1;

               // Switch state
               state         <= STATE_WRITE;
               dest.aw_valid <= 0;
               src.t_ready   <= last_burst || len == 0 ? 0 : 1;
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
                  dest.w_strb <= strobe[ptr];
                  dest.w_last <= ptr_new == length_latch;
                  ptr         <= ptr_new;
               end
            end

            // Set t_ready if we are continuing in STATE_WRITE
            // we have enough space, and when the package is not finished
            if (t_fire && src.t_last || last_burst_delay || last_burst || length_new == (len >> ADDR_SHIFT))
               src.t_ready <= 0;
            else if (w_fire && ptr == length_latch)
               src.t_ready <= 0;
            else
               src.t_ready <= length_new != ptr_new;

            if (t_fire) begin
               if (src.t_keep) begin
                  assert(&src.t_keep) else $error("NASTI-Stream to NASTI Data Mover: Mixed byte type not supported");

                  // Append to buffer
                  buffer[length] <= src.t_data;
                  strobe[length] <= src.t_strb;

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
               if (last_burst || len == 0)
                  state <= STATE_ACK;
               else begin
                  // Start next buffer-and-write cycle
                  state       <= STATE_START;
                  src.t_ready <= length != MAX_BURST_LENGTH && !last_burst_delay;
               end
            end
         end
         STATE_ACK: begin
            assert(w_valid) else $error("NASTI-Stream to NASTI Data Mover: w_valid should be asserted high");

            state <= STATE_IDLE;
         end
         default:
            assert(0) else $error("NASTI-Stream to NASTI Data Mover: Unexpected state");
      endcase
   end

endmodule
