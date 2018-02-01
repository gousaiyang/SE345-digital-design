module pipe_cu(op, func, rs, rt, ern, mrn, rsrtequ, ewreg, em2reg, mwreg, mm2reg,
	wpcir, wreg, m2reg, wmem, jal, aluimm, shift, regrt, sext, pcsource, fwda, fwdb, aluc);
	input            rsrtequ, ewreg, em2reg, mwreg, mm2reg;
	input      [4:0] rs, rt, ern, mrn;
	input      [5:0] op, func;
	output           wpcir, wreg, m2reg, wmem, jal, aluimm, shift, regrt, sext;
	output     [1:0] pcsource;
	output reg [1:0] fwda, fwdb;
	output     [3:0] aluc;

	wire r_type = op == 6'b000000;
	wire i_add = r_type & func == 6'b100000;
	wire i_sub = r_type & func == 6'b100010;
	wire i_and = r_type & func == 6'b100100;
	wire i_or  = r_type & func == 6'b100101;
	wire i_xor = r_type & func == 6'b100110;
	wire i_sll = r_type & func == 6'b000000;
	wire i_srl = r_type & func == 6'b000010;
	wire i_sra = r_type & func == 6'b000011;
	wire i_jr  = r_type & func == 6'b001000;
	wire i_hamd = r_type & func == 6'b100111;
	wire i_addi = op == 6'b001000;
	wire i_andi = op == 6'b001100;
	wire i_ori  = op == 6'b001101;
	wire i_xori = op == 6'b001110;
	wire i_lw   = op == 6'b100011;
	wire i_sw   = op == 6'b101011;
	wire i_beq  = op == 6'b000100;
	wire i_bne  = op == 6'b000101;
	wire i_lui  = op == 6'b001111;
	wire i_j    = op == 6'b000010;
	wire i_jal  = op == 6'b000011;

	// Determine which instructions use rs/rt.
	wire use_rs = i_add | i_sub | i_and | i_or | i_xor | i_jr | i_hamd | i_addi | i_andi | i_ori | i_xori
		| i_lw | i_sw | i_beq | i_bne;
	wire use_rt = i_add | i_sub | i_and | i_or | i_xor | i_sll | i_srl | i_sra | i_hamd | i_sw | i_beq | i_bne;

	wire load_use_hazard = ewreg & em2reg & (ern != 0) & ((use_rs & (ern == rs)) | (use_rt & (ern == rt)));

	// When load/use hazard happens, stall F and D registers (stall PC),
	// and generate a bubble to E register (by forbidding writing registers and memory).
	assign wpcir = ~load_use_hazard;
	assign wreg = (i_add | i_sub | i_and | i_or | i_xor | i_sll | i_srl | i_sra | i_hamd
		| i_addi | i_andi | i_ori | i_xori | i_lw | i_lui | i_jal) & ~load_use_hazard;
	assign m2reg = i_lw;
	assign wmem = i_sw & ~load_use_hazard;
	assign jal = i_jal;
	assign aluimm = i_addi | i_andi | i_ori | i_xori | i_lw | i_sw | i_lui;
	assign shift = i_sll | i_srl | i_sra;
	assign regrt = i_addi | i_andi | i_ori | i_xori | i_lw | i_lui;
	assign sext = i_addi | i_lw | i_sw | i_beq | i_bne;

	assign pcsource[1] = i_jr | i_j | i_jal;
	assign pcsource[0] = (i_beq & rsrtequ) | (i_bne & ~rsrtequ) | i_j | i_jal;

	assign aluc[3] = i_sra | i_hamd;
	assign aluc[2] = i_sub | i_or | i_srl | i_sra | i_ori | i_beq | i_bne | i_lui;
	assign aluc[1] = i_xor | i_sll | i_srl | i_sra | i_hamd | i_xori | i_lui;
	assign aluc[0] = i_and | i_or | i_sll | i_srl | i_sra | i_hamd | i_andi | i_ori;

	// Forwarding logic.
	// Forward priority: Look for E stage first, then M stage.
	// Also, we should not forward r0.
	always @(*) begin
		if (ewreg & ~em2reg & (ern != 0) & (ern == rs))
			fwda = 2'b01; // Forward from ealu.
		else if (mwreg & ~mm2reg & (mrn != 0) & (mrn == rs))
			fwda = 2'b10; // Forward from malu.
		else if (mwreg & mm2reg & (mrn != 0) & (mrn == rs))
			fwda = 2'b11; // Forward from mmo.
		else
			fwda = 2'b00; // Do not forward.
	end

	always @(*) begin
		if (ewreg & ~em2reg & (ern != 0) & (ern == rt))
			fwdb = 2'b01; // Forward from ealu.
		else if (mwreg & ~mm2reg & (mrn != 0) & (mrn == rt))
			fwdb = 2'b10; // Forward from malu.
		else if (mwreg & mm2reg & (mrn != 0) & (mrn == rt))
			fwdb = 2'b11; // Forward from mmo.
		else
			fwdb = 2'b00; // Do not forward.
	end
endmodule
