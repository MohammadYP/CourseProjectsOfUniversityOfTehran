module tb ();
    
    reg clk = 0;
    reg rst = 0;
    reg start = 0;
    reg [7:0] A = 0;
    reg [7:0] B = 0;
    
    wire done;
    wire [15:0] outR;

    booth mul(
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .done(done),
        .outR(outR)
    );

    always #5 clk = ~clk;

    int expected, A_e, B_e;

    initial begin
        rst = 1'b1;

        #15;

        rst = 1'b0;

        #15;

        // @(posedge clk) start = 1'b1;
        // A = 8'd25;
        // B = ~8'd110 + 1;
        // @(posedge clk) start = 1'b0;
        // @(posedge done);


        // @(posedge clk) start = 1'b1;
        // A = 8'd100;
        // B = ~8'd12 + 1;
        // @(posedge clk) start = 1'b0;
        // @(posedge done);

        repeat (10) begin
            @(posedge clk);
            A = $random;
            B = $random;  
            start = 1;
            @(posedge clk);
            start = 0;

            @(posedge done);
            A_e = signed'(A);
            B_e = signed'(B);
            expected = A_e * B_e;
            $display("Test: A = %d, B = %d, Expected = %d, Result = %d", signed'(A), signed'(B), expected, signed'(outR));
            
            assert (signed'(outR) !== expected)
                $display("ERROR: Incorrect multiplication result!");
            else 
                $display("FINE: The result is correct");
        end
        # 30 $stop;

    end

    sequence s1;
		(##[1:$] done ##1 ~done);
	endsequence

	property pr1;
		@(posedge clk) start |-> s1;
	endproperty

    done_check: assert property (pr1) $display($stime,,,"\t\t %m done is properly working");
	else $display($stime,,,"\t\t %m done goes wrong");



endmodule
