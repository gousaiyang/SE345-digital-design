module display_score(score, hex5, hex4);
	input  [6:0] score;
	output [6:0] hex5, hex4;

	sevenseg_decimal disp5(score / 10, hex5);
	sevenseg_decimal disp4(score % 10, hex4);
endmodule

module display_number(number, hex3, hex2, hex1, hex0);
	input  [9:0] number;
	output [6:0] hex3, hex2, hex1, hex0;

	sevenseg_decimal disp3(number / 1000, hex3);
	sevenseg_decimal disp2(number % 1000 / 100, hex2);
	sevenseg_decimal disp1(number % 100 / 10, hex1);
	sevenseg_decimal disp0(number % 10, hex0);
endmodule

module display_progress(progress, led);
	input  [4:0] progress;
	output [9:0] led;

	assign led = ~((1 << (10 - progress)) - 1);
endmodule

module number_game_main(clock, resetn, sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input        clock, resetn;
	input  [9:0] sw;
	input  [3:1] key;
	output [6:0] hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0] led;

	wire   [9:0] random;
	wire         second_clock;
	wire   [6:0] score_hex5, score_hex4, number_hex3, number_hex2, number_hex1, number_hex0;
	reg          resetn_secclk;
	reg    [2:0] state;
	reg    [6:0] score;
	reg    [9:0] number;
	wire   [4:0] progress;
	reg          downcount_started;
	reg    [3:0] difficulty;
	wire   [9:0] progress_led;
	parameter secclk_N = 50000000;
	parameter default_difficulty = 1; // 5
	parameter code_off = 7'b1111111;
	parameter code_hf = 7'b0111111;
	parameter code_F = 7'b0001110;
	parameter code_A = 7'b0001000;
	parameter code_I = 7'b1111001;
	parameter code_L = 7'b1000111;
	parameter led_off = 10'b0000000000;

	wire key3 = key[3];

	clock_adjust sec_clk(clock, resetn_secclk, secclk_N, second_clock);
	rand10 rand_gen(clock, resetn, random);
	display_score disp_score(score, score_hex5, score_hex4);
	display_number disp_num(number, number_hex3, number_hex2, number_hex1, number_hex0);
	display_progress disp_prog(progress, progress_led);
	mux8x7 select_hex5(code_off, code_off, code_off, score_hex5, code_off, code_hf, code_off, code_off, state, hex5);
	mux8x7 select_hex4(code_off, code_off, code_off, score_hex4, code_off, code_F, code_off, code_off, state, hex4);
	mux8x7 select_hex3(code_off, code_off, code_off, number_hex3, code_off, code_A, code_off, code_off, state, hex3);
	mux8x7 select_hex2(code_off, code_off, code_off, number_hex2, code_off, code_I, code_off, code_off, state, hex2);
	mux8x7 select_hex1(code_off, code_off, code_off, number_hex1, code_off, code_L, code_off, code_off, state, hex1);
	mux8x7 select_hex0(code_off, code_off, code_off, number_hex0, code_off, code_hf, code_off, code_off, state, hex0);
	mux8x10 select_led(led_off, led_off, led_off, progress_led, led_off, led_off, led_off, led_off, state, led);
	downcount_difficulty game_downcount(second_clock, resetn_secclk, difficulty, progress);

	always @(posedge clock) begin
		if (!resetn) begin
			state <= 3;
			score <= 0;
			downcount_started <= 0;
			resetn_secclk <= 1;
			difficulty <= default_difficulty;
			number <= random;
		end else if (state == 3) begin
			if (!resetn_secclk) begin
				resetn_secclk <= 1;
			end else if (!downcount_started) begin
				downcount_started <= 1;
				resetn_secclk <= 0;
			end else if (progress == 0) begin
				state <= 5;
			end else if (sw == number) begin
				score <= score + 1;
				number <= random;
				downcount_started <= 0;
			end
		end
	end
endmodule
