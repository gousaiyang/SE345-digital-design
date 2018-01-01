module pipe_F_reg(npc, wpcir, clock, resetn, pc);
	input  [31:0] npc;
	input         wpcir, clock, resetn;
	output [31:0] pc;

	dffe32pc ip(npc, clock, resetn, wpcir, pc);
endmodule
