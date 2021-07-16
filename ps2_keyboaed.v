module ps2_keyboard_driver(clk,rst_n,ps2k_clk,ps2k_data,ps2_state,ps2_byte_r);
 
input clk;		//50M时钟信号
input rst_n;	//复位信号
input ps2k_clk;	//PS2接口时钟信号
input ps2k_data;		//PS2接口数据信号
output ps2_state;		//键盘当前状态，ps2_state=1表示有键被按下 
output reg[7:0] ps2_byte_r;
//------------------------------------------
reg ps2k_clk_r0,ps2k_clk_r1,ps2k_clk_r2;	//ps2k_clk状态寄存器
//wire pos_ps2k_clk; 	// ps2k_clk上升沿标志位
wire neg_ps2k_clk;	// ps2k_clk下降沿标志位
//设备发送向主机的数据在下降沿有效，首先检测PS2k_clk的下降沿
//利用上面逻辑赋值语句可以提取得下降沿，neg_ps2k_clk为高电平时表示数据可以被采集
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			ps2k_clk_r0 <= 1'b0;
			ps2k_clk_r1 <= 1'b0;
			ps2k_clk_r2 <= 1'b0;
		end
	else begin								//锁存状态，进行滤波
			ps2k_clk_r0 <= ps2k_clk;
			ps2k_clk_r1 <= ps2k_clk_r0;
			ps2k_clk_r2 <= ps2k_clk_r1;
		end
end
 
assign neg_ps2k_clk = ~ps2k_clk_r1 & ps2k_clk_r2;	//下降沿
 
//-----------------数据采集-------------------------
	/*
	帧结构：设备发往主机数据帧为11比特，（主机发送数据包为12bit） 
			1bit start bit ,This is always 0,
			 8bit data bits, 
			 1 parity bit,(odd parity)校验位，奇校验，
			 data bits 为偶数个1时该位为1，
			 data bits 为奇数个1时该位为0.
	         1bit stop bit ,this is always 1.
				num 范围为 'h00,'h0A;
	*/
		//PC接收来自PS2的一个字节数据存储器
reg[7:0] temp_data;			//当前接收数据寄存器
reg[3:0] num;				//计数寄存器
 
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			num <= 4'd0;
			temp_data <= 8'd0;
		end
	else if(neg_ps2k_clk) begin	//检测到ps2k_clk的下降沿
			case (num)
			 /*
		帧结构中数据位为一个字节，且低位在前，高位在后，
		这里要定义一个buf,size is one Byte.
	 */   
				4'd0:	num <= num+1'b1;
				4'd1:	begin
							num <= num+1'b1;
							temp_data[0] <= ps2k_data;	//bit0
						end
				4'd2:	begin
							num <= num+1'b1;
							temp_data[1] <= ps2k_data;	//bit1
						end
				4'd3:	begin
							num <= num+1'b1;
							temp_data[2] <= ps2k_data;	//bit2
						end
				4'd4:	begin
							num <= num+1'b1;
							temp_data[3] <= ps2k_data;	//bit3
						end
				4'd5:	begin
							num <= num+1'b1;
							temp_data[4] <= ps2k_data;	//bit4
						end
				4'd6:	begin
							num <= num+1'b1;
							temp_data[5] <= ps2k_data;	//bit5
						end
				4'd7:	begin
							num <= num+1'b1;
							temp_data[6] <= ps2k_data;	//bit6
						end
				4'd8:	begin
							num <= num+1'b1;
							temp_data[7] <= ps2k_data;	//bit7
						end
				4'd9:	begin
							num <= num+1'b1;	//奇偶校验位，不做处理
						end
				4'd10: begin
							num <= 4'd0;	// num清零
						end
				default: ;
				endcase
		end	
end
 
reg key_f0;		//松键标志位，置1表示接收到数据8'hf0，再接收到下一个数据后清零
reg ps2_state_r;	//键盘当前状态，ps2_state_r=1表示有键被按下 
//+++++++++++++++数据处理开始++++++++++++++++=============
always @ (posedge clk or negedge rst_n) begin	//接收数据的相应处理，这里只对1byte的键值进行处理
	if(!rst_n) begin
			key_f0 <= 1'b0;
			ps2_state_r <= 1'b0;
		end
	else if(num==4'd10) ///一帧数据是否采集完。
			begin	//刚传送完一个字节数据
					if(temp_data == 8'hf0) key_f0 <= 1'b1;//判断该接收数据是否为断码
				else
					begin
					//========================理解困难==================================
						if(!key_f0) 
								begin	//说明有键按下
									ps2_state_r <= 1'b1;
									ps2_byte_r <= temp_data;	//锁存当前键值
								end
						else 
								begin
									ps2_state_r <= 1'b0;
									key_f0 <= 1'b0;
								end
					//=====================================================
					end
			end
end
assign ps2_state = ps2_state_r;
endmodule
 
 