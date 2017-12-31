module pipe_W_stage(walu, wmo, wm2reg, wdi);
	input         wm2reg;
	input  [31:0] walu, wmo;
	output [31:0] wdi;

	mux2x32 select_write_data(walu, wmo, wm2reg, wdi);
endmodule
