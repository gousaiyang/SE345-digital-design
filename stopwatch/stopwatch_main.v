module show_counting_status(time_counter, counting, led);
	input [18:0] time_counter;
	input        counting;
	output [9:0] led;
	assign led = counting ? 1 << (9 - time_counter / 100 % 10) : 0;
endmodule

module show_time(time_display, hex5, hex4, hex3, hex2, hex1, hex0);
	input [18:0] time_display;
	output [6:0] hex5, hex4, hex3, hex2, hex1, hex0;
	sevenseg_decimal(time_display / 60000, hex5);
	sevenseg_decimal(time_display / 6000 % 10, hex4);
	sevenseg_decimal(time_display % 6000 / 1000, hex3);
	sevenseg_decimal(time_display / 100 % 10, hex2);
	sevenseg_decimal(time_display % 100 / 10, hex1);
	sevenseg_decimal(time_display % 10, hex0);
endmodule

module stopwatch_main(clk, key3, key2, key1, key0, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input         clk, key3, key2, key1, key0;
	output [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0]  led;
	wire          status_clk;
	reg    [18:0] time_counter, time_display;
	reg           counting, paused, freeze_display, mem_op;
	// reg    [31:0] record_cnt, record_datain;
	// wire   [31:0] record_dataout;
	parameter max_time = 360000 - 1;
	initial begin
		time_counter = 0;
		time_display = 0;
		counting = 0;
		paused = 0;
		freeze_display = 0;
		// mem_op = 0;
		// record_cnt = 0;
		// record_datain = 0;
	end
	show_time(time_display, hex5, hex4, hex3, hex2, hex1, hex0);
	show_counting_status(time_counter, counting, led);
	// memory(mem_op, record_cnt, record_datain, record_dataout);
	always @(negedge key3)
		counting = ~counting;
	always @(negedge key2 or negedge key3)
		paused = !key3 ? 0 : ~paused; // Cannot write `key3 ? ~paused : 0`!
	always @(negedge key1 or negedge key0 or negedge key3) begin
		if (!key3)
			freeze_display = 0;
		else if (!key0)
			freeze_display = counting && !paused ? 0 : freeze_display;
		else if (counting && !paused)
			freeze_display = 1;
	end
	always @(posedge clk or negedge key3 or negedge key1) begin
		if (!key3) begin
			time_counter = 0;
			time_display = 0;
			// record_cnt = 0;
		end
		else if (!key1) begin
			if (counting && !paused)
				time_display = time_counter;
		end
		else begin
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
