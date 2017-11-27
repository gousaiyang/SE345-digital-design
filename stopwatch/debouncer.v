// Debounce a key on its posedge and negedge.
module debouncer(keyin, keyout);
	input      keyin;
	output reg keyout;
	reg        keyf, keyn;

	always @(keyin) begin
		keyf = 0;
		keyn = 1;
		// Check until key state is consistent after 10ms.
		while (keyf != keyn) begin
			keyf = keyin;
			#10000000 keyn = keyin;
		end
		keyout = keyf;
	end
endmodule
