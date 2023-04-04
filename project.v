module project(CLK,reset,out,out2,dot_row,dot_col, right_button, left_button, rotate_button);
	input reset,CLK, right_button, left_button, rotate_button;
	wire [2:0] block1_x,block2_x,block3_x,block4_x;//生成方塊的x座標
	wire [3:0] block1_y,block2_y,block3_y,block4_y;//生成方塊的y座標
	wire [2:0] next_block1_x,next_block2_x,next_block3_x,next_block4_x;//下落方塊的x座標
	wire [3:0] next_block1_y,next_block2_y,next_block3_y,next_block4_y;//下落方塊的y座標
	
	wire [127:0] map;// 0為左上角127為右下角
	wire [9:0] row;
	output [6:0] out,out2;
	output [7:0] dot_row;
	output [15:0]dot_col;
   //reg stop;//停下
	wire stop;
	wire placed;//已無法移動
	wire Second;//每"Second"下降
	wire [2 : 0] new_block_id;
	
	wire right_button_debounced; // for debouncing button
	wire left_button_debounced;
	wire rotate_button_debounced;
	
	// reg a in generate_block
	wire a;
	
	//當placed == 1，表示其已經無法繼續下降，請生成新的方塊
	
	counter c(CLK,Second);//秒的分頻器
	
	counter2 c2(CLK,dis);//點矩陣的分頻器
	
	dot_display dd(row,out,out2);//七段顯示器顯示
	
	//debounce button 每個button都要!!
	oneshot debouncer_right_button(.clock(dis), .din(right_button), .dout(right_button_debounced));
	oneshot debouncer_left_button(.clock(dis), .din(left_button), .dout(left_button_debounced));
	oneshot d_rotate_btn( dis, rotate_button, rotate_button_debounced);
	
	//generate new block when hit floor
	generate_block gb(.CLK(Second), .disabled(placed), .random_id(new_block_id));
	
	change_position cp(
		CLK,placed,reset,
		next_block1_x,next_block1_y,
		next_block2_x,next_block2_y,
		next_block3_x,next_block3_y,
		next_block4_x,next_block4_y,
		block1_x,block1_y,
		block2_x,block2_y,
		block3_x,block3_y,
		block4_x,block4_y);
	
	// 方塊所有的移動都在這
	// 之前down move跟y綁著 left_right跟x綁著 旋轉不好寫
	move_control mc(
		dis, reset, left_button_debounced, right_button_debounced, rotate_button_debounced, 
		map, map, placed, new_block_id, row, stop,
		block1_x,block2_x,block3_x,block4_x,
		block1_y,block2_y,block3_y,block4_y,
		next_block1_x,next_block2_x,next_block3_x,next_block4_x,
		next_block1_y,next_block2_y,next_block3_y,next_block4_y);

		//點矩陣顯示
	board_display bd(
		dis,map, stop,
		block1_x,block1_y,
		block2_x,block2_y,
		block3_x,block3_y,
		block4_x,block4_y,
		dot_row,dot_col);
endmodule 
