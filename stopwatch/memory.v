// An RAM.
module memory(operation, offset, datain, dataout);
	input      [1:0]  operation;
	input      [31:0] offset;
	input      [31:0] datain;
	output reg [31:0] dataout;
	parameter mem_size = 5;
	reg [31:0] mem [mem_size + 1:0]; // Actual data in [mem_size:1].
	integer i;

	initial begin
		for (i = 0; i < mem_size + 2; i = i + 1)
			mem[i] = 0;
	end

	always @(operation, offset, datain) begin
		if (offset >= 0 && offset < mem_size + 2) begin // boundary check
			case (operation)
				2'b01: dataout = mem[offset]; // read
				2'b10: mem[offset] = datain; // write
				// hang on other conditions
			endcase
		end
	end
endmodule
