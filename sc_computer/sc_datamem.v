module sc_datamem(resetn, addr, datain, dataout, we, clock, mem_clk, dmem_clk,
	sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);
	input              resetn;
	input      [31:0]  addr, datain;
	input              we, clock, mem_clk;
	input      [9:0]   sw;
	input      [3:1]   key;
	output reg [31:0]  dataout;
	output             dmem_clk;
	output reg [6:0]   hex5, hex4, hex3, hex2, hex1, hex0;
	output reg [9:0]   led;
	wire               write_enable;
	wire       [31:0]  mem_dataout;

	assign write_enable = we & ~clock & (addr[31:8] != 24'hffffff);
	assign dmem_clk = mem_clk & ~clock;

	ram_1port dram(addr[6:2], dmem_clk, datain, write_enable, mem_dataout);

	// IO ports design.
	always @(posedge dmem_clk or negedge resetn) begin
		if (!resetn) begin // reset hexs and leds
			hex0 <= 7'b1111111;
			hex1 <= 7'b1111111;
			hex2 <= 7'b1111111;
			hex3 <= 7'b1111111;
			hex4 <= 7'b1111111;
			hex5 <= 7'b1111111;
			led <= 10'b0000000000;
		end else if (we) begin // write when dmem_clk posedge comes
			case (addr)
				32'hffffff20: hex0 <= datain[6:0];
				32'hffffff30: hex1 <= datain[6:0];
				32'hffffff40: hex2 <= datain[6:0];
				32'hffffff50: hex3 <= datain[6:0];
				32'hffffff60: hex4 <= datain[6:0];
				32'hffffff70: hex5 <= datain[6:0];
				32'hffffff80: led <= datain[9:0];
			endcase
		end
	end

	always @(posedge dmem_clk) begin // read when dmem_clk posedge comes
		case (addr)
			32'hffffff00: dataout <= {22'b0, sw};
			32'hffffff10: dataout <= {28'b0, key, 1'b1}; // can only read key[3..1], key0 is used for reset
			default: dataout <= mem_dataout;
		endcase
	end
endmodule
