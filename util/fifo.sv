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
logic [WIDTH-1:0] buffer [0:2**DEPTH-1];
logic [DEPTH-1:0] readptr, readptr_next, writeptr;
logic [DEPTH-1:0] readptr_new, writeptr_new;

// Internal status
logic r_fire, w_fire;

// Function to move ring buffer pointer to next location
function [DEPTH-1:0] incr(input [DEPTH-1:0] ptr);
   incr = ptr == 2**DEPTH - 1 ? 0 : ptr + 1;
endfunction

assign r_fire = !empty & r_en;
assign w_fire = w_en & !full;

assign readptr_new = r_fire ? readptr_next : readptr;
assign writeptr_new = w_fire ? incr(writeptr) : writeptr;

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

      if (w_fire && writeptr == readptr_new)
         // Writing without buffer remaining
         // Pipe it to output directly
         r_data <= w_data;
      else if (r_fire)
         // Fetch read data from buffer
         r_data <= buffer[readptr_next];

      // Write into buffer
      if (w_fire)
         buffer[writeptr] <= w_data;
   end

endmodule
