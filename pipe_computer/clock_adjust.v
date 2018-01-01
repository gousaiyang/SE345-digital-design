// Generate a clock whose period is N times the period of the reference clock.
module clock_adjust(refclk, resetn, outclk);
	input      refclk, resetn;
	output reg outclk;
	reg [31:0] counter;
	parameter N = 50000000;

	initial begin
		counter <= 0;
		outclk <= 0;
	end

	always @(posedge refclk or negedge resetn) begin
		if (!resetn) begin
			counter <= 0;
			outclk <= 0;
		end
		else begin
			if (counter >= N / 2 - 1) begin
				counter <= 0;
				outclk <= ~outclk;
			end
			else
				counter <= counter + 1;
		end
	end
endmodule
