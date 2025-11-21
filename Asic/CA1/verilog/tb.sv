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

    initial begin
        rst = 1'b1;

        #15;

        rst = 1'b0;

        #15;

        @(posedge clk) start = 1'b1;
        A = 8'd25;
        B = ~8'd110 + 1;
        @(posedge clk) start = 1'b0;
        @(posedge done);


        @(posedge clk) start = 1'b1;
        A = 8'd100;
        B = ~8'd12 + 1;
        @(posedge clk) start = 1'b0;
        @(posedge done);

        # 30 $stop;



    end

endmodule
