module vag_b(
	input				sys_clk,
	input				sys_rst_n,
	input	[1:0]		key0,
	input	[1:0]		key1,
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

assign rst_n_w=sys_rst_n && locked_w;
assign VGA_BLANK_N=1;
assign VGA_SYNC_N=0;

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
	.key0(key0),
	.key1(key1),
	
	.pixel_data(pixel_data_wire),
	.pixel_xpos(pixel_xpos_wire),
	.pixel_ypos(pixel_ypos_wire)
	);
	
endmodule
