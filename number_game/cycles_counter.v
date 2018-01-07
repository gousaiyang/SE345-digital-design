module cycles_counter(clock, resetn, counter);
	input             clock, resetn;
	output reg [31:0] counter;

	initial begin
		counter <= 0;
	end

	always @(posedge clock or negedge resetn) begin
		if (!resetn)
			counter <= 0;
		else
			counter <= counter + 1;
	end
endmodule
