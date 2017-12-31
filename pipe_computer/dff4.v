// 4bit D flip-flop.
module dff4(d, clk, clrn, q);
	input      [3:0] d;
	input            clk, clrn;
	output reg [3:0] q;

	always @(negedge clrn or posedge clk)
		if (clrn == 0) begin
			q <= 0;
		end else begin
			q <= d;
		end
endmodule
