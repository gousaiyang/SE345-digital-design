// Debounce a key on its posedge and negedge.
module debouncer(clk, keyin, keyout);
	input      clk, keyin;
	output reg keyout;
	reg        keyp;

	always @(posedge clk) begin
		if (keyp == keyin)
			keyout <= keyin;
		keyp <= keyin;
	end
endmodule
