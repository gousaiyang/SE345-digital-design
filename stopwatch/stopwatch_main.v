module status_clock(refclk, counting, paused, reset, outclk);
	input      refclk, counting, paused, reset;
	output reg outclk;
	reg [5:0]  counter;
	parameter half_max = 49;
	initial begin
		outclk = 1;
		counter = 0;
	end
	always @(posedge refclk or negedge reset) begin
		if (!reset)
			counter = 0;
		else if (counting && !paused) begin
			if (counter == half_max) begin
				counter = 0;
				outclk = ~outclk;
			end
			else
				counter = counter + 1;
		end
	end

endmodule

module show_counting_status(status_clk, counting, reset, led);
	input        status_clk, counting, reset;
	output [9:0] led;
	reg    [3:0] pos;
	parameter max_pos = 9;
	initial begin
		pos = max_pos;
	end
	assign led = counting ? 1 << pos : 0;
	always @(posedge status_clk or negedge reset) begin
		if (!reset)
			pos = max_pos;
		else
			pos = pos ? pos - 1 : max_pos;
	end
endmodule

module show_time(time_counter, hex5, hex4, hex3, hex2, hex1, hex0);
	input [18:0] time_counter;
	output [6:0] hex5, hex4, hex3, hex2, hex1, hex0;
	sevenseg_decimal(time_counter / 60000, hex5);
	sevenseg_decimal(time_counter / 6000 % 10, hex4);
	sevenseg_decimal(time_counter % 6000 / 1000, hex3);
	sevenseg_decimal(time_counter / 100 % 10, hex2);
	sevenseg_decimal(time_counter % 100 / 10, hex1);
	sevenseg_decimal(time_counter % 10, hex0);
endmodule

module stopwatch_main(clk, key3, key2, key1, key0, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input         clk, key3, key2, key1, key0;
	output [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0]  led;
	wire          status_clk;
	reg    [18:0] time_counter;
	reg           counting, paused;
	parameter max_time = 359999;
	initial begin
		time_counter = 0;
		counting = 0;
		paused = 0;
	end
	show_time(time_counter, hex5, hex4, hex3, hex2, hex1, hex0);
	status_clock(clk, counting, paused, key3, status_clk);
	show_counting_status(status_clk, counting, key3, led); // Still buggy. Sometimes not synchonized.
	always @(negedge key3)
		counting = ~counting;
	always @(negedge key2 or negedge key3)
		paused = !key3 ? 0 : ~paused; // Cannot write `key3 ? ~paused : 0`!
	always @(posedge clk or negedge key3) begin
		if (!key3)
			time_counter = 0;
		else begin
			if (counting && !paused)
				time_counter = time_counter == max_time ? 0 : time_counter + 1;
		end
	end
endmodule
