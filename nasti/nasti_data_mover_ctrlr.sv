module data_mover_ctrlr # (
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64
) (
    input aclk,
    input aresetn,

    // From CPU to DM CTRLR
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
    output logic dm_en,

    // From DM to DM CTRLR
    input done

    );


    always_ff @(posedge aclk or negedge aresetn) begin
        busy <= !done;
        if (!aresetn) begin
            dm_en <= 0;
            busy <= 0;
        end
        else if (!dm_en) begin
            if (cpu_en) begin
                // PREP state
                src_addr_latch <= src_addr;
                dest_addr_latch <= dest_addr;
                length_latch <= length;
                dm_en <= 1;
            end
            // else -> IDLE state, waiting for input from CPU
        end
        // AWAIT state
        else if (!done) begin
            dm_en <= 0;
        end
    end

endmodule