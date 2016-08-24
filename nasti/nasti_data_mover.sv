module nasti_data_mover # (
   parameter ADDR_WIDTH = 64,
   parameter DATA_WIDTH = 64,
   parameter MAX_BURST_LENGTH = 256
) (
   input  aclk,
   input  aresetn,
   // Do not use modport here, we are not using all of master connections
   nasti_channel src,
   nasti_channel dest,
   input  [ADDR_WIDTH-1:0] r_src,
   input  [ADDR_WIDTH-1:0] r_dest,
   input  [ADDR_WIDTH-1:0] r_len,
   input  r_valid,
   output logic r_ready
);

   localparam ADDR_SHIFT = $clog2(DATA_WIDTH / 8);

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

   assign dest.aw_id     = 0;
   assign dest.aw_size   = 3'b011;
   assign dest.aw_burst  = 2'b01;
   assign dest.aw_cache  = 4'b0;
   assign dest.aw_prot   = 3'b0;
   assign dest.aw_lock   = 1'b0;
   assign dest.aw_qos    = 4'b0;
   assign dest.aw_region = 4'b0;
   assign dest.aw_user   = 0;

   // Write channel of src, connect to zeros
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

   // Read channels of dest, connect to zeros
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

   // Connect dest.w to src.r directly
   // Note that a read error is not considered here
   assign dest.w_strb = 8'b11111111;
   assign dest.w_valid = src.r_valid;
   assign dest.w_data   = src.r_data;
   assign dest.w_last   = src.r_last;
   assign src.r_ready = dest.w_ready;

   // Once the task is started, these values shouldn't be changed from outside the module,
   // so latch it
   logic [63:0] src_addr, dest_addr, length;

   logic state_addr, state_wait, state_ready;
   logic src_ready, dest_ready;

   // Whether address will be ready for next cycle
   logic src_ar_fire, dest_aw_fire;
   assign src_ar_fire = src.ar_ready & src.ar_valid;
   assign dest_aw_fire = dest.aw_ready & dest.aw_valid;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         r_ready <= 1;

         src.ar_valid <= 0;
         dest.aw_valid <= 0;
         dest.b_ready <= 0;
      end
      else if (r_ready) begin
         if (r_valid) begin
            assert((r_src  & (DATA_WIDTH - 1)) == 0) else $error("Data mover request must be aligned");
            assert((r_dest & (DATA_WIDTH - 1)) == 0) else $error("Data mover request must be aligned");
            assert((r_len  & (DATA_WIDTH - 1)) == 0) else $error("Data mover request must be aligned");

            state_addr <= 1;
            src_addr   <= {r_src [ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};
            dest_addr  <= {r_dest[ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};
            length     <= {r_len [ADDR_WIDTH-1:ADDR_SHIFT], {ADDR_SHIFT{1'b0}}};
            r_ready    <= 0;
         end
      end
      else begin
         case (1'b1)
            state_addr: begin
               src.ar_addr   <= src_addr;
               src.ar_valid  <= 1;
               dest.aw_addr  <= dest_addr;
               dest.aw_valid <= 1;

               if ((length >> ADDR_SHIFT) > MAX_BURST_LENGTH) begin
                  // Max burst length is 256
                  src.ar_len     <= MAX_BURST_LENGTH - 1;
                  dest.aw_len    <= MAX_BURST_LENGTH - 1;
                  length         <= length    - (MAX_BURST_LENGTH << ADDR_SHIFT);
                  src_addr       <= src_addr  + (MAX_BURST_LENGTH << ADDR_SHIFT);
                  dest_addr      <= dest_addr + (MAX_BURST_LENGTH << ADDR_SHIFT);
               end
               else begin
                  src.ar_len   <= (length >> ADDR_SHIFT) - 1;
                  dest.aw_len  <= (length >> ADDR_SHIFT) - 1;
                  length       <= 0;
               end

               src_ready <= 0;
               dest_ready <= 0;

               // Transition to wait state
               state_addr <= 0;
               state_wait <= 1;
            end
            state_wait: begin
               if (src_ar_fire) begin
                  src.ar_valid <= 0;
                  src_ready    <= 1;
               end
               if (dest_aw_fire) begin
                  dest.aw_valid <= 0;
                  dest_ready    <= 1;
               end
               if ((src_ready || src_ar_fire) && (dest_ready || dest_aw_fire)) begin
                  state_wait   <= 0;
                  state_ready  <= 1;
                  dest.b_ready <= 1;
               end
            end
            state_ready: begin
               if (dest.b_valid) begin
                  dest.b_ready <= 0;
                  if (length == 0) begin
                     r_ready <= 1;
                  end
                  else begin
                     state_ready <= 0;
                     state_addr  <= 1;
                  end
               end
            end
         endcase
      end
   end

endmodule
