module centisecond_clock(refclk, outclk);
	input      refclk;
	output reg outclk;
	reg [24:0] counter;
	parameter half_max = 249999;
	initial begin
		counter = 0;
		outclk = 0;
	end
	always @(posedge refclk) begin
		if (counter == half_max) begin
			counter = 0;
			outclk = ~outclk;
		end else begin
			counter = counter + 1;
		end
	end
endmodule
