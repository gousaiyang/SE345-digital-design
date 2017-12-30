// Generate a clock whose period is twice the period of the reference clock.
module clock_2T(inclk, outclk);
	input      inclk;
	output reg outclk;

	initial begin
		outclk <= 0;
	end

	always @(posedge inclk)
		outclk <= ~outclk;
endmodule
