module min_max_threshold(min, max, vin, vout);
	input  [31:0] min, max, vin;
	output [31:0] vout;

	assign vout = vin > min ? (vin < max ? vin : max) : min;
endmodule
