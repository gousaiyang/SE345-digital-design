// 32bit D flip-flop with an enable signal for PC.
module dffe32pc(d, clk, clrn, e, q);
	input      [31:0] d;
	input             clk, clrn, e;
	output reg [31:0] q;

	always @(negedge clrn or posedge clk)
		if (clrn == 0) begin
			q <= -4; // Make sure instruction at address 0 will be properly executed.
		end else begin
			if (e == 1)
				q <= d;
		end
endmodule
