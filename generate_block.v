module generate_block(CLK, disabled, a, random_id);
	input CLK, disabled;
	output reg [20:0]a;
	output reg [2 : 0] random_id;
	
	initial 
	begin
		a = 0;
	end
	always@(posedge CLK) begin
		if (!disabled)
			random_id = random_id;
		else
		begin
			case(a) 
				0 :random_id = 3'd3;
				1 :random_id = 3'd6;
				2 :random_id = 3'd5;
				3 :random_id = 3'd1;
				4 :random_id = 3'd2;
				5 :random_id = 3'd0;
				6 :random_id = 3'd4;
				7 :random_id = 3'd2;
				8 :random_id = 3'd1;
				9 :random_id = 3'd6;
				10:random_id = 3'd5;
				11:random_id = 3'd4;
				12:random_id = 3'd3;
				13:random_id = 3'd0;
				14:random_id = 3'd3;
				15:random_id = 3'd4;
				16:random_id = 3'd2;
				17:random_id = 3'd0;
				18:random_id = 3'd5;
				19:random_id = 3'd1;
				20:random_id = 3'd6;
				default:random_id = 3'd0;
			endcase
			a = ( a + 1 ) % 21;
//			random_id <= {$random(seed)} % 7;
//			case(a)
//				0: random = 3'd0;
//				1: random = 3'd1;
//				2: random = 3'd2;
//				3: random = 3'd3;
//				4: random = 3'd4;
//				5: random = 3'd5;
//				6: random = 3'd6;
//				default: random = 3'd0;
//			endcase
		end
	end
endmodule
