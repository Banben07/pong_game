module ballbody(vga_clk,move_clock,body_x,body_y,padbody_y1,padbody_y2,start,sys_rst_n,head);
input wire start,sys_rst_n;
input vga_clk,move_clock;
input wire [11:0]body_x;
input wire [11:0]body_y;
input wire [11:0]padbody_y1,padbody_y2;
output reg head;
reg [12:0]stackbodyX[63:0];//To store all the x coordinates of 63 parts of the snake
reg [12:0]stackbodyY[63:0];
reg	[12:0] 		movex,movey;
initial 		begin
		stackbodyY[0]<=240;stackbodyX[0]<=320;
end
always @(posedge move_clock) begin
		 if(~start || sys_rst_n) begin
			 stackbodyY[0]<=240;stackbodyX[0]<=320;movex<=10;movey<=10;
	    end else if(stackbodyY[0]==20) begin
			 movey<=10;stackbodyY[0]<=stackbodyY[0]+movey;stackbodyX[0]<=stackbodyX[0]+movex;
		 end else if(stackbodyY[0]==450) begin
			 movey<=13'b1111111110110;stackbodyY[0]<=stackbodyY[0]+movey;stackbodyX[0]<=stackbodyX[0]+movex;
	    end else if(stackbodyX[0]==0) begin
			 stackbodyY[0]<=240;stackbodyX[0]<=320;
	    end else if(stackbodyX[0]==630) begin
			 stackbodyY[0]<=240;stackbodyX[0]<=320;
		 end else if(stackbodyX[0]==610 && stackbodyY[0]>=padbody_y1-10 && stackbodyY[0]<=padbody_y1+70) begin
		     movex<=13'b1111111110110;stackbodyY[0]<=stackbodyY[0]+movey;stackbodyX[0]<=stackbodyX[0]+movex;
		 end else if(stackbodyX[0]==30 && stackbodyY[0]>=padbody_y2-10 && stackbodyY[0]<=padbody_y2+70) begin
		     movex<=10;stackbodyY[0]<=stackbodyY[0]+movey;stackbodyX[0]<=stackbodyX[0]+movex;
		 end else begin
			 stackbodyY[0]<=stackbodyY[0]+movey;stackbodyX[0]<=stackbodyX[0]+movex;
		 end
end
always @(vga_clk)
begin
	head<=(body_x>stackbodyX[0][11:0] && body_x<(stackbodyX[0][11:0]+10)) && (body_y>stackbodyY[0][11:0] && body_y<stackbodyY[0][11:0]+10);
end
endmodule