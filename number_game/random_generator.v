module rand10(clock, resetn, random);
	input         clock, resetn;
	output [9:0]  random;
	wire   [31:0] counter;

	assign random = counter[14:5]; // Strip last 5 bits to get more evenly distributed result.

	cycles_counter cc(clock, resetn, counter);
endmodule
