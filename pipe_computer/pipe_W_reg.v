module pipe_W_reg(mwreg, mm2reg, mmo, malu, mrn, clock, resetn, wwreg, wm2reg, wmo, walu, wrn);
	input         mwreg, mm2reg, clock, resetn;
	input  [4:0]  mrn;
	input  [31:0] mmo, malu;
	output        wwreg, wm2reg;
	output [4:0]  wrn;
	output [31:0] wmo, walu;

	dff1 wreg_r_w(mwreg, clock, resetn, wwreg);
	dff1 m2reg_r_w(mm2reg, clock, resetn, wm2reg);
	dff5 rn_r_w(mrn, clock, resetn, wrn);
	dff32 mo_r_w(mmo, clock, resetn, wmo);
	dff32 alu_r_w(malu, clock, resetn, walu);
endmodule
