module padody(vga_clk,move_clock,body_x,body_y,start,sys_rst_n,head);
input wire start,sys_rst_n;
input vga_clk,move_clock;
input wire [11:0]body_x;
input wire [11:0]body_y;
output reg head;
reg [11:0]stackbodyX[63:0];//To store all the x coordinates of 63 parts of the snake
reg [11:0]stackbodyY[63:0];
reg	[3:0]	movex,movey;
always @(posedge move_clock) begin
		if(~start || sys_rst_n) begin
			 stackbodyY[0]<=240;stackbodyX[0]<=320;movex<=10;movey<=10;
	    end else if(stackbodyY[0]<=5) begin
			 movey=~movey;movex<=movex;
		end else if(stackbodyY[0]<=470) begin
			 movey=~movey;movex<=movex;
	    end else if(stackbodyX[0]<=0) begin
			 stackbodyY[0]<=240;stackbodyX[0]<=320;
	    end else if(stackbodyX[0]<=640) begin
			 stackbodyY[0]<=240;stackbodyX[0]<=320;		
		end else begin
			 stackbodyY[0]<=stackbodyY[0]+movey;stackbodyX[0]<=stackbodyX[0]+movex;
		end
end
always @(vga_clk)
begin
	head<=(body_x>stackbodyX[0] && body_x<(stackbodyX[0]+5)) && (body_y>stackbodyY[0] && body_y<stackbodyY[0]+5);
end
endmodule