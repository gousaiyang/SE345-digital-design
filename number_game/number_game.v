// Main module of the game.
// States:
//   0 -> initial (welcome), waiting for goal settings
//   1 -> goal set, waiting for difficulty settings
//   2 -> downcounting, will enter game after 5 seconds (preparing)
//   3 -> game in process
//   4 -> pass one level (score + 1), show "-PASS-" flash effect and proceed to next level
//   5 -> successfully finished goal
//   6 -> failed to finish goal
//   7 -> scoreboard display
// Key usage:
//   key3: next (enabled in states 0, 1 and 3)
//   key2: show scoreboard (only enabled in state 0)
//   key1: back (return to state 0, will terminate current game)
//   key0: reset (reset all states including high score record, return to state 0)
module number_game_main(clock, resetn, sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input         clock, resetn;
	input  [9:0]  sw;
	input  [3:1]  key;
	output [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0]  led;

	wire          second_clock, flash_clock, pf_status;
	wire   [2:0]  prepare_downcount, pass_downcount;
	wire   [4:0]  progress;
	wire   [6:0]  hex1_goal, hex0_goal;
	wire   [6:0]  hex1_diff, hex0_diff;
	wire   [6:0]  hex3_prepare, hex2_prepare;
	wire   [6:0]  hex5_score, hex4_score, hex3_number, hex2_number, hex1_number, hex0_number;
	wire   [6:0]  hex5_pass, hex4_pass, hex3_pass, hex2_pass, hex1_pass, hex0_pass;
	wire   [6:0]  hex1_sb, hex0_sb;
	wire   [9:0]  random;
	wire   [9:0]  led_wlcm, led_progress, led_pass, led_success;
	wire   [31:0] new_goal, new_difficulty;
	reg           resetn_downcount, downcount_started, key3_last, key2_last;
	reg    [2:0]  state;
	reg    [3:0]  difficulty;
	reg    [6:0]  goal, score, highscore;
	reg    [9:0]  number;

	// Clock ratio for 1s clock and 0.5s clock.
	parameter secclk_N = 5000000;
	parameter halfsecclk_N = 2500000;

	// Sevenseg and LED codes.
	parameter code_off = 7'b1111111; // Sevenseg all off.
	parameter code_hf = 7'b0111111; // '-'
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
	parameter led_off = 10'b0000000000; // LED all off.
	parameter led_on = 10'b1111111111; // LED all on.

	// Debug mode switch.
	parameter enable_debug = 0;

	wire key3 = key[3];
	wire key2 = key[2];
	wire key1 = key[1];

	// Generate 1s clock and 0.5s clock.
	clock_adjust sec_clk(clock, resetn_downcount, secclk_N, second_clock);
	clock_adjust halfsec_clk(clock, resetn, halfsecclk_N, flash_clock);

	// Random number generator.
	rand10 rand_gen(clock, resetn, random);

	// Welcome LED. (For states 0, 1 and 7)
	display_welcome disp_welcome(flash_clock, resetn, led_wlcm);

	// Module instances for state 0.
	min_max_threshold input_goal(1, 99, {22'b0, sw}, new_goal); // Goal should be in range [1, 99].
	display_goal disp_goal(new_goal, hex1_goal, hex0_goal);

	// Module instances for state 1.
	min_max_threshold input_diff(1, 10, {22'b0, sw}, new_difficulty); // Difficulty should be in range [1, 10].
	display_difficulty disp_diff(new_difficulty, hex1_diff, hex0_diff);

	// Module instances for state 2.
	downcount5 prep_downcount(second_clock, resetn_downcount, prepare_downcount);
	display_prepare disp_prep(prepare_downcount, hex3_prepare, hex2_prepare);

	// Module instances for state 3.
	display_score disp_score(score, hex5_score, hex4_score);
	display_number disp_num(number, hex3_number, hex2_number, hex1_number, hex0_number);
	downcount_difficulty game_downcount(second_clock, resetn_downcount, difficulty, progress);
	display_progress disp_prog(progress, led_progress);

	// For state 4. (pf_status: turn sevensegs and LEDs on/off)
	downcount3_flash pass_flash_downcount(flash_clock, resetn_downcount, pass_downcount, pf_status);
	assign hex5_pass = pf_status ? code_hf : code_off;
	assign hex4_pass = pf_status ? code_P : code_off;
	assign hex3_pass = pf_status ? code_A : code_off;
	assign hex2_pass = pf_status ? code_S : code_off;
	assign hex1_pass = pf_status ? code_S : code_off;
	assign hex0_pass = pf_status ? code_hf : code_off;
	assign led_pass = pf_status ? led_on: led_off;

	// For state 5.
	display_success led_succ(flash_clock, resetn, led_success);

	// For state 7.
	display_scoreboard disp_sb(highscore, hex1_sb, hex0_sb);

	// Multiplexers to select output for sevensegs and LEDs according to current state.
	mux8x7 select_hex5(code_G, code_D, code_hf, hex5_score, hex5_pass, code_hf, code_hf, code_H, state, hex5);
	mux8x7 select_hex4(code_O, code_I, code_hf, hex4_score, hex4_pass, code_S, code_F, code_I, state, hex4);
	mux8x7 select_hex3(code_A, code_F, hex3_prepare, hex3_number, hex3_pass, code_U, code_A, code_G, state, hex3);
	mux8x7 select_hex2(code_L, code_F, hex2_prepare, hex2_number, hex2_pass, code_C, code_I, code_H, state, hex2);
	mux8x7 select_hex1(hex1_goal, hex1_diff, code_hf, hex1_number, hex1_pass, code_C, code_L, hex1_sb, state, hex1);
	mux8x7 select_hex0(hex0_goal, hex0_diff, code_hf, hex0_number, hex0_pass, code_hf, code_hf, hex0_sb, state, hex0);
	mux8x10 select_led(led_wlcm, led_wlcm, led_on, led_progress, led_pass, led_success, led_off, led_wlcm, state, led);

	always @(posedge clock or negedge key1 or negedge resetn) begin
		if (!resetn || !key1) begin // reset or back
			state <= 0;
			score <= 0;
			goal <= 1;
			difficulty <= 1;
			downcount_started <= 0;
			resetn_downcount <= 1;
			key3_last <= 0;
			key2_last <= 0;

			if (!resetn)
				highscore <= 0;
		end else begin // posedge of clock
			case (state) // state machine
				0: begin
					if (!key3 && key3_last) begin // key3 pressed, store goal and proceed to state 1
						goal <= new_goal[6:0];
						state <= 1;
					end else if (!key2 && key2_last) // key2 pressed, show scoreboard (goto state 7)
						state <= 7;
				end
				1: begin
					if (!key3 && key3_last) begin // key3 pressed, store difficulty and proceed to state 2
						difficulty <= new_difficulty[3:0];
						state <= 2;
					end
				end
				2: begin
					// The following 5 lines of code generates a reset signal to start the prepare downcounter.
					if (!resetn_downcount) begin
						resetn_downcount <= 1;
					end else if (!downcount_started) begin
						downcount_started <= 1;
						resetn_downcount <= 0;
					end else if (prepare_downcount == 0) begin // Downcount ended, launch game.
						state <= 3;
						number <= random; // Fetch a random number from the random number generator.
						downcount_started <= 0;
					end
				end
				3: begin
					// Start the life progress downcounter.
					if (!resetn_downcount) begin
						resetn_downcount <= 1;
					end else if (!downcount_started) begin
						downcount_started <= 1;
						resetn_downcount <= 0;
					end else if (progress == 0) begin // Life dropped to 0, goto state 6 (fail).
						state <= 6;
					end else if (!key3 && key3_last && (sw == number || enable_debug)) begin
						// Pass current level, if key3 is pressed (to submit), and switch equals the number.
						// When debug mode is enabled, pressing key3 will pass current level directly.
						score <= score + 1; // Increment score.
						highscore <= score + 1 > highscore ? (score + 1) : highscore; // Record highscore.
						downcount_started <= 0;
						state <= score + 1 >= goal ? 5 : 4; // If finished goal, goto state 5, else goto state 4.
					end
				end
				4: begin
					// Start the pass flash downcounter.
					if (!resetn_downcount) begin
						resetn_downcount <= 1;
					end else if (!downcount_started) begin
						downcount_started <= 1;
						resetn_downcount <= 0;
					end else if (pass_downcount == 0) begin // Downcount ended, goto state 3 (new level).
						state <= 3;
						number <= random; // Fetch a new random number.
						downcount_started <= 0;
					end
				end
			endcase

			// Store last states of key3 and key2 (resolve long pressing problem).
			key3_last <= key3;
			key2_last <= key2;
		end
	end
endmodule
