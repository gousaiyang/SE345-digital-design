module hamd(a, b, d);
	input  [31:0] a, b;
	output [31:0] d;

	wire   [31:0] c;

	assign c = a ^ b;
	assign d = c[31] + c[30] + c[29] + c[28] + c[27] + c[26] + c[25] + c[24]
		+ c[23] + c[22] + c[21] + c[20] + c[19] + c[18] + c[17] + c[16]
		+ c[15] + c[14] + c[13] + c[12] + c[11] + c[10] + c[9] + c[8]
		+ c[7] + c[6] + c[5] + c[4] + c[3] + c[2] + c[1] + c[0];
endmodule
