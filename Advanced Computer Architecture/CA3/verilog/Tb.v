`timescale 1ns/1ns
module tb();
	reg clk,rst=1'b0;
	
	mips mips_processor(.clk(clk),.rst(rst));
	
	always begin
		#5 clk = ~clk;
	end

initial begin
    clk = 1'b0;
	rst = 1'b1;
    #3 rst = 1'b0;
	#620000;
	#1000000;
	$stop;
end
    
endmodule
