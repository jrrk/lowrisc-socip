module fifo # (
   WIDTH = 1,
   DEPTH = 1
) (
   input  aclk,
   input  aresetn,
   input  w_en,
   input  [WIDTH-1:0] w_data,
   input  r_en,
   output logic [WIDTH-1:0] r_data,
   output logic full,
   output logic empty
);

// Ring buffer constructs
logic [DEPTH-1:0] readptr, readptr_next, writeptr;
logic [DEPTH-1:0] readptr_new, writeptr_new;

// Internal status
logic r_fire, w_fire;

logic r_use_latch;
logic [WIDTH-1:0] r_data_latch, r_data_read;

dual_port_bram # (
   .DATA_WIDTH (WIDTH),
   .ADDR_WIDTH (DEPTH)
) buffer (
   .clk_a   (aclk),
   .en_a    (r_fire && !(w_fire && writeptr == readptr_new)),
   .we_a    ('0),
   .addr_a  (readptr_next),
   .write_a ('0),
   .read_a  (r_data_read),

   .clk_b   (aclk),
   .en_b    (w_fire),
   .we_b    ('1),
   .addr_b  (writeptr),
   .write_b (w_data),
   .read_b  ()
);

// Function to move ring buffer pointer to next location
function [DEPTH-1:0] incr(input [DEPTH-1:0] ptr);
   incr = ptr == 2**DEPTH - 1 ? 0 : ptr + 1;
endfunction

assign r_fire = !empty & r_en;
assign w_fire = w_en & !full;

assign readptr_new = r_fire ? readptr_next : readptr;
assign writeptr_new = w_fire ? incr(writeptr) : writeptr;

assign r_data = r_use_latch ? r_data_latch : r_data_read;

always_ff @(posedge aclk or negedge aresetn)
   if (!aresetn) begin
      readptr <= 0;
      readptr_next <= 1;
      writeptr <= 0;
      full  <= 0;
      empty <= 1;
   end
   else begin
      readptr  <= readptr_new;
      readptr_next <= incr(readptr_new);
      writeptr <= writeptr_new;

      // Update empty & full from pointer
      if (readptr_new == writeptr_new) begin
         if (r_fire) empty <= 1;
         if (w_fire) full  <= 1;
      end
      else begin
         empty <= 0;
         full <= 0;
      end

      if (w_fire && writeptr == readptr_new) begin
         // Writing without buffer remaining
         // Pipe it to output directly
         r_data_latch <= w_data;
         r_use_latch <= 1;
      end
      else if (r_fire) begin
         // Fetch read data from buffer
         r_use_latch <= 0;
      end
   end

endmodule
