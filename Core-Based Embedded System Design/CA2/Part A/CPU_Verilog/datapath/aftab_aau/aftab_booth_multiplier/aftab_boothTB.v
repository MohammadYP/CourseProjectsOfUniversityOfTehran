// **************************************************************************************
// Filename: aftab_boothTB.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_boothTB
// Description:
//
// Dependencies:
//
// File content description:
// boothTB for AFTAB AAU multiplier testing
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_boothTB();
    reg [32:0] M;
    reg [32:0] Q;
    reg clk;
    reg rst;
    reg start;
    wire done;
    wire [65:0] P;

    aftab_booth #(33) CUT (
        .M(M),
        .Q(Q),
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .P(P)
    );

    initial repeat(300) #10 clk = ~clk;

    initial begin
    clk = 1;
    start = 0;
    rst = 1;
    #15;
    rst = 0;
    M = 33'd50;
    Q = -33'd3;
    #15;
    start = 1;
    #40;
    start = 0;
    end

endmodule