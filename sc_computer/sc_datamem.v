module sc_datamem(addr, datain, dataout, we, clock, mem_clk, dmem_clk);
	input  [31:0]  addr, datain;
	input          we, clock, mem_clk;
	output [31:0]  dataout;
	output         dmem_clk;
	wire           write_enable;

	assign write_enable = we & ~clock;
	assign dmem_clk = mem_clk & ~clock;

	ram_1port dram(addr[6:2], dmem_clk, datain, write_enable, dataout);
endmodule
