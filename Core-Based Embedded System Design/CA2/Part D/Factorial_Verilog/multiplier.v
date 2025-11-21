module multiplier ( datain1, datain2, dataout);
	// parameters
	parameter I_WIDTH = 8;
	parameter O_WIDTH = 32;
	
	// interfaces
	input  [I_WIDTH - 1:0] datain1;
	input  [O_WIDTH - 1:0] datain2;
	output [O_WIDTH - 1:0] dataout;
	
	wire [O_WIDTH + I_WIDTH - 1:0] mul;
	
	assign mul = datain1 * datain2;
	
	assign dataout = mul[O_WIDTH-1:0];
	
endmodule
