module board_display(CLK,map,stop,block1_x,block1_y,block2_x,block2_y,block3_x,block3_y,block4_x,block4_y,row,col);
	input CLK;
	input [2:0] block1_x,block2_x,block3_x,block4_x;//生成方塊的x座標
	input [3:0] block1_y,block2_y,block3_y,block4_y;//生成方塊的y座標
	input [127:0] map;
	output reg [7:0] row;
	output reg [15:0] col;
	reg [127:0] t_map;
	reg [3:0] col_count;
	always@(posedge CLK)
	begin
		t_map <= map | (1 << (block1_x+8*block1_y)) | (1 << (block2_x+8*block2_y)) | (1 << (block3_x+8*block3_y)) | (1 << (block4_x+8*block4_y));
		col_count <= col_count + 1;
		case(col_count)
			4'd0 : col <= 16'b1000000000000000;
			4'd1 : col <= 16'b0100000000000000;
			4'd2 : col <= 16'b0010000000000000;
			4'd3 : col <= 16'b0001000000000000;
			4'd4 : col <= 16'b0000100000000000;
			4'd5 : col <= 16'b0000010000000000;
			4'd6 : col <= 16'b0000001000000000;
			4'd7 : col <= 16'b0000000100000000;
			4'd8 : col <= 16'b0000000010000000;
			4'd9 : col <= 16'b0000000001000000;
			4'd10: col <= 16'b0000000000100000;
			4'd11: col <= 16'b0000000000010000;
			4'd12: col <= 16'b0000000000001000;
			4'd13: col <= 16'b0000000000000100;
			4'd14: col <= 16'b0000000000000010;
			4'd15: col <= 16'b0000000000000001;
			default : col <= 16'b0000000000000000;
		endcase
		case(col_count)
			4'd0 : row <= ~(t_map[7:0]);
			
			4'd1 : row <= ~(t_map[15:8]);
			4'd2 : row <= ~(t_map[23:16]);
			4'd3 : row <= ~(t_map[31:24]);
			4'd4 : row <= ~(t_map[39:32]);
			4'd5 : row <= ~(t_map[47:40]);
			4'd6 : row <= ~(t_map[55:48]);
			4'd7 : row <= ~(t_map[63:56]);
			4'd8 : row <= ~(t_map[71:64]);
			4'd9 : row <= ~(t_map[79:72]);
			4'd10: row <= ~(t_map[87:80]);
			4'd11: row <= ~(t_map[95:88]);
			4'd12: row <= ~(t_map[103:96]);
			4'd13: row <= ~(t_map[111:104]);
			4'd14: row <= ~(t_map[119:112]);
			4'd15: row <= ~(t_map[127:120]);
			default : row <= 8'd0;
		endcase
	end
endmodule
