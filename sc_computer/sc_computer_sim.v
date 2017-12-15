//=============================================
//
// 该 Verilog HDL 代码，是用于对设计模块进行仿真时，对输入信号的模拟输入值的设定。
// 否则，待仿真的对象模块，会因为缺少输入信号，而“不知所措”。
// 该文件可设定若干对目标设计功能进行各种情况下测试的输入用例，以判断自己的功能设计是否正确。
//
// 对于CPU设计来说，基本输入量只有：复位信号、时钟信号。
//
// 对于带I/O设计，则需要设定各输入信号值。
//
//
// =============================================


// `timescale 10ns/10ns            // 仿真时间单位/时间精度
`timescale 1ps/1ps            // 仿真时间单位/时间精度

//
// （1）仿真时间单位/时间精度：数字必须为1、10、100
// （2）仿真时间单位：模块仿真时间和延时的基准单位
// （3）仿真时间精度：模块仿真时间和延时的精确程度，必须小于或等于仿真单位时间
//
//      时间单位：s/秒、ms/毫秒、us/微秒、ns/纳秒、ps/皮秒、fs/飞秒（10负15次方）。

module sc_computer_sim;
	reg         resetn_sim;
	reg         clock_50M_sim;
	reg         mem_clk_sim;
	// reg  [31:0] in_port0_sim;
	// reg  [31:0] in_port1_sim;
	// wire [6:0]  hex0_sim, hex1_sim, hex2_sim, hex3_sim, hex4_sim, hex5_sim;
	// wire        led0_sim, led1_sim, led2_sim, led3_sim;
	// wire [31:0] in_port0_sim, in_port1_sim;
	wire [31:0] pc_sim, inst_sim, aluout_sim, memout_sim;
	wire        imem_clk_sim, dmem_clk_sim;
	// wire [31:0] out_port0_sim, out_port1_sim;
	// wire [31:0] mem_dataout_sim; // to check data_mem output
	// wire [31:0] data_sim;
	// wire [31:0] io_read_data_sim;
	reg         sw9, sw8, sw7, sw6, sw5, sw4, sw3, sw2, sw1, sw0, key3, key2, key1, key0;
	wire [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	wire [9:0]  led;

	initial begin
		sw9 <= 1;
		sw8 <= 0;
		sw7 <= 1;
		sw6 <= 0;
		sw5 <= 1;
		sw4 <= 0;
		sw3 <= 1;
		sw2 <= 0;
		sw1 <= 1;
		sw0 <= 0;
		key3 <= 1;
		key2 <= 1;
		key1 <= 1;
		key0 <= 1;
	end

	// wire        wmem_sim; // connect the cpu and dmem.

	sc_computer_main sc_computer_instance(resetn_sim, clock_50M_sim, mem_clk_sim,
		pc_sim, inst_sim, aluout_sim, memout_sim, imem_clk_sim, dmem_clk_sim,
		sw9, sw8, sw7, sw6, sw5, sw4, sw3, sw2, sw1, sw0, key3, key2, key1, key0,
		hex5, hex4, hex3, hex2, hex1, hex0, led);/*,
		out_port0_sim,out_port1_sim,in_port0_sim,in_port1_sim,
		mem_dataout_sim,data_sim,io_read_data_sim);*/

// module sc_computer (resetn,clock,mem_clk,pc,inst,aluout,memout,imem_clk,dmem_clk,out_port0,out_port1,in_port0,in_port1,mem_dataout,data,io_read_data);

/*  input         resetn, clock, mem_clk;

	input  [31:0] in_port0, in_port1;

	output [31:0] pc, inst, aluout, memout;
	output        imem_clk, dmem_clk;
	output [31:0] out_port0, out_port1;
	output [31:0] mem_dataout;            // to check data_mem output
	output [31:0] data;
	output [31:0] io_read_data;

	wire   [31:0] data;
	wire          wmem;   // connect the cpu and dmem.
*/

	initial begin
		clock_50M_sim = 1;
		while (1)
			#2 clock_50M_sim = ~clock_50M_sim;
	end

	initial begin
		mem_clk_sim = 1;
		while (1)
			#1 mem_clk_sim = ~mem_clk_sim;
	end

	initial begin
		resetn_sim = 0; // 低电平持续 10 个时间单位，后一直为 1。
		while (1)
			#5 resetn_sim = 1;
	end

	// initial begin
	// 	in_port0_sim = 0;
	// 	in_port1_sim = 0;
	// end

	initial begin
		$display($time, "resetn = %b clock_50M = %b mem_clk = %b", resetn_sim, clock_50M_sim, mem_clk_sim);
		// #125000 $display($time, "out_port0 = %b  out_port1 = %b ",out_port0_sim, out_port1_sim);
	end
endmodule
