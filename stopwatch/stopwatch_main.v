module stopwatch_main(clk, hex5, hex4, hex3, hex2, hex1, hex0);
	input         clk;
	output [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	reg    [18:0] counter;
	initial begin
		counter = 0;
	end

	// reg [3:0] minute_display_high;
	// reg [3:0] minute_display_low;
	// reg [3:0] second_display_high;
	// reg [3:0] second_display_low;
	// reg [3:0] msecond_display_high;
	// reg [3:0] msecond_display_low;
	// // 定义 6 个计时数据（变量）寄存器：
	// reg [3:0] minute_counter_high;
	// reg [3:0] minute_counter_low;
	// reg [3:0] second_counter_high;
	// reg [3:0] second_counter_low;
	// reg [3:0] msecond_counter_high;
	// reg [3:0] msecond_counter_low;
	// reg [31:0] counter_50M; // 计时用计数器， 每个 50MHz 的 clock 为 20ns。
	// // DE1-SOC 板上有 4 个时钟， 都为 50MHz，所以需要 500000 次 20ns 之后，才是 10ms。16
	// reg reset_1_time; // 消抖动用状态寄存器 -- for reset KEY
	// reg [31:0] counter_reset; // 按键状态时间计数器
	// reg start_1_time; //消抖动用状态寄存器 -- for counter/pause KEY
	// reg [31:0] counter_start; //按键状态时间计数器
	// reg display_1_time; //消抖动用状态寄存器 -- for KEY_display_refresh/pause
	// reg [31:0] counter_display; //按键状态时间计数器
	// reg start; // 工作状态寄存器
	// reg display; // 工作状态寄存器
	// sevenseg 模块为 4 位的 BCD 码至 7 段 LED 的译码器，
	//下面实例化 6 个 LED 数码管的各自译码器。
	sevenseg_decimal(counter / 60000, hex5);
	sevenseg_decimal(counter / 6000 % 10, hex4);
	sevenseg_decimal(counter % 6000 / 1000, hex3);
	sevenseg_decimal(counter / 100 % 10, hex2);
	sevenseg_decimal(counter % 100 / 10, hex1);
	sevenseg_decimal(counter % 10, hex0);
	always @(posedge clk)
		begin
			if (counter == 359999) begin
				counter = 0;
			end else begin
				counter = counter + 1;
			end
		end
endmodule
