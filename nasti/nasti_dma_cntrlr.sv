module nasti_dma_ctrlr # (
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter BUFF_SIZE = 32,
    parameter BUFF_WIDTH = ADDR_WIDTH*4 // direction + src_addr + dest_addr + length
) (
    input aclk,
    input aresetn,

    // From CPU to DM CTRLR
    input direction_in, // 0: a -> b, 1: b -> a
    input [ADDR_WIDTH-1:0] src_addr_in,
    input [ADDR_WIDTH-1:0] dest_addr_in,
    input [ADDR_WIDTH-1:0] length_in,
    input cpu_en,

    // From DM CTRL to CPU
    output logic full,
    output logic ack,

    // From DM CTRLR to DM
    output logic [ADDR_WIDTH-1:0] src_addr_out,
    output logic [ADDR_WIDTH-1:0] dest_addr_out,
    output logic [ADDR_WIDTH-1:0] length_out,
    output logic dm_en_a, // a -> b
    output logic dm_en_b, // b -> a

    // From DM to DM CTRLR
    input done_a,
    input done_b

    );

logic [BUFF_WIDTH-1:0] buffer [0:BUFF_SIZE-1];
logic [4:0] buff_read, elements;
logic busy, direction;
integer i;


logic [255:0] direction_read, src_addr_read, dest_addr_read, 
            length_read, direction_write, src_addr_write,
            dest_addr_write, length_write;

    always_ff @(posedge aclk or negedge aresetn) begin
        busy <= !done_a || !done_b;
        if (!aresetn) begin
            dm_en_a <= 0;
            dm_en_b <= 0;
            busy <= 0;

            for (i=0; i<BUFF_SIZE; i=i+1) buffer[i] <= 0;
            ack <= 0;
            buff_read <= 0;
            elements <= 0;
            full <= 0;

        end
        else if (!(dm_en_a || dm_en_b) && !busy && elements > 0) begin // not doing anything and have thigns to give
            // Read from buffer
            $display("Reading from buff position, %d", buff_read);

            direction <= buffer[buff_read][0];
            src_addr_out <= buffer [buff_read][2*ADDR_WIDTH - 1: ADDR_WIDTH];
            dest_addr_out <= buffer [buff_read][3*ADDR_WIDTH - 1: 2*ADDR_WIDTH];
            length_out <= buffer [buff_read][4*ADDR_WIDTH - 1: 3*ADDR_WIDTH];
            
            if (buffer[buff_read][0] == 0) begin // direction bit
                dm_en_a <= 1;
            end
            else begin 
                dm_en_b <= 1;
            end

            elements <= elements - 1;
            buff_read <= (buff_read + 1) % BUFF_SIZE;
        end
        else if (busy && (dm_en_a || dm_en_b)) begin 
            dm_en_a <= 0;
            dm_en_b <= 0;
        end
        else if (!(dm_en_a || dm_en_b) && cpu_en) begin
            // buff_write = buff_read + elements*BUFF_WIDTH
            $display("Adding to buff in position, %d", buff_read + elements);
            buffer[(buff_read + elements) % BUFF_SIZE][0] <= direction_in;
            buffer[(buff_read + elements) % BUFF_SIZE][2*ADDR_WIDTH - 1: ADDR_WIDTH] <= src_addr_in;
            buffer[(buff_read + elements) % BUFF_SIZE][3*ADDR_WIDTH - 1: 2*ADDR_WIDTH] <= dest_addr_in;
            buffer[(buff_read + elements) % BUFF_SIZE][4*ADDR_WIDTH - 1: 3*ADDR_WIDTH] <= length_in;
            ack <= 1;
            elements <= elements + 1;
        end
        else if (ack && !cpu_en) begin
            ack <= 0;
        end

        if (elements >= BUFF_SIZE) begin 
            full <= 1;
        end
        else begin 
            full <= 0;
        end

    end

endmodule
