module nasti_stream_mover # (
   parameter ADDR_WIDTH = 64,
   parameter DATA_WIDTH = 64,
   parameter MAX_BURST_LENGTH = 8
) (
   input  aclk,
   input  aresetn,
   nasti_channel.master        src,
   nasti_stream_channel.master dest,

   nasti_stream_channel.slave  command,

   input  r_valid,
   output logic r_ready
);

   localparam DATA_BYTE_CNT = DATA_WIDTH / 8;
   localparam ADDR_SHIFT    = $clog2(DATA_BYTE_CNT);
   localparam LEN_WIDTH     = ADDR_SHIFT + 16;

   // Structure of command. This depends on width of address.
   // If address is 46-bit, then this struct is 64 bit
   typedef struct packed unsigned {
      // Lowest ADDR_SHIFT bits are required to be zero
      logic [ADDR_WIDTH-1:ADDR_SHIFT] addr;
      // 16-bit length field
      logic [ LEN_WIDTH-1:ADDR_SHIFT] length;
      logic [6:0] reserved;
      logic last;
   } DataMoverReq;

   // States
   enum {
      STATE_IDLE,    // Default state
      STATE_COMMAND, // Waiting for NASTI Stream command input
      STATE_START,   // Start NASTI transaction
      STATE_READING  // Reading from NASTI
   } state;

   // Internal channel connected to buffer
   nasti_stream_channel # (
      .DATA_WIDTH (DATA_WIDTH)
   ) ch();

   // Internal values to track the transfer
   DataMoverReq req;

   // Internal buffer. We will only start new NASTI transaction
   // when buffer is empty to prevent deadlocks
   nasti_stream_buf # (
      .DATA_WIDTH (DATA_WIDTH),
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
   assign ch.t_last  = req.last && req.length == 0 ? src.r_last : 0;
   assign src.r_ready  = ch.t_ready;

   // We are ready to start when we are in IDLE state
   assign r_ready = state == STATE_IDLE;

   // We can receive command when we are in COMMAND state
   assign command.t_ready = state == STATE_COMMAND;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         state <= STATE_IDLE;

         src.ar_valid <= 0;
      end
      else if (state == STATE_IDLE) begin
         // IDLE state, r_ready is high
         // Waiting for r_valid, then we'll start accepting command
         if (r_valid) begin
            state <= STATE_COMMAND;
         end
      end
      else if (state == STATE_COMMAND) begin
         // COMMAND state, command.t_ready is high
         // Waiting for t_valid, then we'll start actual DMA
         if (command.t_valid) begin
            req <= command.t_data;
            state <= STATE_START;
         end
      end
      else if (state == STATE_START) begin
         // When the data moving request just starts
         // or when the last NASTI burst finished

         if (req.length == 0) begin
            // Finish the request
            state <= req.last ? STATE_IDLE : STATE_COMMAND;
         end
         else begin
            // Wait until buffer is empty
            if (!dest.t_valid) begin
               // Initialize a read burst
               src.ar_addr   <= {req.addr, {ADDR_SHIFT{1'b0}}};
               src.ar_valid  <= 1;

               if (req.length >= MAX_BURST_LENGTH) begin
                  src.ar_len   <= MAX_BURST_LENGTH -1;
                  req.length   <= req.length - MAX_BURST_LENGTH;
                  req.addr     <= req.addr   + MAX_BURST_LENGTH;
               end
               else begin
                  assert(0) else $warning("NASTI to NASTI-Stream Data Mover: Partial burst causes error in NASTI/TileLink converter");
                  src.ar_len   <= req.length - 1;
                  req.length   <= 0;
               end
               state <= STATE_READING;
            end
         end
      end else begin
         // ar fired
         if (src.ar_valid && src.ar_ready) begin
            src.ar_valid <= 0;
         end

         // Last byte of transfer, we will take control back
         if (src.r_valid && src.r_ready && src.r_last) begin
            state <= STATE_START;
         end
      end
   end

endmodule
