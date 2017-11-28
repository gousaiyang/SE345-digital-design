// Generate a 100Hz clock with the on-board 50MHz clock.
module centisecond_clock(refclk, outclk);
	input      refclk;
	output reg outclk;
	reg [24:0] counter;
	parameter half_max = 500000 / 2 - 1;

	// Initial block is only used for simulation, but the initial value here does not matter.
	initial begin
		counter <= 0;
		outclk <= 0;
	end

	always @(posedge refclk) begin
		if (counter >= half_max) begin
			counter <= 0;
			outclk <= ~outclk;
		end
		else
			counter <= counter + 1;
	end
endmodule
