module downcount3_flash(halfsecclk, resetn, counter, status);
	input            halfsecclk, resetn;
	output reg [2:0] counter;
	output           status;

	assign status = !(counter % 2);

	always @(posedge halfsecclk or negedge resetn) begin
		if (!resetn)
			counter <= 6;
		else if (counter > 0)
			counter <= counter - 1;
	end
endmodule

module downcount5(secclk, resetn, counter);
	input            secclk, resetn;
	output reg [2:0] counter;

	always @(posedge secclk or negedge resetn) begin
		if (!resetn)
			counter <= 5;
		else if (counter > 0)
			counter <= counter - 1;
	end
endmodule

module downcount_difficulty(secclk, resetn, difficulty, progress);
	input             secclk, resetn;
	input      [3:0]  difficulty;
	output reg [4:0]  progress;
	reg        [31:0] counter;

	always @(posedge secclk or negedge resetn) begin
		if (!resetn) begin
			counter <= 10 * difficulty;
			progress <= 10;
		end else if (counter > 0) begin
			counter <= counter - 1;
			progress <= (counter - 1 + difficulty - 1) / difficulty;
		end
	end
endmodule
