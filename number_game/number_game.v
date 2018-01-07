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

module number_game_main(clock, resetn, sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input        clock, resetn;
	input  [9:0] sw;
	input  [3:1] key;
	output [6:0] hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0] led;
	wire   [9:0] random;
	reg    [6:0] score;
	reg    [9:0] number;

	wire key3 = key[3];
	assign led = 10'b0000000000;

	rand10 rand_gen(clock, resetn, random);
	display_score disp_score(score, hex5, hex4);
	display_number disp_num(number, hex3, hex2, hex1, hex0);

	always @(negedge key3 or negedge resetn) begin
		if (!resetn)
			score <= 0;
		else
			score <= score + 1;
	end

	always @(negedge key3) begin
		number <= random;
	end
endmodule
