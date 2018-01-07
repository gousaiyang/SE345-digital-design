module rand10(clock, resetn, random);
	input         clock, resetn;
	output [9:0]  random;
	wire   [31:0] counter;

	assign random = counter[9:0];

	cycles_counter cc(clock, resetn, counter);
endmodule
