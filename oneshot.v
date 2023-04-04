module oneshot(clock, din, dout);
	input clock;
	input din;
	output dout;
	reg [1:0] ss;
	always @(posedge clock)
	begin
		case(ss)
			2'b00:
				if(~din) //若 push button 為共陰極用~din，共陽用 din
					ss<=2'b01;
			2'b01:
				ss<=2'b10;
			2'b10:
				if(din) //若 push button 為共陰極用 din，共陽用~din
					ss<=2'b00;
			default:
				ss<=2'b00;
		endcase
	end
	assign dout=ss[0];
endmodule 