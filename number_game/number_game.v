// States:
//   0 -> initial, waiting for goal settings
//   1 -> waiting for difficulty settings
//   2 -> down counting, will soon enter game
//   3 -> game in process
//   4 -> pass one level, show "pass" flash effect
//   5 -> successfully finished goal
//   6 -> failed to finish goal
//   7 -> scoreboard display
module number_game_main(clock, resetn, sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input         clock, resetn;
	input  [9:0]  sw;
	input  [3:1]  key;
	output [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0]  led;

	wire          second_clock, flash_clock, pf_status;
	wire   [2:0]  prepare_downcount, pass_downcount;
	wire   [3:0]  new_difficulty;
	wire   [4:0]  progress;
	wire   [6:0]  hex1_goal, hex0_goal;
	wire   [6:0]  hex1_diff, hex0_diff;
	wire   [6:0]  hex3_prepare, hex2_prepare;
	wire   [6:0]  hex5_score, hex4_score, hex3_number, hex2_number, hex1_number, hex0_number;
	wire   [6:0]  hex5_pass, hex4_pass, hex3_pass, hex2_pass, hex1_pass, hex0_pass;
	wire   [6:0]  hex1_sb, hex0_sb;
	wire   [9:0]  random;
	wire   [9:0]  led_wlcm, led_progress, led_pass, led_success;
	wire   [31:0] new_goal;
	reg           resetn_downcount, downcount_started, key3_last;
	reg    [2:0]  state;
	reg    [3:0]  difficulty;
	reg    [6:0]  goal, score, highscore;
	reg    [9:0]  number;

	parameter secclk_N = 5000000;
	parameter halfsecclk_N = 2500000;
	parameter code_off = 7'b1111111;
	parameter code_hf = 7'b0111111;
	parameter code_A = 7'b0001000;
	parameter code_C = 7'b1000110;
	parameter code_D = 7'b0100001;
	parameter code_F = 7'b0001110;
	parameter code_G = 7'b1000010;
	parameter code_H = 7'b0001001;
	parameter code_I = 7'b1111001;
	parameter code_L = 7'b1000111;
	parameter code_O = 7'b1000000;
	parameter code_P = 7'b0001100;
	parameter code_S = 7'b0010010;
	parameter code_U = 7'b1000001;
	parameter led_off = 10'b0000000000;
	parameter led_on = 10'b1111111111;
	parameter enable_debug = 0;

	wire key3 = key[3];
	wire key2 = key[2];
	wire key1 = key[1];

	clock_adjust sec_clk(clock, resetn_downcount, secclk_N, second_clock);
	clock_adjust halfsec_clk(clock, resetn, halfsecclk_N, flash_clock);

	display_welcome disp_welcome(flash_clock, resetn, led_wlcm);
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

	downcount3_flash pass_flash_downcount(flash_clock, resetn_downcount, pass_downcount, pf_status);
	assign hex5_pass = pf_status ? code_hf : code_off;
	assign hex4_pass = pf_status ? code_P : code_off;
	assign hex3_pass = pf_status ? code_A : code_off;
	assign hex2_pass = pf_status ? code_S : code_off;
	assign hex1_pass = pf_status ? code_S : code_off;
	assign hex0_pass = pf_status ? code_hf : code_off;
	assign led_pass = pf_status ? led_on: led_off;

	display_success led_succ(flash_clock, resetn, led_success);

	display_scoreboard disp_sb(highscore, hex1_sb, hex0_sb);

	mux8x7 select_hex5(code_G, code_D, code_hf, hex5_score, hex5_pass, code_hf, code_hf, code_H, state, hex5);
	mux8x7 select_hex4(code_O, code_I, code_hf, hex4_score, hex4_pass, code_S, code_F, code_I, state, hex4);
	mux8x7 select_hex3(code_A, code_F, hex3_prepare, hex3_number, hex3_pass, code_U, code_A, code_G, state, hex3);
	mux8x7 select_hex2(code_L, code_F, hex2_prepare, hex2_number, hex2_pass, code_C, code_I, code_H, state, hex2);
	mux8x7 select_hex1(hex1_goal, hex1_diff, code_hf, hex1_number, hex1_pass, code_C, code_L, hex1_sb, state, hex1);
	mux8x7 select_hex0(hex0_goal, hex0_diff, code_hf, hex0_number, hex0_pass, code_hf, code_hf, hex0_sb, state, hex0);
	mux8x10 select_led(led_wlcm, led_wlcm, led_on, led_progress, led_pass, led_success, led_off, led_wlcm, state, led);

	always @(posedge clock or negedge key1 or negedge resetn) begin
		if (!resetn || !key1) begin
			state <= 0;
			score <= 0;
			goal <= 1;
			difficulty <= 1;
			downcount_started <= 0;
			resetn_downcount <= 1;
			key3_last <= 1;

			if (!resetn)
				highscore <= 0;
		end else begin // posedge clock
			case (state)
				0: begin
					if (!key3) begin
						goal <= new_goal;
						state <= 1;
					end else if (!key2)
						state <= 7;
				end
				1: begin
					if (!key3 && key3_last) begin
						difficulty <= new_difficulty;
						state <= 2;
					end
				end
				2: begin
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
				end
				3: begin
					if (!resetn_downcount) begin
						resetn_downcount <= 1;
					end else if (!downcount_started) begin
						downcount_started <= 1;
						resetn_downcount <= 0;
					end else if (progress == 0) begin
						state <= 6;
					end else if (!key3 && key3_last && (sw == number || enable_debug)) begin
						score <= score + 1;
						highscore <= score + 1 > highscore ? (score + 1) : highscore;
						downcount_started <= 0;
						state <= score + 1 >= goal ? 5 : 4;
					end
				end
				4: begin
					if (!resetn_downcount) begin
						resetn_downcount <= 1;
					end else if (!downcount_started) begin
						downcount_started <= 1;
						resetn_downcount <= 0;
					end else if (pass_downcount == 0) begin
						state <= 3;
						number <= random;
						downcount_started <= 0;
					end
				end
			endcase

			key3_last <= key3;
		end
	end
endmodule
