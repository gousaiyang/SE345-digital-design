module sc_cu(op, func, z, wmem, wreg, regrt, m2reg, aluc, shift, aluimm, pcsource, jal, sext);
	input  [5:0] op, func;
	input        z;
	output       wreg, regrt, jal, m2reg, shift, aluimm, sext, wmem;
	output [3:0] aluc;
	output [1:0] pcsource;

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

	assign pcsource[1] = i_jr | i_j | i_jal;
	assign pcsource[0] = (i_beq & z) | (i_bne & ~z) | i_j | i_jal;

	assign aluc[3] = i_sra;
	assign aluc[2] = i_sub | i_or | i_srl | i_sra | i_ori | i_beq | i_bne | i_lui;
	assign aluc[1] = i_xor | i_sll | i_srl | i_sra | i_xori | i_lui;
	assign aluc[0] = i_and | i_or | i_sll | i_srl | i_sra | i_andi | i_ori;

	assign shift = i_sll | i_srl | i_sra ;
	assign aluimm = i_addi | i_andi | i_ori | i_xori | i_lw | i_sw | i_lui;
	assign sext = i_addi | i_lw | i_sw | i_beq | i_bne;
	assign wmem = i_sw;
	assign wreg = i_add | i_sub | i_and | i_or | i_xor | i_sll | i_srl | i_sra
		| i_addi | i_andi | i_ori | i_xori | i_lw | i_lui | i_jal;
	assign m2reg = i_lw;
	assign regrt = i_addi | i_andi | i_ori | i_xori | i_lw | i_lui;
	assign jal = i_jal;
endmodule
