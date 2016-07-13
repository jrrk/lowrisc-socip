module dma_ctrlr # (
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64
) (
    input aclk,
    input aresetn,

    // From CPU to DM CTRLR
    input direction, // 0: a -> b, 1: b -> a
    input [ADDR_WIDTH-1:0] src_addr,
    input [ADDR_WIDTH-1:0] dest_addr,
    input [ADDR_WIDTH-1:0] length,
    input cpu_en,

    // From DM CTRL to CPU
    output logic busy,

    // From DM CTRLR to DM
    output logic [ADDR_WIDTH-1:0] src_addr_latch,
    output logic [ADDR_WIDTH-1:0] dest_addr_latch,
    output logic [ADDR_WIDTH-1:0] length_latch,
    output logic dm_en_a, // a -> b
    output logic dm_en_b, // b -> a

    // From DM to DM CTRLR
    input done_a,
    input done_b

    );

    always_ff @(posedge aclk or negedge aresetn) begin
        busy <= !done_a || !done_b;
        if (!aresetn) begin
            dm_en_a <= 0;
            dm_en_b <= 0;
            busy <= 0;
        end
        else if (!dm_en_a && !dm_en_b) begin
            if (cpu_en) begin 
                // PREP state
                src_addr_latch <= src_addr;
                dest_addr_latch <= dest_addr;
                length_latch <= length;

                if (!direction) begin 
                    dm_en_a <= 1;
                end
                else begin 
                    dm_en_b <= 1;
                end
            end
            // else -> IDLE state, waiting for input from CPU
        end
        if (!done_a) begin 
            dm_en_a <= 0;
        end
        if (!done_b) begin 
            dm_en_b <= 0;
        end
    end

endmodule
