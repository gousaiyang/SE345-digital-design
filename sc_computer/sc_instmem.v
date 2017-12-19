module sc_instmem(addr, inst, clock, mem_clk, imem_clk);
	input  [31:0] addr;
	input         clock, mem_clk;
	output [31:0] inst;
	output        imem_clk;

	assign imem_clk = clock & ~mem_clk;

	rom_1port irom(addr[8:2], imem_clk, inst);
endmodule
