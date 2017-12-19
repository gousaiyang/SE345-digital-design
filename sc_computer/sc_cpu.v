module sc_cpu(clock, resetn, inst, mem, pc, wmem, alu, data);
	input  [31:0] inst, mem;
	input         clock, resetn;
	output [31:0] pc, alu, data;
	output        wmem;

	/* inst: the fetched instruction
	 * mem: result of a data memory read
	 * npc: next pc
	 * res: data to write into register
	 * adr: branch addr
	 * ra: result a from regfile
	 * data: result b from regfile, may be written into memory
	 * alu: result of ALU, may serve as data address
	 * alu_mem: candidate of data to write into register (maybe from ALU or memory)
	 * reg_dest: candidate of register number to write
	 * wn: register number to write
	 */
	wire   [31:0] p4, npc, adr, ra, alua, alub, res, alu_mem;
	wire   [3:0]  aluc;
	wire   [4:0]  reg_dest, wn;
	wire   [1:0]  pcsource;
	wire          zero, wmem, wreg, regrt, m2reg, shift, aluimm, jal, sext;
	wire   [31:0] sa = {27'b0, inst[10:6]}; // extend sa to 32 bits for shift instruction
	wire          e = sext & inst[15]; // the bit to extend
	wire   [15:0] imm = {16{e}}; // high 16 sign bit when sign extend (otherwise 0)
	wire   [31:0] offset = {imm[13:0], inst[15:0], 2'b00}; // branch addr offset (include extend)
	wire   [31:0] immediate = {imm, inst[15:0]}; // extend immediate to high 16
	wire   [31:0] jpc = {p4[31:28], inst[25:0], 2'b00}; // j address

	assign p4 = pc + 32'h4; // pc + 4
	assign adr = p4 + offset; // branch addr
	assign wn = reg_dest | {5{jal}}; // reg_dest or 31 (jal: r31 <-- p4;)

	dff32 ip(npc, clock, resetn, pc);  // define a D-register for PC
	sc_cu cu(inst[31:26], inst[5:0], zero, wmem, wreg, regrt, m2reg, aluc, shift, aluimm, pcsource, jal, sext);
	regfile rf(inst[25:21], inst[20:16], res, wn, wreg, clock, resetn, ra, data);
	mux2x32 alu_a(ra, sa, shift, alua);
	mux2x32 alu_b(data, immediate, aluimm, alub);
	alu al_unit(alua, alub, aluc, alu, zero);
	mux2x32 result(alu, mem, m2reg, alu_mem);
	mux2x32 link(alu_mem, p4, jal, res);
	mux2x5 reg_wn(inst[15:11], inst[20:16], regrt, reg_dest);
	mux4x32 nextpc(p4, adr, ra, jpc, pcsource, npc);
endmodule
