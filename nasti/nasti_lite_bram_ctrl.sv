module nasti_lite_bram_ctrl # (
	parameter ADDR_WIDTH = 64,
	parameter DATA_WIDTH = 32,
	parameter BRAM_ADDR_WIDTH = 16
) (
	input  s_nasti_aclk,
	input  s_nasti_aresetn,
	nasti_channel.slave s_nasti,

	output bram_clk,
	output bram_rst,
	output bram_en,
	output [DATA_WIDTH/8-1:0] bram_we,
	output [BRAM_ADDR_WIDTH-1:0] bram_addr,
	output [DATA_WIDTH-1:0] bram_wrdata,
	input  [DATA_WIDTH-1:0] bram_rddata
);

// Whether the BRAM controller is ready for R/W transaction
logic a_ready;

always_comb s_nasti.ar_ready = a_ready;
always_comb s_nasti.aw_ready = a_ready;

// Whether there is an inbound read transaction
logic inbound_read;

always_comb inbound_read = s_nasti.ar_ready & s_nasti.ar_valid;

// Whether there is an inbound write transaction
logic inbound_write;
logic inbound_write_data;

always_comb inbound_write = s_nasti.aw_ready & s_nasti.aw_valid;
always_comb inbound_write_data = s_nasti.w_ready & s_nasti.w_valid;

// Whether there is an pending write transaction
// caused by simultaneous read & wrtie transaction
logic pending_write;
logic [ADDR_WIDTH-1:0] pending_write_addr;

// Whether there is an pending read response
// we can only guarantee that BRAM data is available for one cycle
// So we need to cache the data
logic pending_read;
logic [DATA_WIDTH-1:0] pending_read_data;

// Wire BRAM clk and rst directly
assign bram_clk = s_nasti_aclk;
assign bram_rst = !s_nasti_aresetn;

// Activate bram_en when next state is read complete state or write complete state
// Except that when w_strb is 0, we will not enable it
assign bram_en = inbound_read | (inbound_write_data & |s_nasti.w_strb);

// Choose correct address depending on next state
assign bram_addr = inbound_read ? s_nasti.ar_addr : (inbound_write_data ? pending_write_addr : {BRAM_ADDR_WIDTH{1'bx}});

// Wire BRAM's R/W ports directly to AXI
assign s_nasti.r_data = pending_read ? pending_read_data : bram_rddata;
assign bram_wrdata = s_nasti.w_data;
assign bram_we = inbound_write_data ? s_nasti.w_strb : 0;

always_ff @(posedge s_nasti_aclk or negedge s_nasti_aresetn)
begin
	if (!s_nasti_aresetn) begin
		pending_write   <= 0;
		pending_read    <= 0;
		a_ready         <= 1;
		s_nasti.r_valid <= 0;
		s_nasti.w_ready <= 0;
		s_nasti.b_valid <= 0;
	end
	else if (a_ready) begin
		// Idle state
		
		if (inbound_read) begin
			if (inbound_write) begin
				// When read and write arrives together
				// We process read first and pend the write transaction
				pending_write      <= 1;
				pending_write_addr <= s_nasti.aw_addr;
			end
			
			a_ready <= 0;
			
			// BRAM should present valid data
			// in this time already, so set valid to high
			// Transition to read complete state
			s_nasti.r_valid <= 1;
			s_nasti.r_resp  <= 0;
		end
		else if (inbound_write) begin
			pending_write_addr <= s_nasti.aw_addr;
			
			a_ready <= 0;

			// Transition to write state
			s_nasti.w_ready <= 1;
		end
	end
	else if (s_nasti.r_valid) begin
		// Read complete state
		
		if (s_nasti.r_ready) begin
			s_nasti.r_valid <= 0;
			pending_read <= 0;

			if (pending_write) begin
				s_nasti.w_ready <= 1;
				pending_write   <= 0;
			end
			else begin				
				// Transition to idle state
				a_ready <= 1;
			end
		end
		else if(!pending_read) begin
			pending_read <= 1;
			pending_read_data <= bram_rddata;
		end
	end
	else if (s_nasti.w_ready) begin
		// Write state
		
		if (s_nasti.w_valid) begin
			s_nasti.w_ready <= 0;
			
			// BRAM should already finish writing the data
			// so set valid to high
			// Transition to write complete state
			s_nasti.b_valid <= 1;
			s_nasti.b_resp  <= 0;
		end
	end
	else if (s_nasti.b_valid) begin
		// Write complete state
		
		if (s_nasti.b_ready) begin
			s_nasti.b_valid <= 0;
			
			// Transition to idle state
			a_ready <= 1;
		end
	end
	else begin		
		// Transition to idle state otherwise
		a_ready <= 1;
	end
end

endmodule
