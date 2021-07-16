module vag_b(
	input				sys_clk,
	input				sys_rst_n,
	//input	[1:0]		key0,
	//input	[1:0]		key1,
	input				SW_16,
	input				ps2_dat,
	input				ps2_clk,
	input				s,
	output			vga_hs,
	output  			vga_vs,
	output [23:0] 	vga_rgb,
	output vga_clk_w,
	output VGA_BLANK_N,
	output VGA_SYNC_N
	);
	
//wire			vga_clk_w;
wire			locked_w;
wire			rst_n_w;
wire [23:0] pixel_data_wire;
wire[9:0]	pixel_xpos_wire;
wire[9:0]	pixel_ypos_wire;
wire[7:0]	key1_code;
wire[7:0]	key2_code;

assign rst_n_w=sys_rst_n && locked_w;
assign VGA_BLANK_N=1;
assign VGA_SYNC_N=0;

//键盘时钟
reg [31:0] VGA_CLKo;
assign keyboard_sysclk=VGA_CLKo[12];
always@(posedge sys_clk)
	begin 
		VGA_CLKo<=VGA_CLKo+1;
	end

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

vga_pll u_vga_pll(
	.inclk0(sys_clk),
	.areset(~sys_rst_n),
	
	.c0(vga_clk_w),
	.locked(locked_w)
	);
	
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
	
vga_display u_vga_display(
	.vga_clk(vga_clk_w),
	.sys_rst_n(rst_n_w),
	.keycode1(key1_code),
	.keycode2(key2_code),
	.start(SW_16),
	.s(s),
	
	.pixel_data(pixel_data_wire),
	.pixel_xpos(pixel_xpos_wire),
	.pixel_ypos(pixel_ypos_wire)
	);
	
endmodule
