module display_welcome(flash_clock, resetn, led);
	input        flash_clock, resetn;
	output [9:0] led;
	reg    [3:0] counter;

	// A red spot moving right.
	assign led = 1 << (9 - counter);

	always @(posedge flash_clock or negedge resetn)
		if (!resetn)
			counter <= 0;
		else
			counter <= counter >= 9 ? 0 : counter + 1;
endmodule

module display_goal(goal, hex1, hex0);
	input  [6:0] goal;
	output [6:0] hex1, hex0;

	sevenseg_decimal disp_g_1(goal / 10, hex1);
	sevenseg_decimal disp_g_0(goal % 10, hex0);
endmodule

module display_difficulty(difficulty, hex1, hex0);
	input  [3:0] difficulty;
	output [6:0] hex1, hex0;

	sevenseg_decimal disp_d_1(difficulty / 10, hex1);
	sevenseg_decimal disp_d_0(difficulty % 10, hex0);
endmodule

module display_prepare(downcount, hex3, hex2);
	input  [2:0] downcount;
	output [6:0] hex3, hex2;

	sevenseg_decimal disp_p_3(0, hex3);
	sevenseg_decimal disp_p_2(downcount, hex2);
endmodule

module display_score(score, hex5, hex4);
	input  [6:0] score;
	output [6:0] hex5, hex4;

	sevenseg_decimal disp_s_5(score / 10, hex5);
	sevenseg_decimal disp_s_4(score % 10, hex4);
endmodule

module display_number(number, hex3, hex2, hex1, hex0);
	input  [9:0] number;
	output [6:0] hex3, hex2, hex1, hex0;

	sevenseg_decimal disp_n_3(number / 1000, hex3);
	sevenseg_decimal disp_n_2(number % 1000 / 100, hex2);
	sevenseg_decimal disp_n_1(number % 100 / 10, hex1);
	sevenseg_decimal disp_n_0(number % 10, hex0);
endmodule

module display_progress(progress, led);
	input  [4:0] progress;
	output [9:0] led;

	// A life progress bar decaying from 10 to 0 (moving left).
	assign led = ~((1 << (10 - progress)) - 1);
endmodule

module display_success(flash_clock, resetn, led);
	input            flash_clock, resetn;
	output reg [9:0] led;

	// LED flashing between '1010101010' and '0101010101'.
	always @(posedge flash_clock or negedge resetn)
		if (!resetn)
			led <= 10'b1010101010;
		else
			led <= ~led;
endmodule

module display_scoreboard(score, hex1, hex0);
	input  [6:0] score;
	output [6:0] hex1, hex0;

	sevenseg_decimal disp_sb_1(score / 10, hex1);
	sevenseg_decimal disp_sb_0(score % 10, hex0);
endmodule
