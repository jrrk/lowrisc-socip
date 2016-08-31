module nasti_stream_mover # (
   ADDR_WIDTH = 64,
   DATA_WIDTH = 64,
   DEST_WIDTH = 1,
   USER_WIDTH = 1,
   MAX_BURST_LENGTH = 8
) (
   input  aclk,
   input  aresetn,
   nasti_channel.master        src,
   nasti_stream_channel.master dest,

   input  r_valid,
   input  [ADDR_WIDTH-1:0] r_addr,
   input  [ADDR_WIDTH-1:0] r_len,
   input  [DEST_WIDTH-1:0] r_dest,
   input  [USER_WIDTH-1:0] r_user,
   input  r_last,
   output logic r_ready
);

   localparam DATA_BYTE_CNT = DATA_WIDTH / 8;
   localparam ADDR_SHIFT    = $clog2(DATA_BYTE_CNT);

   // States
   enum {
      STATE_IDLE,    // Default state
      STATE_START,   // Start NASTI transaction
      STATE_READING, // Reading from NASTI
      STATE_ACK
   } state;

   // Internal channel connected to buffer
   nasti_stream_channel # (
      .DATA_WIDTH (DATA_WIDTH),
      .DEST_WIDTH (DEST_WIDTH),
      .USER_WIDTH (USER_WIDTH)
   ) ch();

   // Internal values to track the transfer
   logic [ADDR_WIDTH-1:0] addr;
   logic [ADDR_WIDTH-1:0] len;
   logic [DEST_WIDTH-1:0] t_dest;
   logic [USER_WIDTH-1:0] t_user;
   logic last;

   // Internal buffer. We will only start new NASTI transaction
   // when buffer is empty to prevent deadlocks
   nasti_stream_buf # (
      .DATA_WIDTH (DATA_WIDTH),
      .DEST_WIDTH (DEST_WIDTH),
      .USER_WIDTH (USER_WIDTH),
      .BUF_SIZE (MAX_BURST_LENGTH)
   ) buffer (
      .aclk (aclk),
      .aresetn (aresetn),
      .src (ch),
      .dest (dest)
   );

   // Unused fields, connect to constants
   assign src.ar_id     = 0;
   assign src.ar_size   = 3'b011;
   assign src.ar_burst  = 2'b01;
   assign src.ar_cache  = 4'b0;
   assign src.ar_prot   = 3'b0;
   assign src.ar_lock   = 1'b0;
   assign src.ar_qos    = 4'b0;
   assign src.ar_region = 4'b0;
   assign src.ar_user   = 0;
   assign ch.t_id       = 0;
   assign ch.t_dest     = 0;
   assign ch.t_user     = 0;

   // Write channels, connect to zeros
   assign src.aw_id     = 0;
   assign src.aw_addr   = 0;
   assign src.aw_len    = 0;
   assign src.aw_size   = 0;
   assign src.aw_burst  = 0;
   assign src.aw_lock   = 0;
   assign src.aw_cache  = 0;
   assign src.aw_prot   = 0;
   assign src.aw_qos    = 0;
   assign src.aw_region = 0;
   assign src.aw_user   = 0;
   assign src.aw_valid  = 0;
   assign src.w_data    = 0;
   assign src.w_strb    = 0;
   assign src.w_last    = 0;
   assign src.w_user    = 0;
   assign src.w_valid   = 0;
   assign src.b_ready   = 0;

   // Connect ch.t to src.r directly
   // Note that a read error is not considered here
   assign ch.t_strb  = {DATA_BYTE_CNT{1'b1}};
   assign ch.t_keep  = {DATA_BYTE_CNT{1'b1}};
   assign ch.t_valid = src.r_valid;
   assign ch.t_data  = src.r_data;
   assign ch.t_last  = last && len == 0 ? src.r_last : 0;
   assign ch.t_dest  = t_dest;
   assign ch.t_user  = t_user;

   assign src.r_ready = ch.t_ready;

   // We are ready to start when we are in IDLE state
   assign r_ready = state == STATE_ACK;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         state <= STATE_IDLE;

         src.ar_valid <= 0;
      end
      else case (state)
         STATE_IDLE: begin
            // IDLE state
            // Waiting for r_valid, then we'll start actual DMA
            // We will set r_ready to high only after finishing
            if (r_valid) begin
               assert((r_addr & (DATA_BYTE_CNT - 1)) == 0) else $error("Data mover request must be aligned");
               assert((r_len  & (DATA_BYTE_CNT - 1)) == 0) else $error("Data mover request must be aligned");

               addr   <= {r_addr[ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};
               len    <= {r_len [ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};
               t_dest <= r_dest;
               t_user <= r_user;
               last   <= r_last;
               state  <= STATE_START;
            end
         end
         STATE_START: begin
            // When the data moving request just starts
            // or when the last NASTI burst finished

            if (!dest.t_valid) begin
               // Buffer not cleared yet if t_valid is high

               if (len == 0) begin
                  // Finish the request
                  state <= STATE_ACK;
               end else begin
                   // Initialize a read burst
                  src.ar_addr   <= addr;
                  src.ar_valid  <= 1;

                  if ((len >> ADDR_SHIFT) >= MAX_BURST_LENGTH) begin
                     src.ar_len   <= MAX_BURST_LENGTH -1;
                     len          <= len  - (MAX_BURST_LENGTH << ADDR_SHIFT);
                     addr         <= addr + (MAX_BURST_LENGTH << ADDR_SHIFT);
                  end
                  else begin
                     assert(0) else $warning("NASTI to NASTI-Stream Data Mover: Partial burst causes error in NASTI/TileLink converter");
                     src.ar_len   <= (len >> ADDR_SHIFT) - 1;
                     len          <= 0;
                  end
                  state <= STATE_READING;
               end
            end
         end
         STATE_READING: begin
            // ar fired
            if (src.ar_valid && src.ar_ready) begin
               src.ar_valid <= 0;
            end

            // Last byte of transfer, we will take control back
            if (src.r_valid && src.r_ready && src.r_last) begin
               state <= STATE_START;
            end
         end
         STATE_ACK: begin
            assert(r_valid) else $error("NASTI to NASTI-Stream Data Mover: r_valid should be asserted high");

            state <= STATE_IDLE;
         end
      endcase
   end

endmodule
