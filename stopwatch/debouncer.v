module debouncer(keyin, keyout);
	input      keyin;
	output reg keyout;
	reg        keyf, keyn;
	always @(keyin) begin
		keyf = 0;
		keyn = 1;
		while (keyf != keyn) begin
			keyf = keyin;
			#10000000 keyn = keyin;
		end
		keyout = keyf;
	end
endmodule
