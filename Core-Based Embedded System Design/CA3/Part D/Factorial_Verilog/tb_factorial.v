module tb_factorial ();
	// parameters
	parameter N_WIDTH = 8;
	parameter FN_WIDTH = 32;
	// interfaces
	reg		clk;
	reg		rst;
	reg		start;
	wire 	done;
	reg  [N_WIDTH - 1:0]  n;
	wire [FN_WIDTH - 1:0] fn;
	
	factorial #(.N_WIDTH(N_WIDTH),
				.FN_WIDTH(FN_WIDTH))
		FACT (	.clk(clk),
				.rst(rst),
				.start(start),
				.done(done),
				.n(n),
				.fn(fn) );
	
	always
		#5 clk <= ~clk;
	
	initial begin 
		clk = 1;
		start = 0;
		n = 0;
		rst = 1;
		#10;
		rst = 0;
		start = 1;
		n = 10;
		#10;
		start = 0;
		#10;
		while(!done)
		begin
			#10;
		end
		#10;
		$stop();
	end
endmodule
