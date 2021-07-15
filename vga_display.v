`include "config.v"

module vga_display(
	input	vga_clk,
	input	sys_rst_n,
	input [1:0]key0,
	input [1:0]key1,
	
	output reg 	[23:0] pixel_data,
	input			[9:0]	 pixel_xpos,
	input		 [9:0] pixel_ypos
	);
	
//parameter H_DISP=10'd640;
//parameter V_DISP=10'd480;
localparam WHITE	=24'b11111111_11111111_11111111;
localparam BLACK	=24'b00000000_00000000_00000000;
localparam RED		=24'b11111111_00000000_00000000;
localparam GREEN	=24'b00000000_11111111_00000000;
localparam BLUE	=24'b00000000_00000000_11111111;
//localparam SLDE_W =10'd40; //边框宽度

wire[9:0]body0_x,body0_y,body1_x,body1_y;

body body0(
	.vga_clk(vga_clk),
	.sys_rst_n(sys_rst_n),
	.key(key0),
	.body_x(body0_x),
	.body_y(body0_y)
);

body #(22'd570) body1(
	.vga_clk(vga_clk),
	.sys_rst_n(sys_rst_n),
	.key(key1),
	.body_x(body1_x),
	.body_y(body1_y)
);

always @(posedge vga_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		pixel_data<=24'd0;
	else begin
		if((pixel_xpos<`SLDE_W)||(pixel_xpos>=`H_DISP-`SLDE_W)
			||(pixel_ypos<`SLDE_W)||(pixel_ypos>=`V_DISP-`SLDE_W))
			pixel_data<=RED;
		else
		if(((pixel_xpos>=body0_x)&&(pixel_xpos<body0_x+`body_w)
			&&(pixel_ypos>=body0_y)&&(pixel_ypos<body0_y+`body_l))||
			((pixel_xpos>=body1_x)&&(pixel_xpos<body1_x+`body_w)
			&&(pixel_ypos>=body1_y)&&(pixel_ypos<body1_y+`body_l)))
			pixel_data<=WHITE;
		else
		if((pixel_xpos>=`H_DISP/2-10'd2)&&(pixel_xpos<=`H_DISP/2+10'd2)&&
			((pixel_ypos>=10'd180&&pixel_ypos<=10'd300)||(pixel_ypos>=10'd0&&pixel_ypos<=10'd100)||(pixel_ypos>=10'd380&&pixel_ypos<=10'd480)))
			pixel_data<=RED;
		else
			pixel_data<=BLACK;
	end
end

endmodule

