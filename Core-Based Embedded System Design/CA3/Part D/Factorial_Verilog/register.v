module register ( clk, rst, ld, datain, dataout);
	// parameters
	parameter WIDTH = 8;
	
	// interfaces
	input	clk;
	input	rst;
	input	ld;
	input		[WIDTH - 1:0] datain;
	output reg 	[WIDTH - 1:0] dataout;
	
	always @(posedge clk ) begin
		if( rst )
			dataout <= 0;
		else if( ld )
			dataout <= datain;
	end
endmodule
