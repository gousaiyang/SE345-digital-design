// States:
//   0 -> initial, waiting for goal settings
//   1 -> waiting for difficulty settings
//   2 -> down counting, will soon enter game
//   3 -> game in process
//   4 -> successfully finished goal
//   5 -> failed to finish goal
//   6 -> scoreboard display
module number_game_main(clock, resetn, sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input         clock, resetn;
	input  [9:0]  sw;
	input  [3:1]  key;
	output [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0]  led;

	wire          second_clock, flash_clock;
	wire   [2:0]  prepare_downcount;
	wire   [3:0]  new_difficulty;
	wire   [4:0]  progress;
	wire   [6:0]  hex1_goal, hex0_goal;
	wire   [6:0]  hex1_diff, hex0_diff;
	wire   [6:0]  hex3_prepare, hex2_prepare;
	wire   [6:0]  hex5_score, hex4_score, hex3_number, hex2_number, hex1_number, hex0_number;
	wire   [9:0]  random;
	wire   [9:0]  led_welcome, led_progress, led_success;
	wire   [31:0] new_goal;
	reg           resetn_downcount, downcount_started, key3_last;
	reg    [2:0]  state;
	reg    [3:0]  difficulty;
	reg    [6:0]  goal, score;
	reg    [9:0]  number;

	parameter secclk_N = 50000000;
	parameter halfsecclk_N = 25000000;
	parameter code_off = 7'b1111111;
	parameter code_hf = 7'b0111111;
	parameter code_A = 7'b0001000;
	parameter code_C = 7'b1000110;
	parameter code_D = 7'b0100001;
	parameter code_F = 7'b0001110;
	parameter code_G = 7'b1000010;
	parameter code_I = 7'b1111001;
	parameter code_L = 7'b1000111;
	parameter code_O = 7'b1000000;
	parameter code_S = 7'b0010010;
	parameter code_U = 7'b1000001;
	parameter led_off = 10'b0000000000;
	parameter led_on = 10'b1111111111;

	wire key3 = key[3];
	wire key2 = key[2];
	wire key1 = key[1];

	clock_adjust sec_clk(clock, resetn_downcount, secclk_N, second_clock);
	clock_adjust halfsec_clk(clock, resetn, halfsecclk_N, flash_clock);

	display_welcome disp_welcome(flash_clock, resetn, led_welcome);
	min_max_threshold input_goal(1, 99, sw, new_goal);
	display_goal disp_goal(new_goal, hex1_goal, hex0_goal);

	min_max_threshold input_diff(1, 10, sw, new_difficulty);
	display_difficulty disp_diff(new_difficulty, hex1_diff, hex0_diff);

	downcount5 prep_downcount(second_clock, resetn_downcount, prepare_downcount);
	display_prepare disp_prep(prepare_downcount, hex3_prepare, hex2_prepare);

	rand10 rand_gen(clock, resetn, random);
	downcount_difficulty game_downcount(second_clock, resetn_downcount, difficulty, progress);
	display_score disp_score(score, hex5_score, hex4_score);
	display_number disp_num(number, hex3_number, hex2_number, hex1_number, hex0_number);
	display_progress disp_prog(progress, led_progress);

	display_success led_succ(flash_clock, resetn, led_success);

	mux8x7 select_hex5(code_G, code_D, code_hf, hex5_score, code_hf, code_hf, code_off, code_off, state, hex5);
	mux8x7 select_hex4(code_O, code_I, code_hf, hex4_score, code_S, code_F, code_off, code_off, state, hex4);
	mux8x7 select_hex3(code_A, code_F, hex3_prepare, hex3_number, code_U, code_A, code_off, code_off, state, hex3);
	mux8x7 select_hex2(code_L, code_F, hex2_prepare, hex2_number, code_C, code_I, code_off, code_off, state, hex2);
	mux8x7 select_hex1(hex1_goal, hex1_diff, code_hf, hex1_number, code_C, code_L, code_off, code_off, state, hex1);
	mux8x7 select_hex0(hex0_goal, hex0_diff, code_hf, hex0_number, code_hf, code_hf, code_off, code_off, state, hex0);
	mux8x10 select_led(led_welcome, led_welcome, led_on, led_progress, led_success, led_off, led_off, led_off, state, led);

	always @(posedge clock) begin
		if (!resetn || !key1) begin
			state <= 0;
			score <= 0;
			downcount_started <= 0;
			resetn_downcount <= 1;
			key3_last <= 1;
		end else if (state == 0) begin
			if (!key3) begin
				goal <= new_goal;
				state <= 1;
			end
		end else if (state == 1) begin
			if (!key3 && key3_last) begin
				difficulty <= new_difficulty;
				state <= 2;
			end
		end else if (state == 2) begin
			if (!resetn_downcount) begin
				resetn_downcount <= 1;
			end else if (!downcount_started) begin
				downcount_started <= 1;
				resetn_downcount <= 0;
			end else if (prepare_downcount == 0) begin
				state <= 3;
				number <= random;
				downcount_started <= 0;
			end
		end else if (state == 3) begin
			if (!resetn_downcount) begin
				resetn_downcount <= 1;
			end else if (!downcount_started) begin
				downcount_started <= 1;
				resetn_downcount <= 0;
			end else if (progress == 0) begin
				state <= 5;
			end else if (sw == number) begin
				score <= score + 1;
				if (score + 1 >= goal)
					state <= 4;
				else begin
					number <= random;
					downcount_started <= 0;
				end
			end
		end

		key3_last <= key3;
	end
endmodule
