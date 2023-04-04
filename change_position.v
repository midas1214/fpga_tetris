module change_position(CLK,placed,reset,
	next_block1_x,next_block1_y,
	next_block2_x,next_block2_y,
	next_block3_x,next_block3_y,
	next_block4_x,next_block4_y,
	block1_x,block1_y,
	block2_x,block2_y,
	block3_x,block3_y,
	block4_x,block4_y);
	
	initial begin 
		block1_x = 3'd2;
		block2_x = 3'd3;
		block3_x = 3'd4;
		block4_x = 3'd5;
	end
	input reset,CLK,placed;
	input [2:0] next_block1_x,next_block2_x,next_block3_x,next_block4_x;//下落方塊的x座標
	input [3:0] next_block1_y,next_block2_y,next_block3_y,next_block4_y;//下落方塊的y座標
	output reg [2:0] block1_x,block2_x,block3_x,block4_x;//生成方塊的x座標
	output reg [3:0] block1_y,block2_y,block3_y,block4_y;//生成方塊的y座標
	always@(posedge CLK or negedge placed or negedge reset)
	begin
		block1_x = next_block1_x;
		block2_x = next_block2_x;
		block3_x = next_block3_x;
		block4_x = next_block4_x; 
		block1_y = next_block1_y;
		block2_y = next_block2_y;
		block3_y = next_block3_y;
		block4_y = next_block4_y;
	end
endmodule
