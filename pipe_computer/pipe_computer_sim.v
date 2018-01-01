`timescale 1ps/1ps

module pipe_computer_sim;
	reg         resetn, clock;
	wire        mem_clock;
	wire [31:0] pc, ins, dpc4, inst, da, db, dimm, ealu, eb, mmo, wdi;
	wire [4:0]  drn, ern, mrn, wrn;
	reg  [9:0]  sw;
	reg  [3:1]  key;
	wire [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	wire [9:0]  led;

	pipe_computer_main pipe_computer_instance(resetn, clock, mem_clock,
		pc, ins, dpc4, inst, da, db, dimm, drn, ealu, eb, ern, mmo, mrn, wdi, wrn,
		sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);

	initial begin // Generate clock.
		clock = 1;
		while (1)
			#2 clock = ~clock;
	end

	initial begin // Generate a reset signal at the start.
		resetn = 1;
		#1 resetn = 0;
		#5 resetn = 1;
		// while (1) begin // Reset and run pipe test again.
		// 	#400 resetn = 0;
		// 	#5   resetn = 1;
		// end
	end

	initial begin // Simulate switch changes.
		sw <= 10'b1010101010;
		while (1)
			#2400 sw = ~sw;
	end

	initial begin // Simulate key presses.
		key <= 3'b111;
		while (1) begin
			#800 key <= 3'b101; // key2 pressed, should change to sub mode
			#800 key <= 3'b110; // key1 pressed, should change to xor mode
			#800 key <= 3'b011; // key3 pressed, should change to add mode
		end
	end
endmodule
