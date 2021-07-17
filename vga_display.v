`include "config.v"
//////////显示模块//////////
module vga_display(
	input	vga_clk,
	input	sys_rst_n,
	input	SW1,
	input [7:0]keycode1,
	input [7:0]keycode2,
	input [7:0]keycode3,
	input [7:0]keycode4,
	input start,
	input s,
	
	output reg 	[23:0] pixel_data,
	input			[9:0]	 pixel_xpos,
	input		 [9:0] pixel_ypos
	);
	
localparam WHITE	=24'b11111111_11111111_11111111;
localparam BLACK	=24'b00000000_00000000_00000000;
localparam RED		=24'b11111111_00000000_00000000;
localparam GREEN	=24'b00000000_11111111_00000000;
localparam BLUE	=24'b00000000_00000000_11111111;


wire[9:0]body0_x,body0_y,body1_x,body1_y,ball_x,ball_y;
wire [3:0]score;
reg[1:0] key0,key1;
wire guiwei;

//键盘编码
always @(keycode1,keycode2,keycode3,keycode4)begin
	key1=2'b00;key0=2'b00;
	if(keycode1==8'h4B||keycode2==8'h4B||keycode3==8'h4B||keycode4==8'h4B)
		key1[1]<=1;
	if(keycode1==8'h44||keycode2==8'h44||keycode3==8'h44||keycode4==8'h44)
		key1[0]<=1;
	if(keycode1==8'h1B||keycode2==8'h1B||keycode3==8'h1B||keycode4==8'h1B)
		key0[1]<=1;
	if(keycode1==8'h1D||keycode2==8'h1D||keycode3==8'h1D||keycode4==8'h1D)
		key0[0]<=1;
end


body0 body0(					//木板（设人机）
	.vga_clk(vga_clk),
	.sys_rst_n(sys_rst_n),
	.key(key0),
	.body_x(body0_x),
	.body_y(body0_y),
	.s(s),
	.guiwei(guiwei),
	.ai_switch(SW1),
	.ballbody_x(ball_x),
	.ballbody_y(ball_y)
);

body1 #(22'd580) body1(		//木板（不设人机）
	.vga_clk(vga_clk),
	.sys_rst_n(sys_rst_n),
	.key(key1),
	.body_x(body1_x),
	.body_y(body1_y),
	.s(s),
	.guiwei(guiwei)
);

ballbody u_ballbody(			//小球
	.vga_clk(vga_clk),
	.body_x(ball_x),
	.body_y(ball_y),
	.padbody_y0(body0_y),
	.padbody_y1(body1_y),
	.start(start),
	.sys_rst_n(sys_rst_n),
	.score(score),
	.s(s),
	.guiwei(guiwei)
);

always @(posedge vga_clk or negedge sys_rst_n)begin
	if(!sys_rst_n) begin
		pixel_data<=24'd0;
		//score<=4'b0000;
	end
	else begin
		//if(!start)
		//score<=4'b0000;
	
		if((pixel_xpos<`SLDE_W)||(pixel_xpos>=`H_DISP-`SLDE_W)
			||(pixel_ypos<`SLDE_W)||(pixel_ypos>=`V_DISP-`SLDE_W))
			pixel_data<=24'b00000000_11111111_11111111; //边框
		else
		if(((pixel_xpos>=body0_x)&&(pixel_xpos<body0_x+`body_w)
			&&(pixel_ypos>=body0_y)&&(pixel_ypos<body0_y+`body_l))||
			((pixel_xpos>=body1_x)&&(pixel_xpos<body1_x+`body_w)
			&&(pixel_ypos>=body1_y)&&(pixel_ypos<body1_y+`body_l)))
			pixel_data<=WHITE;//木板
		else
		if((pixel_xpos>=`H_DISP/2-10'd2)&&(pixel_xpos<=`H_DISP/2+10'd2)&&
			((pixel_ypos>=10'd180&&pixel_ypos<=10'd300)||(pixel_ypos>=10'd0&&pixel_ypos<=10'd100)||(pixel_ypos>=10'd380&&pixel_ypos<=10'd480)))
			pixel_data<=RED;//虚线
		else
			pixel_data<=BLACK;//背景

		
		//左边得分
		if ((score[3:2]==2'b00) &&
			(pixel_xpos>=`H_DISP/2-10'd40)&&(pixel_xpos<`H_DISP/2-10'd20)
			&&(pixel_ypos>=`SLDE_W+10'd10)&&(pixel_ypos<`SLDE_W+10'd50) &&
			((pixel_xpos<`H_DISP/2-10'd40+10'd5)||(pixel_xpos>=`H_DISP/2-10'd20-10'd5)
			||(pixel_ypos<`SLDE_W+10'd10+10'd5)||(pixel_ypos>=`SLDE_W+10'd50-10'd5)))//左得分0
			pixel_data<=WHITE;
		else
		if((score[3:2]==2'b01) &&
			(pixel_xpos>=`H_DISP/2-10'd20-10'd5)&&(pixel_xpos<`H_DISP/2-10'd20)
			&&(pixel_ypos>=`SLDE_W+10'd10)&&(pixel_ypos<`SLDE_W+10'd50))//左得分1
			pixel_data<=WHITE;
		else
		if((score[3:2]==2'b10) &&
			(pixel_xpos>=`H_DISP/2-10'd40)&&(pixel_xpos<`H_DISP/2-10'd20)
			&&(pixel_ypos>=`SLDE_W+10'd10)&&(pixel_ypos<`SLDE_W+10'd50) &&
			(((pixel_xpos<`H_DISP/2-10'd40+10'd5)&&(pixel_ypos>=`SLDE_W+10'd28))
			||((pixel_xpos>=`H_DISP/2-10'd20-10'd5)&&(pixel_ypos<`SLDE_W+10'd28+10'd5))
			||((pixel_ypos>=`SLDE_W+10'd28)&&(pixel_ypos<`SLDE_W+10'd28+10'd5))
			||(pixel_ypos>=`SLDE_W+10'd50-10'd5)
			||(pixel_ypos<`SLDE_W+10'd10+10'd5)))//左得分2
			pixel_data<=WHITE;
		else
		if((score[3:2]==2'b11) &&
			(pixel_xpos>=`H_DISP/2-10'd40)&&(pixel_xpos<`H_DISP/2-10'd20)
			&&(pixel_ypos>=`SLDE_W+10'd10)&&(pixel_ypos<`SLDE_W+10'd50) &&
			(((pixel_xpos>=`H_DISP/2-10'd20-10'd5)&&(pixel_ypos>=`SLDE_W+10'd28))
			||((pixel_xpos>=`H_DISP/2-10'd20-10'd5)&&(pixel_ypos<`SLDE_W+10'd28+10'd5))
			||((pixel_ypos>=`SLDE_W+10'd28)&&(pixel_ypos<`SLDE_W+10'd28+10'd5))
			||(pixel_ypos>=`SLDE_W+10'd50-10'd5)
			||(pixel_ypos<`SLDE_W+10'd10+10'd5)))//左得分3
			pixel_data<=24'b11111111_11111111_00000000;
			
		//右边得分
		if ((score[1:0]==2'b00) &&
			(pixel_xpos>=`H_DISP/2-10'd40+10'd60)&&(pixel_xpos<`H_DISP/2-10'd20+10'd60)
			&&(pixel_ypos>=`SLDE_W+10'd10)&&(pixel_ypos<`SLDE_W+10'd50) &&
			((pixel_xpos<`H_DISP/2-10'd40+10'd5+10'd60)||(pixel_xpos>=`H_DISP/2-10'd20-10'd5+10'd60)
			||(pixel_ypos<`SLDE_W+10'd10+10'd5)||(pixel_ypos>=`SLDE_W+10'd50-10'd5)))//右得分0
			pixel_data<=WHITE;
		else
		if((score[1:0]==2'b01) &&
			(pixel_xpos>=`H_DISP/2-10'd20-10'd5+10'd60)&&(pixel_xpos<`H_DISP/2-10'd20+10'd60)
			&&(pixel_ypos>=`SLDE_W+10'd10)&&(pixel_ypos<`SLDE_W+10'd50))//右得分1
			pixel_data<=WHITE;
		else
		if((score[1:0]==2'b10) &&
			(pixel_xpos>=`H_DISP/2-10'd40+10'd60)&&(pixel_xpos<`H_DISP/2-10'd20+10'd60)
			&&(pixel_ypos>=`SLDE_W+10'd10)&&(pixel_ypos<`SLDE_W+10'd50) &&
			(((pixel_xpos<`H_DISP/2-10'd40+10'd5+10'd60)&&(pixel_ypos>=`SLDE_W+10'd28))
			||((pixel_xpos>=`H_DISP/2-10'd20-10'd5+10'd60)&&(pixel_ypos<`SLDE_W+10'd28+10'd5))
			||((pixel_ypos>=`SLDE_W+10'd28)&&(pixel_ypos<`SLDE_W+10'd28+10'd5))
			||(pixel_ypos>=`SLDE_W+10'd50-10'd5)
			||(pixel_ypos<`SLDE_W+10'd10+10'd5)))//右得分2
			pixel_data<=WHITE;
		else
		if((score[1:0]==2'b11) &&
			(pixel_xpos>=`H_DISP/2-10'd40+10'd60)&&(pixel_xpos<`H_DISP/2-10'd20+10'd60)
			&&(pixel_ypos>=`SLDE_W+10'd10)&&(pixel_ypos<`SLDE_W+10'd50) &&
			(((pixel_xpos>=`H_DISP/2-10'd20-10'd5+10'd60)&&(pixel_ypos>=`SLDE_W+10'd28))
			||((pixel_xpos>=`H_DISP/2-10'd20-10'd5+10'd60)&&(pixel_ypos<`SLDE_W+10'd28+10'd5))
			||((pixel_ypos>=`SLDE_W+10'd28)&&(pixel_ypos<`SLDE_W+10'd28+10'd5))
			||(pixel_ypos>=`SLDE_W+10'd50-10'd5)
			||(pixel_ypos<`SLDE_W+10'd10+10'd5)))//右得分3
			pixel_data<=24'b11111111_11111111_00000000;
			
			
		//小球
		if(((pixel_xpos>=ball_x)&&(pixel_xpos<ball_x+`BALL_W)
			&&(pixel_ypos>=ball_y)&&(pixel_ypos<ball_y+`BALL_W)))
			pixel_data<=WHITE;
			
	end
end


endmodule

