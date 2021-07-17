`include "config.v"
//////////小球//////////
module ballbody(vga_clk,body_x,body_y,padbody_y0,padbody_y1,start,sys_rst_n,score,s,guiwei);
input wire start,sys_rst_n;
input vga_clk;
input s;
output wire [9:0]body_x;
output wire [9:0]body_y;
output reg       guiwei;
input wire [9:0]padbody_y0,padbody_y1;
output reg [3:0]score;
reg [10:0]stackbodyX;
reg [10:0]stackbodyY;
reg [10:0]movex,movey;
initial 		begin
		stackbodyY<=`V_DISP/2-`BALL_W/2;stackbodyX<=`H_DISP/2-`BALL_W/2;
		x_direct<=1'b1;y_direct<=1'b1;
		score<=4'b0000;
end

reg[21:0]div_cnt;//分频计数器
reg y_direct;//球竖直移动方向，
reg [2:0] x_direct;//球水平移动方向
wire move_en;
wire[21:0]speed;
assign speed=s?22'd80000:22'd180000;//速度选择

assign move_en=(div_cnt==speed-1'b1)? 1'b1:1'b0;

//分频
always@(posedge vga_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)
		div_cnt<=22'd0;
	else begin
		if(div_cnt<speed-1'b1)
			div_cnt<=div_cnt+1'b1;
		else
			div_cnt<=22'd0;
	end
end


//球速度方向更新
always @(posedge vga_clk ) begin
	if (~start || ~sys_rst_n) begin
		x_direct<=1'd4;
		y_direct<=1'b1;
	end
	else begin
		if(stackbodyY==`SLDE_W+1 || stackbodyY==`SLDE_W)
			y_direct<=1'b1;
		else
		if(stackbodyY==`V_DISP-`SLDE_W-`BALL_W-1'b1 || stackbodyY==`V_DISP-`SLDE_W-`BALL_W)
			y_direct<=1'b0;
		else
			y_direct<=y_direct;
			
		if((stackbodyX==580-`BALL_W ||stackbodyX==580-`BALL_W+1 )&& stackbodyY>=padbody_y1-`BALL_W && stackbodyY<padbody_y1+`body_l/3)
			x_direct<=3'd1;
		else if((stackbodyX==580-`BALL_W ||stackbodyX==580-`BALL_W+1 ) && stackbodyY>=padbody_y1+`body_l/3 && stackbodyY<=padbody_y1+(`body_l/3)*2)
			x_direct<=3'd0;
		else if((stackbodyX==580-`BALL_W ||stackbodyX==580-`BALL_W+1 ) && stackbodyY>padbody_y1+(`body_l/3)*2 && stackbodyY<=padbody_y1+`body_l)
			x_direct<=3'd1;		
		else if((stackbodyX==55+`body_w || stackbodyX==55+`body_w-1) && stackbodyY>=padbody_y0-`BALL_W && stackbodyY<padbody_y0+`body_l/3)
			x_direct<=3'd3;
		else if((stackbodyX==55+`body_w || stackbodyX==55+`body_w-1)&& stackbodyY>=padbody_y0+`body_l/3 && stackbodyY<=padbody_y0+(`body_l/3)*2)
			x_direct<=3'd2;
		else if((stackbodyX==55+`body_w || stackbodyX==55+`body_w-1) && stackbodyY>padbody_y0+(`body_l/3)*2 && stackbodyY<=padbody_y0+`body_l)
			x_direct<=3'd3;
		else if(stackbodyX==`SLDE_W+1 ||  stackbodyX==`SLDE_W+2)
			x_direct<=3'd4;
		else if(stackbodyX==`H_DISP-`SLDE_W-`BALL_W-1 || stackbodyX==`H_DISP-`SLDE_W-`BALL_W )
			x_direct<=3'd5;
		else
			x_direct<=x_direct;
	end
end
	
	
//球坐标更新
always @(posedge vga_clk ) begin
   guiwei<=0;
	if (~start || ~sys_rst_n) begin
		stackbodyY<=`V_DISP/2-`BALL_W/2;
		stackbodyX<=`H_DISP/2-`BALL_W/2;
		score<=4'b0000;
	end 
	else if(move_en) begin
	
		if(x_direct==3 && y_direct) begin
			stackbodyX<=stackbodyX+2'd2;stackbodyY<=stackbodyY+2'd2;
		end else if(x_direct==3 && !y_direct) begin
			stackbodyX<=stackbodyX+2'd2;stackbodyY<=stackbodyY-2'd2;
		end else if(x_direct==1 &&  y_direct) begin
			stackbodyX<=stackbodyX-2'd2;stackbodyY<=stackbodyY+2'd2;
		end else if(x_direct==1 && !y_direct) begin
			stackbodyX<=stackbodyX-2'd2;stackbodyY<=stackbodyY-2'd2;
		end else if(x_direct==2 &&  y_direct) begin
			stackbodyX<=stackbodyX+2'd2;stackbodyY<=stackbodyY+1'b1;
		end else if(x_direct==2 && !y_direct) begin
			stackbodyX<=stackbodyX+2'd2;stackbodyY<=stackbodyY-1'b1;
		end else if(x_direct==0 &&  y_direct) begin
			stackbodyX<=stackbodyX-2'd2;stackbodyY<=stackbodyY+1'b1;
		end else if(x_direct==0 && !y_direct) begin
			stackbodyX<=stackbodyX-2'd2;stackbodyY<=stackbodyY-1'b1;
		end else if(x_direct==4 &&  y_direct) begin
			stackbodyX<=stackbodyX+1'd1;stackbodyY<=stackbodyY+1'b1;
		end else if(x_direct==4 && !y_direct) begin
			stackbodyX<=stackbodyX+1'd1;stackbodyY<=stackbodyY-1'b1;
		end else if(x_direct==5 &&  y_direct) begin
			stackbodyX<=stackbodyX-1'd1;stackbodyY<=stackbodyY+1'b1;
		end else if(x_direct==5 && !y_direct) begin
			stackbodyX<=stackbodyX-1'd1;stackbodyY<=stackbodyY-1'b1;
		end
	end
		if(stackbodyX==`SLDE_W+1 ||  stackbodyX==`SLDE_W+2) begin
			stackbodyY<=`V_DISP/2-`BALL_W/2; 
			stackbodyX<=`H_DISP/2-`BALL_W/2;
			score[1:0]<=score[1:0]+1;
			guiwei<=1;
		end
		else if(stackbodyX==`H_DISP-`SLDE_W-`BALL_W-1 || stackbodyX==`H_DISP-`SLDE_W-`BALL_W )begin
			stackbodyY<=`V_DISP/2-`BALL_W/2;
			stackbodyX<=`H_DISP/2-`BALL_W/2;
			score[3:2]<=score[3:2]+1;
			guiwei<=1;
		end
		
		if(score[3:2]==2'b11 || score[1:0]==2'b11) begin
			stackbodyY<=`V_DISP/2-`BALL_W/2;
			stackbodyX<=`H_DISP/2-`BALL_W/2;
		end
end

assign body_x=stackbodyX[9:0];
assign body_y=stackbodyY[9:0];

endmodule
