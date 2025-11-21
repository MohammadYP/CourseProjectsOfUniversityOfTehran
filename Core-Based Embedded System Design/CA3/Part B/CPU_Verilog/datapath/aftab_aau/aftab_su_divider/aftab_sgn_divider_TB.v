// **************************************************************************************
// Filename: aftab_sgn_divider_TB.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_sgn_divider_TB
// Description:
//
// Dependencies:
//
// File content description:
// sgn_divider_TB for AFTAB AAU su _divider testing
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_sgn_divider_TB();
    reg start, rst;
    reg clk = 1;
    reg [32:0] Divisor, Devidend;
    wire [32:0] Quotient, Remainder;
    wire ready;
    reg  SignedFlag;
    wire dividedByZeroFlag;

    aftab_signed_divider #(33) CUT(
        Devidend,
        Divisor,
        start,
        clk,
        rst,
        Quotient,
        Remainder,
        ready,
        SignedFlag,
        dividedByZeroFlag
    );

    initial repeat(1000) #10 clk = ~clk;

    initial begin
    SignedFlag = 1;
    start = 0;
    rst = 1;
    #5;
    rst = 0;
    Divisor = 33'd3;
    Devidend = -33'd13;
    #5;
    start = 1;
    #40;
    start = 0;
    #4000
    Devidend = 33'd100;
    Divisor = 33'd0;
    start = 1;
    #40;
    start = 0;
    #4000;
    end
endmodule