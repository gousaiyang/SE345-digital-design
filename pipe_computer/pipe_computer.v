module pipe_computer_main(resetn, clock, mem_clock,
	pc, ins, dpc4, inst, da, db, dimm, drn, ealu, eb, ern, mmo, mrn, wdi, wrn,
	sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);
	// 定义整个计算机 module 和外界交互的输入信号，包括复位信号 resetn 及时钟信号 clock。
	input         resetn, clock;

	// 模块用于仿真输出的观察信号。
	output        mem_clock;
	output [4:0]  drn, ern, mrn, wrn;
	output [31:0] pc, ins, dpc4, inst, da, db, dimm, ealu, eb, mmo, wdi;

	// 定义计算机的 I/O 端口。
	input  [9:0]  sw;
	input  [3:1]  key;
	output [6:0]  hex5, hex4, hex3, hex2, hex1, hex0;
	output [9:0]  led;

	// 模块间互联传递数据或控制信息的信号线，均为 32 位宽信号。IF 取指令阶段。
	wire   [31:0] pc, bpc, jpc, npc, pc4, ins, inst;

	// 模块间互联传递数据或控制信息的信号线，均为 32 位宽信号。ID 指令译码阶段。
	wire   [31:0] dpc4, da, db, dimm;

	// 模块间互联传递数据或控制信息的信号线，均为 32 位宽信号。EXE 指令运算阶段。
	wire   [31:0] epc4, ea, eb, eimm, ealu;

	// 模块间互联传递数据或控制信息的信号线，均为 32 位宽信号。MEM 访问数据阶段。
	wire   [31:0] mb, mmo, malu;

	// 模块间互联传递数据或控制信息的信号线，均为 32 位宽信号。WB 回写寄存器阶段。
	wire   [31:0] wmo, wdi, walu;

	// 模块间互联，通过流水线寄存器传递结果寄存器号的信号线，寄存器号（32 个）为 5bit。
	wire   [4:0]  drn, ern0, ern, mrn, wrn;

	// ID 阶段向 EXE 阶段通过流水线寄存器传递的 aluc 控制信号，4bit。
	wire   [3:0]  daluc, ealuc;

	// CU 模块向 IF 阶段模块传递的 PC 选择信号，2bit。
	wire   [1:0]  pcsource;

	// CU 模块发出的控制流水线停顿的控制信号，使 PC 和 IF/ID 流水线寄存器保持不变。
	wire          wpcir;

	// ID 阶段产生，需往后续流水级传播的控制信号。
	wire          dwreg, dm2reg, dwmem, daluimm, dshift, djal;

	// 来自于 ID/EXE 流水线寄存器，EXE 阶段使用，或需要往后续流水级传播的控制信号。
	wire          ewreg, em2reg, ewmem, ealuimm, eshift, ejal;

	// 来自于 EXE/MEM 流水线寄存器，MEM 阶段使用，或需要往后续流水级传播的控制信号。
	wire          mwreg, mm2reg, mwmem;

	// 来自于 MEM/WB 流水线寄存器，WB 阶段使用的控制信号。
	wire          wwreg, wm2reg;

	// mem_clock 和 clock 同频率但反相，用作指令同步 ROM 和数据同步 RAM 的时钟信号，其波形需要有别于实验一。
	assign mem_clock = ~clock;

	// 程序计数器模块，是最前面一级 IF 流水段的输入。
	pipe_F_reg prog_cnt(npc, wpcir, clock, resetn, pc);

	// IF 取指令模块，注意其中包含的指令同步 ROM 存储器的同步信号。
	// 留给信号半个节拍的传输时间。
	pipe_F_stage if_stage(pcsource, pc, bpc, da, jpc, npc, pc4, ins, mem_clock);

	// IF/ID 流水线寄存器模块，起承接 IF 阶段和 ID 阶段的流水任务。
	// 在 clock 上升沿时，将 IF 阶段需传递给 ID 阶段的信息，锁存在 IF/ID 流水线寄存器中，并呈现在 ID 阶段。
	pipe_D_reg inst_reg(pc4, ins, wpcir, clock, resetn, dpc4, inst);

	// ID 指令译码模块。注意其中包含控制器 CU、寄存器堆及多个多路器等。
	// 其中的寄存器堆，会在系统 clock 的下沿进行寄存器写入，也就是给信号从 WB 阶段
	// 传输过来留有半个 clock 的延迟时间，亦即确保信号稳定。
	// 该阶段 CU 产生的，要传播到流水线后级的信号较多。
	pipe_D_stage id_stage(mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst,
		wrn, wdi, ealu, malu, mmo, wwreg, clock, resetn,
		bpc, jpc, pcsource, wpcir, dwreg, dm2reg, dwmem, daluc,
		daluimm, da, db, dimm, drn, dshift, djal);

	// ID/EXE 流水线寄存器模块，起承接 ID 阶段和 EXE 阶段的流水任务。
	// 在 clock 上升沿时，将 ID 阶段需传递给 EXE 阶段的信息，锁存在 ID/EXE 流水线寄存器中，并呈现在 EXE 阶段。
	pipe_E_reg de_reg(dwreg, dm2reg, dwmem, daluc, daluimm, da, db, dimm, drn, dshift,
		djal, dpc4, clock, resetn, ewreg, em2reg, ewmem, ealuc, ealuimm,
		ea, eb, eimm, ern0, eshift, ejal, epc4);

	// EXE 运算模块。其中包含 ALU 及多个多路器等。
	pipe_E_stage exe_stage(ealuc, ealuimm, ea, eb, eimm, eshift, ern0, epc4, ejal, ern, ealu);

	// EXE/MEM 流水线寄存器模块，起承接 EXE 阶段和 MEM 阶段的流水任务。
	// 在 clock 上升沿时，将 EXE 阶段需传递给 MEM 阶段的信息，锁存在 EXE/MEM 流水线寄存器中，并呈现在 MEM 阶段。
	pipe_M_reg em_reg(ewreg, em2reg, ewmem, ealu, eb, ern, clock, resetn, mwreg, mm2reg, mwmem, malu, mb, mrn);

	// MEM 数据存取模块。其中包含对数据同步 RAM 的读写访问。
	// 留给信号半个节拍的传输时间，然后在 mem_clock 上沿时，读输出或写输入。
	pipe_M_stage mem_stage(mwmem, malu, mb, mem_clock, resetn, mmo, sw, key, hex5, hex4, hex3, hex2, hex1, hex0, led);

	// MEM/WB 流水线寄存器模块，起承接 MEM 阶段和 WB 阶段的流水任务。
	// 在 clock 上升沿时，将 MEM 阶段需传递给 WB 阶段的信息，锁存在 MEM/WB 流水线寄存器中，并呈现在 WB 阶段。
	pipe_W_reg mw_reg(mwreg, mm2reg, mmo, malu, mrn, clock, resetn, wwreg, wm2reg, wmo, walu, wrn);

	// WB 写回阶段模块。
	pipe_W_stage wb_stage(walu, wmo, wm2reg, wdi);
endmodule
