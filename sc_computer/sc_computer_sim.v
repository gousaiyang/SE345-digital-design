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
	wire [31:0] pc_sim, inst_sim, aluout_sim, memout_sim;
	wire        imem_clk_sim, dmem_clk_sim;
	reg  [9:0]  sw;
	reg  [3:0]  key;
	wire [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	wire [9:0]  led;

	initial begin
		sw <= 10'b1010101010;
		key <= 4'b1111;
	end

	sc_computer_main sc_computer_instance(resetn_sim, clock_50M_sim, mem_clk_sim,
		pc_sim, inst_sim, aluout_sim, memout_sim, imem_clk_sim, dmem_clk_sim,
		sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);

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

	initial begin
		while (1)
			#20	sw = ~sw;
	end

	initial begin
		$display($time, "resetn = %b clock_50M = %b mem_clk = %b", resetn_sim, clock_50M_sim, mem_clk_sim);
	end
endmodule
