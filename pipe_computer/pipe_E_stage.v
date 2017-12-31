module pipe_E_stage(ealuc, ealuimm, ea, eb, eimm, eshift, ern0, epc4, ejal, ern, ealu);
	input         ealuimm, eshift, ejal;
	input  [3:0]  ealuc;
	input  [4:0]  ern0;
	input  [31:0] ea, eb, eimm, epc4;
	output [4:0]  ern;
	output [31:0] ealu;

	wire [31:0] alua, alub, alur, pc8;

	assign pc8 = epc4 + 4;
	assign ern = ern0 | {5{ejal}}; // jal: r31 <-- pc8;

	mux2x32 selectalua(ea, eimm, eshift, alua);
	mux2x32 selectalub(eb, eimm, ealuimm, alub);
	alu al_unit(alua, alub, ealuc, alur);
	mux2x32 selectalur(alur, pc8, ejal, ealu);
endmodule
