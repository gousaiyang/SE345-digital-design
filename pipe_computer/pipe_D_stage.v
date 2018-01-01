module pipe_D_stage(mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst,
	wrn, wdi, ealu, malu, mmo, wwreg, clock, resetn,
	bpc, jpc, pcsource, wpcir, dwreg, dm2reg, dwmem, daluc,
	daluimm, da, db, dimm, drn, dshift, djal);
	input         mwreg, ewreg, em2reg, mm2reg, wwreg, clock, resetn;
	input  [4:0]  mrn, ern, wrn;
	input  [31:0] dpc4, inst, wdi, ealu, malu, mmo;
	output        wpcir, dwreg, dm2reg, dwmem, daluimm, dshift, djal;
	output [1:0]  pcsource;
	output [3:0]  daluc;
	output [4:0]  drn;
	output [31:0] bpc, jpc, da, db, dimm;

	wire          rsrtequ, regrt, sext;
	wire   [1:0]  fwda, fwdb;
	wire   [31:0] qa, qb;

	wire   [5:0]  op = inst[31:26];
	wire   [5:0]  func = inst[5:0];
	wire   [4:0]  rs = inst[25:21];
	wire   [4:0]  rt = inst[20:16];
	wire   [4:0]  rd = inst[15:11];
	wire   [15:0] imm = inst[15:0];
	wire   [25:0] addr = inst[25:0];
	wire   [31:0] sa = {27'b0, inst[10:6]}; // zero extend sa to 32 bits for shift instruction
	wire          e = sext & inst[15]; // the bit to extend
	wire   [15:0] imm_ext = {16{e}}; // high 16 sign bit when sign extend (otherwise 0)
	wire   [31:0] boffset = {imm_ext[13:0], imm, 2'b00}; // branch addr offset
	wire   [31:0] immediate = {imm_ext, imm}; // extend immediate to high 16

	assign rsrtequ = da == db;
	assign jpc = {dpc4[31:28], addr, 2'b00};
	assign bpc = dpc4 + boffset;
	assign dimm = op == 6'b000000 ? sa : immediate; // combine sa and immediate to one signal

	pipe_cu cu(op, func, rs, rt, ern, mrn, rsrtequ, ewreg, em2reg, mwreg, mm2reg,
		wpcir, dwreg, dm2reg, dwmem, djal, daluimm, dshift, regrt, sext, pcsource, fwda, fwdb, daluc);
	regfile rf(rs, rt, wdi, wrn, wwreg, clock, resetn, qa, qb);
	mux4x32 selecta(qa, ealu, malu, mmo, fwda, da);
	mux4x32 selectb(qb, ealu, malu, mmo, fwdb, db);
	mux2x5 selectrn(rd, rt, regrt, drn);
endmodule
