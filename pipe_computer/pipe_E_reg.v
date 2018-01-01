module pipe_E_reg(dwreg, dm2reg, dwmem, daluc, daluimm, da, db, dimm, drn, dshift,
	djal, dpc4, clock, resetn, ewreg, em2reg, ewmem, ealuc, ealuimm,
	ea, eb, eimm, ern0, eshift, ejal, epc4);
	input         dwreg, dm2reg, dwmem, daluimm, dshift, djal, clock, resetn;
	input  [3:0]  daluc;
	input  [4:0]  drn;
	input  [31:0] da, db, dimm, dpc4;
	output        ewreg, em2reg, ewmem, ealuimm, eshift, ejal;
	output [3:0]  ealuc;
	output [4:0]  ern0;
	output [31:0] ea, eb, eimm, epc4;

	dff1 wreg_r_e(dwreg, clock, resetn, ewreg);
	dff1 m2reg_r_e(dm2reg, clock, resetn, em2reg);
	dff1 wmem_r_e(dwmem, clock, resetn, ewmem);
	dff1 aluimm_r_e(daluimm, clock, resetn, ealuimm);
	dff1 shift_r_e(dshift, clock, resetn, eshift);
	dff1 jal_r_e(djal, clock, resetn, ejal);
	dff4 aluc_r_e(daluc, clock, resetn, ealuc);
	dff5 rn_r_e(drn, clock, resetn, ern0);
	dff32 a_r_e(da, clock, resetn, ea);
	dff32 b_r_e(db, clock, resetn, eb);
	dff32 imm_r_e(dimm, clock, resetn, eimm);
	dff32 pc4_r_e(dpc4, clock, resetn, epc4);
endmodule
