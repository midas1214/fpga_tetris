module move_control(
	clk_10000Hz,
	reset, left_btn, right_btn, rotate_btn,
	map, new_map, placed, 
	new_block_id, row,
	x1, x2, x3, x4, y1, y2, y3, y4,
	nx1, nx2, nx3, nx4, ny1, ny2, ny3, ny4);
	
	input clk_10000Hz, reset;
	input left_btn, right_btn, rotate_btn;
	input [127:0] map;           // 0為左上角127為右下角
	input [2:0] x1, x2, x3, x4;  //生成方塊的x座標
	input [3:0] y1, y2, y3, y4;  //生成方塊的y座標
	input [2:0] new_block_id;
	output reg [3:0] nx1, nx2, nx3, nx4;//移動後方塊的x座標
	output reg [3:0] ny1, ny2, ny3, ny4;//移動後方塊的y座標
	output reg [127:0] new_map;
	output reg [9:0] row;
	output reg placed;//=1:已無法移動

	reg signed [4:0] rx1, rx2, rx4, ry1, ry2, ry4; //旋轉後的xy,只有1,2,4,為了檢查看能不能轉
	reg signed [4:0] fix_x; //rotate 可能會卡進去牆壁,要修正
	reg [13:0]drop_clk;

	initial begin
		nx1 = 3'd2;
		nx2 = 3'd3;
		nx3 = 3'd4;
		nx4 = 3'd5;
		ny1 = 3'd0;
		ny2 = 3'd0;
		ny3 = 3'd0;
		ny4 = 3'd0;
		new_map = 128'd0;
	end

	always@( posedge clk_10000Hz or negedge reset ) begin
		if(!reset) begin  // reset後新方塊的xy寫在這, 更新map, reset drop_clk = 14'd0;
			case (new_block_id) 
				3'd0 : // I
				begin
					nx1 <= 3'd2;
					nx2 <= 3'd3;
					nx3 <= 3'd4;
					nx4 <= 3'd5;
					ny1 <= 4'd0; 
					ny2 <= 4'd0;
					ny3 <= 4'd0;
					ny4 <= 4'd0;
				end
				3'd1 : // O
				begin 
					nx1 <= 3'd3;
					nx2 <= 3'd4;
					nx3 <= 3'd3;
					nx4 <= 3'd4;
					ny1 <= 4'd0; 
					ny2 <= 4'd0;
					ny3 <= 4'd1;
					ny4 <= 4'd1;
				end
				3'd2 : // Z
				begin 
					nx1 <= 3'd3;
					nx2 <= 3'd4;
					nx3 <= 3'd4;
					nx4 <= 3'd5;
					ny1 <= 4'd0; 
					ny2 <= 4'd0;
					ny3 <= 4'd1;
					ny4 <= 4'd1;
				end
				3'd3 : // S
				begin 
					nx1 <= 3'd3;
					nx2 <= 3'd4;
					nx3 <= 3'd4;
					nx4 <= 3'd5;
					ny1 <= 4'd1; 
					ny2 <= 4'd1;
					ny3 <= 4'd0;
					ny4 <= 4'd0;
				end
				3'd4 : // L
				begin 
					nx1 <= 3'd5;
					nx2 <= 3'd4;
					nx3 <= 3'd3;
					nx4 <= 3'd3;
					ny1 <= 4'd0; 
					ny2 <= 4'd0;
					ny3 <= 4'd0;
					ny4 <= 4'd1;
				end
				3'd5 : // J
				begin 
					nx1 <= 3'd5;
					nx2 <= 3'd4;
					nx3 <= 3'd3;
					nx4 <= 3'd3;
					ny1 <= 4'd1; 
					ny2 <= 4'd1;
					ny3 <= 4'd1;
					ny4 <= 4'd0;
				end
				3'd6 : // T
				begin 
					nx1 <= 3'd3;
					nx2 <= 3'd4;
					nx3 <= 3'd4;
					nx4 <= 3'd5;
					ny1 <= 4'd1; 
					ny2 <= 4'd0;
					ny3 <= 4'd1;
					ny4 <= 4'd1;
				end
				default : 
				begin 
					nx1 <= 3'd3;
					nx2 <= 3'd4;
					nx3 <= 3'd4;
					nx4 <= 3'd5;
					ny1 <= 4'd1; 
					ny2 <= 4'd0;
					ny3 <= 4'd1;
					ny4 <= 4'd1;
				end
			endcase
			new_map  = 128'd0;
			drop_clk <= 14'd0;
		end
		else if( drop_clk == 14'd7500 ) begin // 每到了要檢查drop的時候, 整個always block就只會進到這個else if
			drop_clk <= 14'd0;
			if(((y1+1) == 16) || ((y2+1) == 16) || ((y3+1) == 16) || ((y4+1) == 16) // 碰到底||下面有方塊 導致不能下降就停
			  || map[y1*8+x1+8] || map[y2*8+x2+8] || map[y3*8+x3+8] || map[y4*8+x4+8])
			begin 
//				if( y1==0 || y2==0 || y3==0 || y4==0 ) begin // 剛出的方塊馬上就碰到頂了, 結束遊戲
//					
				placed = 1;
				// 把現方塊併入地圖
				new_map = (1'b1 << ((y1*8) +x1)) | (1'b1 << ((y2*8) +x2)) | (1'b1 << ((y3*8) +x3)) | (1'b1 << ((y4*8) +x4)) | map;
							
				//土法煉鋼 判斷消行
				if(new_map[7:0] == 8'b11111111)
				begin
					row = row + 1;
					new_map[15:8] = new_map[7:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================	
				if(new_map[15:8] == 8'b11111111)
				begin
					row = row + 1;
					new_map[15:8] = new_map[7:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================	
				if(new_map[23:16] == 8'b11111111)
				begin
					row = row + 1;
					new_map[23:8] = new_map[15:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================	
				if(new_map[31:24] == 8'b11111111)
				begin
					row = row + 1;
					new_map[31:8] = new_map[23:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================	
				if(new_map[39:32] == 8'b11111111)
				begin
					row = row + 1;
					new_map[39:8] = new_map[31:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================	
				if(new_map[47:40] == 8'b11111111)
				begin
					row = row + 1;
					new_map[47:8] = new_map[39:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================	
				if(new_map[55:48] == 8'b11111111)
				begin
					row = row + 1;
					new_map[55:8] = new_map[47:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================
				if(new_map[63:56] == 8'b11111111)
				begin
					row = row + 1;
					new_map[63:8] = new_map[55:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================
				if(new_map[71:64] == 8'b11111111)
				begin
					row = row + 1;
					new_map[71:8] = new_map[63:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================
				if(new_map[79:72] == 8'b11111111)
				begin
					row = row + 1;
					new_map[79:8] = new_map[71:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================	
				if(new_map[87:80] == 8'b11111111)
				begin
					row = row + 1;
					new_map[87:8] = new_map[79:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================
				if(new_map[95:88] == 8'b11111111)
				begin
					row = row + 1;
					new_map[95:8] = new_map[87:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================
				if(new_map[103:96] == 8'b11111111)
				begin
					row = row + 1;
					new_map[103:8] = new_map[95:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================
				if(new_map[111:104] == 8'b11111111)
				begin
					row = row + 1;
					new_map[111:8] = new_map[103:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================
				if(new_map[119:112] == 8'b11111111)
				begin
					row = row + 1;
					new_map[119:8] = new_map[111:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
				//===================================
				if(new_map[127:120] == 8'b11111111)
				begin
					row = row + 1;
					new_map[127:8] = new_map[119:0];
					new_map[7:0] = 8'b00000000;
				end
				else
					new_map[7:0] = new_map[7:0];
					
				if(row[4:0] == 5'b01010)
				begin	
					row[4:0] = 5'b00000;
					row = row + 10'b0000100000;	
				end
				else
					row = row;
					
				case (new_block_id) // 新方塊的y寫在這
					3'd0 : // I
					begin 					
						nx1 <= 3'd2;
						nx2 <= 3'd3;
						nx3 <= 3'd4;
						nx4 <= 3'd5;
						ny1 <= 4'd0; 
						ny2 <= 4'd0;
						ny3 <= 4'd0;
						ny4 <= 4'd0;
					end
					3'd1 : // O
					begin 
						nx1 <= 3'd3;
						nx2 <= 3'd4;
						nx3 <= 3'd3;
						nx4 <= 3'd4;
						ny1 <= 4'd0; 
						ny2 <= 4'd0;
						ny3 <= 4'd1;
						ny4 <= 4'd1;
					end
					3'd2 : // Z
					begin 
						nx1 <= 3'd3;
						nx2 <= 3'd4;
						nx3 <= 3'd4;
						nx4 <= 3'd5;
						ny1 <= 4'd0; 
						ny2 <= 4'd0;
						ny3 <= 4'd1;
						ny4 <= 4'd1;
					end
					3'd3 : // S
					begin 
						nx1 <= 3'd3;
						nx2 <= 3'd4;
						nx3 <= 3'd4;
						nx4 <= 3'd5;
						ny1 <= 4'd1; 
						ny2 <= 4'd1;
						ny3 <= 4'd0;
						ny4 <= 4'd0;
					end
					3'd4 : // L
					begin 
						nx1 <= 3'd5;
						nx2 <= 3'd4;
						nx3 <= 3'd3;
						nx4 <= 3'd3;
						ny1 <= 4'd0; 
						ny2 <= 4'd0;
						ny3 <= 4'd0;
						ny4 <= 4'd1;
					end
					3'd5 : // J
					begin 
						nx1 <= 3'd5;
						nx2 <= 3'd4;
						nx3 <= 3'd3;
						nx4 <= 3'd3;
						ny1 <= 4'd1; 
						ny2 <= 4'd1;
						ny3 <= 4'd1;
						ny4 <= 4'd0;
					end
					3'd6 : // T
					begin 
						nx1 <= 3'd3;
						nx2 <= 3'd4;
						nx3 <= 3'd4;
						nx4 <= 3'd5;
						ny1 <= 4'd1; 
						ny2 <= 4'd0;
						ny3 <= 4'd1;
						ny4 <= 4'd1;
					end
					default : 
					begin 
						nx1 <= 3'd3;
						nx2 <= 3'd4;
						nx3 <= 3'd4;
						nx4 <= 3'd5;
						ny1 <= 4'd1; 
						ny2 <= 4'd0;
						ny3 <= 4'd1;
						ny4 <= 4'd1;
					end
				endcase
			end
			else
			begin//能下降就下降
				placed = 0;
				ny1 = y1 + 4'b1; 
				ny2 = y2 + 4'b1; 
				ny3 = y3 + 4'b1; 
				ny4 = y4 + 4'b1; 
			end
		end
		else if( !placed && left_btn ) begin // hierachy : 往左移判斷>往右移判斷>旋轉判斷, 一次只會有一種, 前面判斷true後面就不會被判斷到
			if (nx1==0 || nx2==0 || nx3== 0 || nx4== 0 //碰左牆 || 有東西在左邊
			 || map[nx1+ y1*8 - 1] || map[nx2+ y2*8 - 1] || map[nx3+ y3*8 - 1] || map[nx4+ y4*8 - 1])
			begin
				nx1 <= nx1;
				nx2 <= nx2;
				nx3 <= nx3;
				nx4 <= nx4;
			end 
			else 
			begin
				nx1 <= nx1 - 1;
				nx2 <= nx2 - 1;
				nx3 <= nx3 - 1;
				nx4 <= nx4 - 1;
			end
		end
		else if( !placed && right_btn ) begin
			if (nx1==7 || nx2==7 || nx3==7 || nx4==7 //碰右牆 || 有東西在右邊
			 || map[nx1+ y1*8 + 1] || map[nx2+ y2*8 + 1] || map[nx3+ y3*8 + 1] || map[nx4+ y4*8 + 1])
			begin
				nx1 <= nx1;
				nx2 <= nx2;
				nx3 <= nx3;
				nx4 <= nx4;
			end 
			else 
			begin
				nx1 <= nx1 + 1;
				nx2 <= nx2 + 1;
				nx3 <= nx3 + 1;
				nx4 <= nx4 + 1;
			end
		end
		else if( !placed && rotate_btn ) begin
			rx1 = y3-y1  + nx3;
			rx2 = y3-y2  + nx3;
			rx4 = y3-y4  + nx3;
			ry1 = nx1-nx3 +ny3;
			ry2 = nx2-nx3 +ny3;
			ry4 = nx4-nx3 +ny3;
			
			// cut //
			if (ry1<0 || ry2<0 ||ry4<0 || ry1>15 || ry2>15 ||ry4>15) //碰上下牆,救不了
				begin
				nx1 <= nx1;
				nx2 <= nx2;
				nx3 <= nx3;
				nx4 <= nx4;
				ny1 <= ny1;
				ny2 <= ny2;
				ny3 <= ny3;
				ny4 <= ny4;
				end
			else if (!map[ ry1*8+rx1 ] && !map[ ry2*8+rx2 ] && !map[ ny3*8+nx3 ] && !map[ ry4*8+rx4 ] //待轉格子沒東西 && 沒碰右 && 左牆壁
					&& rx1<8 && rx2<8 && rx4<8
					&& rx1>0	&& rx2>0	&& rx4>0)
				begin
				fix_x = 0;
				nx1 <= rx1 +fix_x;
				nx2 <= rx2 +fix_x;
				nx3 <= nx3 +fix_x;
				nx4 <= rx4 +fix_x;
				ny1 <= ry1;
				ny2 <= ry2;
				ny3 <= ny3;
				ny4 <= ry4;
				end
			else if (!map[ ry1*8+rx1+1 ] && !map[ ry2*8+rx2+1 ] && !map[ ny3*8+nx3+1 ] && !map[ ry4*8+rx4+1 ]
					&& rx1+1<8 && rx2+1<8 && rx4+1<8
					&& rx1+1>=0	&& rx2+1>=0	&& rx4+1>=0)
				begin
				fix_x = 1;
				nx1 <= rx1 +fix_x;
				nx2 <= rx2 +fix_x;
				nx3 <= nx3 +fix_x;
				nx4 <= rx4 +fix_x;
				ny1 <= ry1;
				ny2 <= ry2;
				ny3 <= ny3;
				ny4 <= ry4;
				end
			else if (!map[ ry1*8+rx1-1 ] && !map[ ry2*8+rx2-1 ] && !map[ ny3*8+nx3-1 ] && !map[ ry4*8+rx4-1 ]
					&& rx1-1<8 && rx2-1<8 && rx4-1<8
					&& rx1-1>=0	&& rx2-1>=0	&& rx4-1>=0)
				begin
				fix_x = -1;
				nx1 <= rx1 +fix_x;
				nx2 <= rx2 +fix_x;
				nx3 <= nx3 +fix_x;
				nx4 <= rx4 +fix_x;
				ny1 <= ry1;
				ny2 <= ry2;
				ny3 <= ny3;
				ny4 <= ry4;
				end
			else if (!map[ ry1*8+rx1+2 ] && !map[ ry2*8+rx2+2 ] && !map[ ny3*8+nx3+2 ] && !map[ ry4*8+rx4+2 ]
					&& rx1+2<8 && rx2+2<8 && rx4+2<8
					&& rx1+2>=0	&& rx2+2>=0	&& rx4+2>=0)
				begin
				fix_x = 2;
				nx1 <= rx1 +fix_x;
				nx2 <= rx2 +fix_x;
				nx3 <= nx3 +fix_x;
				nx4 <= rx4 +fix_x;
				ny1 <= ry1;
				ny2 <= ry2;
				ny3 <= ny3;
				ny4 <= ry4;
				end
			else if (!map[ ry1*8+rx1-2 ] && !map[ ry2*8+rx2-2 ] && !map[ ny3*8+nx3-2 ] && !map[ ry4*8+rx4-2 ]
					&& rx1-2<8 && rx2-2<8 && rx4-2<8
					&& rx1-2>=0	&& rx2-2>=0	&& rx4-2>=0)
				begin
				fix_x = -2;
				nx1 <= rx1 +fix_x;
				nx2 <= rx2 +fix_x;
				nx3 <= nx3 +fix_x;
				nx4 <= rx4 +fix_x;
				ny1 <= ry1;
				ny2 <= ry2;
				ny3 <= ny3;
				ny4 <= ry4;
				end
			else
				begin
				fix_x = 4;
				nx1 <= nx1;
				nx2 <= nx2;
				nx3 <= nx3;
				nx4 <= nx4;
				ny1 <= ny1;
				ny2 <= ny2;
				ny3 <= ny3;
				ny4 <= ny4;
				end
		// cut //
		end
		else 
			drop_clk <= drop_clk+1;
	end
endmodule 
		














