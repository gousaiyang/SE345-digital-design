module pipe_M_stage(mwmem, malu, mb, ram_clock, resetn, mmo, sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input         mwmem, ram_clock, resetn;
	input  [31:0] malu, mb;
	input  [9:0]  sw;
	input  [3:1]  key;
	output [31:0] mmo;
	output [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0]  led;

	pipe_datamem datamem(malu, mb, mmo, mwmem, ram_clock, resetn, sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);
endmodule
