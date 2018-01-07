module mux8x7(a0, a1, a2, a3, a4, a5, a6, a7, s, y);
	input      [6:0] a0, a1, a2, a3, a4, a5, a6, a7;
	input      [2:0] s;
	output reg [6:0] y;

	always @(*)
		case (s)
			3'b000: y = a0;
			3'b001: y = a1;
			3'b010: y = a2;
			3'b011: y = a3;
			3'b100: y = a4;
			3'b101: y = a5;
			3'b110: y = a6;
			3'b111: y = a7;
		endcase
endmodule
