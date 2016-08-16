module nasti_stream_mover # (
   parameter ADDR_WIDTH = 64,
   parameter DATA_WIDTH = 64,
   parameter MAX_BURST_LENGTH = 8
) (
   input  aclk,
   input  aresetn,
   // Do not use modport here, we are not using all of master connections
   nasti_channel src,
   nasti_stream_channel.master dest,
   input  [ADDR_WIDTH-1:0] r_src,
   input  [ADDR_WIDTH-1:0] r_len,
   input  r_valid,
   output logic r_ready
);
   localparam DATA_BYTE_CNT = DATA_WIDTH / 8;
   localparam ADDR_SHIFT    = $clog2(DATA_BYTE_CNT);

   nasti_stream_channel # (
      .DATA_WIDTH (DATA_WIDTH)
   ) ch();

   nasti_stream_buf # (
      .DATA_WIDTH (DATA_WIDTH),
      .BUF_SIZE (MAX_BURST_LENGTH)
   ) buffer (
      .aclk (aclk),
      .aresetn (aresetn),
      .src (ch),
      .dest (dest)
   );

   // Internal values to track the transfer
   logic [63:0] src_addr, length;
   logic transferring;

   // Unused fields, connect to constants
   assign src.ar_id    = 0;
   assign src.ar_size  = 3'b011;
   assign src.ar_burst = 2'b01;
   assign src.ar_cache = 4'b0;
   assign src.ar_prot  = 3'b0;
   assign src.ar_lock  = 1'b0;

   assign ch.t_id   = 0;
   assign ch.t_dest = 0;
   assign ch.t_user = 0;

   // Note: if data mover is only used in one direction
   // Use the following code to make sure the device
   // will not be affected by x's
   //
   // assign src.aw_valid = 0;
   // assign src.w_valid  = 0;
   // assign src.b_ready  = 0;

   // Connect ch.t to src.r directly
   // Note that a read error is not considered here
   assign ch.t_strb  = {DATA_BYTE_CNT{1'b1}};
   assign ch.t_keep  = {DATA_BYTE_CNT{1'b1}};
   assign ch.t_valid = src.r_valid;
   assign ch.t_data  = src.r_data;
   assign ch.t_last  = length == 0 ? src.r_last : 0;
   assign src.r_ready  = ch.t_ready;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         r_ready <= 1;

         src.ar_valid <= 0;
      end
      else if (r_ready) begin
         if (r_valid) begin
            assert((r_src  & (DATA_BYTE_CNT - 1)) == 0) else $error("Data mover request must be aligned");
            assert((r_len  & (DATA_BYTE_CNT - 1)) == 0) else $error("Data mover request must be aligned");

            transferring <= 0;
            src_addr     <= {r_src [ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};
            length       <= {r_len [ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};
            r_ready      <= 0;
         end
      end
      else begin
         if (!transferring || (src.r_valid && src.r_last && src.r_ready)) begin
            // When the data moving request just starts
            // or when the last NASTI transaction finished

            if (length == 0) begin
               // Finish the request
               r_ready <= 1;
            end
            else begin
               if (dest.t_valid)
                  // Wait until buffer is empty
                  transferring  <= 0;
               else begin
                  // Initialize a read burst
                  src.ar_addr   <= src_addr;
                  src.ar_valid  <= 1;

                  if ((length >> ADDR_SHIFT) > MAX_BURST_LENGTH) begin
                     src.ar_len     <= MAX_BURST_LENGTH -1;
                     length         <= length    - (MAX_BURST_LENGTH << ADDR_SHIFT);
                     src_addr       <= src_addr  + (MAX_BURST_LENGTH << ADDR_SHIFT);
                  end
                  else begin
                     src.ar_len   <= (length >> ADDR_SHIFT) - 1;
                     length       <= 0;
                  end
                  transferring = 1;
               end
            end
         end
         else if (src.ar_valid && src.ar_ready)
            src.ar_valid <= 0;
      end
   end

endmodule
