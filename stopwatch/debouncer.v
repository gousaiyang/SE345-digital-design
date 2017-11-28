// Debounce a key on its posedge and negedge.
module debouncer(clk, keyin, keyout);
	input      clk, keyin;
	output reg keyout;
	reg        keyp;

	always @(posedge clk) begin // Check on every clk posedge (10ms).
		if (keyp == keyin) // Propagate value when last value and current value is consistent.
			keyout <= keyin;
		keyp <= keyin;
	end
endmodule
