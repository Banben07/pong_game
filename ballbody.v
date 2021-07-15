module ballbody(VGA_CLK,CLK_50,move_clock,bCounterX,bCounterY,start,reset,head)
input wire start,reset;
wire [2:0] direction;
input VGA_CLK,move_clock,CLK_50;
input wire [11:0]CounterX;
input wire [11:0]CounterY;
output reg head;
wire [11:0]stackbodyX[63:0];
reg [11:0]stackbodyY[63:0];

always @(posedge CLK_50)
		if(~start || reset) begin
			bstackbodyY[0]<=205;
			for (count11=1;count11<=63;count11=count11+1)
				begin
					stackbodyY[count11]<=720;
				end
	end