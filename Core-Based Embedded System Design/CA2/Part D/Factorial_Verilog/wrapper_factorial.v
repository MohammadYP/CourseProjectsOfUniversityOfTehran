module wrapper_factorial (
    input clk,
    input rst,
    input writeBus,
    input [7:0] dataBusIn,
    input [31:0] addressBus,

    output [7:0] dataBusOut
);
    localparam N_WIDTH = 8;
    localparam FN_WIDTH = 32;

    wire start;
    wire done;
    wire loadN;
    wire loadCNF;
    wire [7:0] n;
    wire [7:0] fcnfOut;
    wire [31:0] fn;


    factorial #(
        .N_WIDTH(N_WIDTH),
        .FN_WIDTH(FN_WIDTH)
    ) FACT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .n(n),
        .fn(fn) 
    );
	
    register #(
        .WIDTH(8)
    ) nReg (
        .clk(clk),
        .rst(rst),
        .ld(loadN),
        .datain(dataBusIn),
        .dataout(n)
    );

    fact_CNFregister #(
        .SIZE(8)
    )fcnf(
        .clk(clk),
        .rst(rst),
        .load(loadCNF),
        .done(done & fcnfOut[0]),
        .in(dataBusIn),
        .out(fcnfOut)
    );

    assign start = fcnfOut[1];
    // 0: int en
    // 1: start 
    // 2: done

    assign loadN = (writeBus && addressBus == 32'd0)? 1'b1 : 1'b0;
    assign loadCNF = (writeBus && addressBus == 32'd8)? 1'b1 : 1'b0;

    assign dataBusOut = (addressBus == 32'd4) ? fn[7:0] :
                        (addressBus == 32'd5) ? fn[15:8] :
                        (addressBus == 32'd6) ? fn[23:16] :
                        (addressBus == 32'd7) ? fn[32:24] :
                        (addressBus == 32'd8) ? fcnfOut[7:0] :
                        32'b0;

endmodule