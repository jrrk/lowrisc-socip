module data_mover_ctrlr # (
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64
) (
    input aclk,
    input aresetn,

    // From CPU to DM CTRLR
    input [ADDR_WIDTH-1:0] ddr_addr,
    input [ADDR_WIDTH-1:0] bram_addr,
    input [ADDR_WIDTH-1:0] length,
    input cpu_en,

    // From DM CTRL to CPU
    output logic busy,

    // From DM CTRLR to DM
    output logic [ADDR_WIDTH-1:0] ddr_addr_latch,
    output logic [ADDR_WIDTH-1:0] bram_addr_latch,
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
                ddr_addr_latch <= ddr_addr;
                bram_addr_latch <= bram_addr;
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