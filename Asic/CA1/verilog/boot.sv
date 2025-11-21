module booth (
    input clk,
    input rst,
    input start,
    input [7:0] A,
    input [7:0] B,
    output done,
    output [15:0] outR
);
    
    wire loadA;
    wire loadB;
    wire loadR;
    wire clearA;
    wire clearB;
    wire clearR;
    wire shiftA;
    wire cntE;
    wire loadC;
    wire clearC;
    wire [1:0] cntOut;

    datapath dp(
        .clk(clk),
        .rst(rst),
        .loadA(loadA),
        .loadB(loadB),
        .loadR(loadR),
        .clearA(clearA),
        .clearB(clearB),
        .clearR(clearR),
        .shiftA(shiftA),
        .cntE(cntE),
        .loadC(loadC),
        .clearC(clearC),
        .inA(A),
        .inB(B),
        .cntOut(cntOut),
        .outR(outR)
    );

    controller cnt(
        .clk(clk),
        .rst(rst),
        .start(start),
        .cntOut(cntOut),
        .loadA(loadA),
        .loadB(loadB),
        .loadR(loadR),
        .clearA(clearA),
        .shiftA(shiftA),
        .clearB(clearB),
        .clearR(clearR),
        .cntE(cntE),
        .loadC(loadC),
        .clearC(clearC),
        .done(done)
    );

endmodule