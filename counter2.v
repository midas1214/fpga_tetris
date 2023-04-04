module counter2(CLK,CLK_out);
	input CLK;
	output CLK_out;
	reg CLK_out;
	reg [31:0] count;
	always@(posedge CLK)
	begin
		if(count == 32'd5000)
		begin
			CLK_out <= CLK + 1;
			count <= 0;
		end
		else
		begin
			CLK_out <= CLK;
			count <= count + 32'd1;
		end
	end
endmodule
