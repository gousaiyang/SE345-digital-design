// Show current status (counting / stopped) on LED.
module show_counting_status(time_counter, counting, led);
	input [18:0] time_counter;
	input        counting;
	output [9:0] led;

	// When stopped, all LEDs off.
	// When counting, LED light spot moves to the right every second.
	// When paused, LED light spot stays at the original position.
	assign led = counting ? 1 << (9 - time_counter / 100 % 10) : 0;
endmodule

// Display time on sevensegs.
module show_time(time_display, hex5, hex4, hex3, hex2, hex1, hex0);
	input [18:0] time_display;
	output [6:0] hex5, hex4, hex3, hex2, hex1, hex0;

	// Minutes.
	sevenseg_decimal(time_display / 60000, hex5);
	sevenseg_decimal(time_display / 6000 % 10, hex4);

	// Seconds.
	sevenseg_decimal(time_display % 6000 / 1000, hex3);
	sevenseg_decimal(time_display / 100 % 10, hex2);

	// Centiseconds.
	sevenseg_decimal(time_display % 100 / 10, hex1);
	sevenseg_decimal(time_display % 10, hex0);
endmodule

// Main module.
// Key usage:
//     key3: Start / Stop counting (stop will reset counter).
//     key2: Pause / Resume counting.
//     key1: Pause display updating (but counting is still in process), display current time value and freeze.
//     key0: Resume display updating.
//     When stopped, key2, key1 and key0 will be disabled.
//     When paused, key1 and key0 will be disabled.
module stopwatch_main(clk, key3, key2, key1, key0, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input         clk, key3, key2, key1, key0;
	output [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0]  led;
	reg    [18:0] time_counter, time_display;
	reg           counting, paused, freeze_display;
	parameter max_time = 360000 - 1;

	initial begin
		time_counter = 0;
		time_display = 0;
		counting = 0;
		paused = 0;
		freeze_display = 0;
	end

	show_time(time_display, hex5, hex4, hex3, hex2, hex1, hex0);
	show_counting_status(time_counter, counting, led);

	always @(negedge key3)
		counting = ~counting;

	always @(negedge key3 or negedge key2)
		paused = !key3 ? 0 : ~paused; // Cannot write as `key3 ? ~paused : 0`!

	always @(negedge key3 or negedge key1 or negedge key0) begin
		if (!key3)
			freeze_display = 0;
		else if (!key0)
			freeze_display = counting && !paused ? 0 : freeze_display;
		else if (counting && !paused) // key1 pressed
			freeze_display = 1;
	end

	always @(posedge clk or negedge key3 or negedge key1) begin
		if (!key3) begin
			time_counter = 0;
			time_display = 0;
		end
		else if (!key1) begin // begin-end required here!
			if (counting && !paused)
				time_display = time_counter;
		end
		else begin // clk posedge
			if (counting && !paused) begin
				time_counter = time_counter == max_time ? 0 : time_counter + 1;
				if (!freeze_display)
					time_display = time_counter;
			end
			else if (!counting)
				time_display = 0;
		end
	end
endmodule
