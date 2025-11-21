
`define	IDLE	0
`define	LOAD	1
`define	ITER	2
`define	STOR	3

module factorial ( clk, rst, start, done, n, fn);
	// parameters
	parameter N_WIDTH = 8;
	parameter FN_WIDTH = 32;
	// interfaces
	input		clk;
	input		rst;
	input		start;
	output reg 	done;
	input  [N_WIDTH - 1:0]		n;
	output [FN_WIDTH - 1: 0 ]	fn;

	// signals
	wire [N_WIDTH - 1:0] a_in, a_reg, a_min1;
	wire [FN_WIDTH - 1:0] p_in, p_reg, aXp;
	reg sel_a, sel_p, ld_a, ld_p, ld_fn;
	wire a_1;
	reg [2:0] ps, ns;	// present state, next state
	
	// Datapath --------------------------------------
	assign a_in = sel_a ? n : a_min1;
	assign p_in = sel_p ? 1 : aXp;
	
	register #(.WIDTH(N_WIDTH))
		REG_A (	.clk(clk),
				.rst(rst),
				.ld(ld_a),
				.datain(a_in),
				.dataout(a_reg) );
	
	register #(.WIDTH(FN_WIDTH))
		REG_P (	.clk(clk),
				.rst(rst),
				.ld(ld_p),
				.datain(p_in),
				.dataout(p_reg) );
	
	assign a_min1 = a_reg - 1;
	
	assign a_1 = (a_reg == 1) ? 1 : 0;
	
	multiplier #(.I_WIDTH(N_WIDTH),
				 .O_WIDTH(FN_WIDTH))
		MUL_AXP (.datain1(a_reg),
				 .datain2(p_reg),
				 .dataout(aXp) );
	
	register #(.WIDTH(FN_WIDTH))
		REG_FN(	.clk(clk),
				.rst(rst),
				.ld(ld_fn),
				.datain(p_reg),
				.dataout(fn) );
	
	// Controller --------------------------------------
	always @(posedge clk ) begin
		if( rst )
			ps <= `IDLE;
		else
			ps <= ns;
	end
	
	always @( ps, start, a_1 ) begin
		ns <= `IDLE;
		case ( ps )
			`IDLE : begin
				if( start )
					ns <= `LOAD;
				else
					ns <= `IDLE;
			end
			`LOAD : begin
				ns <= `ITER;
			end
			`ITER : begin
				if( a_1 )
					ns <= `STOR;
				else
					ns <= `ITER;
			end
			`STOR : begin
				ns <= `IDLE;
			end
		endcase
	end
	
	always @( ps ) begin
		done <= 0;
		sel_a <= 0;
		sel_p <= 0;
		ld_a <= 0;
		ld_p <= 0;
		ld_fn <= 0;
		case ( ps )
			`IDLE : begin
				done <= 1;
			end
			`LOAD : begin
				sel_a <= 1;
				sel_p <= 1;
				ld_a <= 1;
				ld_p <= 1;
			end
			`ITER : begin
				ld_a <= 1;
				ld_p <= 1;
			end
			`STOR : begin
				ld_fn <= 1;
			end
		endcase
	end
	
endmodule


