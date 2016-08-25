module dual_port_bram #(
    ADDR_WIDTH = 16,
    DATA_WIDTH = 32
) (
   input  wire                          clk_a,
   input  wire                          en_a,
   input  wire [(DATA_WIDTH / 8) - 1:0] we_a,
   input  wire [ADDR_WIDTH - 1:0]       addr_a,
   input  wire [DATA_WIDTH - 1:0]       write_a,
   output reg  [DATA_WIDTH - 1:0]       read_a,

   input  wire                          clk_b,
   input  wire                          en_b,
   input  wire [(DATA_WIDTH / 8) - 1:0] we_b,
   input  wire [ADDR_WIDTH - 1:0]       addr_b,
   input  wire [DATA_WIDTH - 1:0]       write_b,
   output reg  [DATA_WIDTH - 1:0]       read_b
);

reg [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];

always_ff @(posedge clk_a)
   if (en_a) begin
      read_a <= mem[addr_a];
      foreach(we_a[i]) if(we_a[i]) mem[addr_a][i*8+:8] <= write_a[i*8+:8];
   end

always_ff @(posedge clk_b)
   if (en_b) begin
      read_b <= mem[addr_b];
      foreach(we_b[i]) if(we_b[i]) mem[addr_b][i*8+:8] <= write_b[i*8+:8];
   end

initial begin
   foreach(mem[i]) mem[i] <= {DATA_WIDTH{1'b0}};
end

endmodule
