module padbody(vga_clk,key,move_clock,body_x,body_y,start,sys_rst_n,head);
input[3:0] key;
input wire start,sys_rst_n;
input vga_clk,move_clock;
input wire [11:0]body_x;
input wire [11:0]body_y;
output reg head;
wire [11:0]stackbodyX[63:0];//To store all the x coordinates of 63 parts of the snake
reg [11:0]stackbodyY[63:0];//To store all the y coordinates of 63 parts of the snake
reg [4:0] length =1;//ask if it is correct
integer count00,count01,count10,count11;
assign			stackbodyX[0]=630;
always @(posedge move_clock) begin	
	if(key[0]==0 && key[1]==1) begin
		if(stackbodyY[0]>=400) begin
			stackbodyY[0]<=stackbodyY[0];
		end else begin
		stackbodyY[0]=stackbodyY[0]+10;//move right
		end
	end else if(key[1]==0 && key[0]==1) begin
	   if(stackbodyY[0]<=5) begin
			   stackbodyY[0]<=stackbodyY[0];
		end else begin
		stackbodyY[0]=stackbodyY[0]-10;//move left
		end
	end else if(~start || sys_rst_n) begin
			stackbodyY[0]<=205;
			for (count11=1;count11<=63;count11=count11+1)
				begin
					stackbodyY[count11]<=720;//values that are not
				end
	end else begin
		stackbodyY[0]=stackbodyY[0];
   end
end
always @(vga_clk)
begin
	head<=(body_x>stackbodyX[0] && body_x<(stackbodyX[0]+5)) && (body_y>stackbodyY[0] && body_y<stackbodyY[0]+70);
end
endmodule