module pipe_M_reg(ewreg, em2reg, ewmem, ealu, eb, ern, clock, resetn, mwreg, mm2reg, mwmem, malu, mb, mrn);
	input         ewreg, em2reg, ewmem, clock, resetn;
	input  [4:0]  ern;
	input  [31:0] ealu, eb;
	output        mwreg, mm2reg, mwmem;
	output [4:0]  mrn;
	output [31:0] malu, mb;

	dff1 wreg_r_m(ewreg, clock, resetn, mwreg);
	dff1 m2reg_r_m(em2reg, clock, resetn, mm2reg);
	dff1 wmem_r_m(ewmem, clock, resetn, mwmem);
	dff5 rn_r_m(ern, clock, resetn, mrn);
	dff32 alu_r_m(ealu, clock, resetn, malu);
	dff32 b_r_m(eb, clock, resetn, mb);
endmodule
