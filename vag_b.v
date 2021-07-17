//////////顶层文件//////////
module vag_b(
	input				sys_clk,		//系统时钟
	input				sys_rst_n,	//复位信号
	//input[1:0]	key0,
	//input[1:0]	key1,
	input				SW_16,		//AI选择
	input				SW1,			//start信号
	input				ps2_dat,		//ps2数据
	input				ps2_clk,		//ps2时钟
	input				s,				//速度选择信号
	output			vga_hs,		//行同步信号
	output  			vga_vs,		//场同步信号
	output [23:0] 	vga_rgb,		//rgb输出
	output 			vga_clk_w,	//25Mhz时钟
	output 			VGA_BLANK_N,//灰电平控制端
	output 			VGA_SYNC_N,	//同步信号控制端
	output [17:0]  LEDR			//led输出
	//output	hex7,hex5,hex3,hex2
	);
	

wire			locked_w;
wire			rst_n_w;
wire[23:0] pixel_data_wire;
wire[9:0]	pixel_xpos_wire;
wire[9:0]	pixel_ypos_wire;
wire[7:0]	key1_code;
wire[7:0]	key2_code;

assign 		rst_n_w=sys_rst_n && locked_w;
assign 		VGA_BLANK_N=1;
assign 		VGA_SYNC_N=0;
assign      LEDR[17]=sys_rst_n;
assign	   LEDR[16]=SW_16;
assign	   LEDR[1]=SW1;
assign	   LEDR[0]=s;
//assign	  hex7=1;
//assign	  hex5=1;
//assign	  hex3=1;
//assign	  hex2=1;

//键盘时钟
reg [31:0] VGA_CLKo;
assign keyboard_sysclk=VGA_CLKo[12];
always@(posedge sys_clk)
	begin 
		VGA_CLKo<=VGA_CLKo+1;
	end

//键盘驱动模块
keyboard keyboard0(
			.CLK_50(sys_clk),
			.ps2_dat(ps2_dat),
			.ps2_clk(ps2_clk),
			.sys_clk(keyboard_sysclk),
			.reset(sys_rst_n),
			.reset1(sys_rst_n),
			.key1_code(key1_code),
			.key2_code(key2_code)
			);

//屏幕显示分频器
vga_pll u_vga_pll(
	.inclk0(sys_clk),
	.areset(~sys_rst_n),
	
	.c0(vga_clk_w),
	.locked(locked_w)
	);
	

//vga驱动模块	
vga_driver u_vga_driver(
	.vga_clk(vga_clk_w),
	.sys_rst_n(rst_n_w),
	
	.vga_hs(vga_hs),
	.vga_vs(vga_vs),
	.vga_rgb(vga_rgb),
	
	.pixel_data(pixel_data_wire),
	.pixel_xpos(pixel_xpos_wire),
	.pixel_ypos(pixel_ypos_wire)
	);

	
//显示模块
vga_display u_vga_display(
	.vga_clk(vga_clk_w),
	.sys_rst_n(rst_n_w),
	.keycode1(key1_code),
	.keycode2(key2_code),
	.start(SW_16),
	.s(s),
	.SW1(SW1),
	.pixel_data(pixel_data_wire),
	.pixel_xpos(pixel_xpos_wire),
	.pixel_ypos(pixel_ypos_wire)
	);
	
endmodule
