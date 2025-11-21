// **************************************************************************************
// Filename: aftab_divider_TB.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_divider_TB
// Description:
//
// Dependencies:
//
// File content description:
// divider_TB for AFTAB AAU divider testing
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_divider_TB();
    reg start, rst;
    reg clk=1;
    reg [32:0] Divisor, Devidend;
    wire [32:0] Quotient, Remainder;
    wire ready;
    wire DevZero;

    aftab_divider #(33) CUT(Devidend, Divisor, start, clk, rst, Quotient, Remainder, ready, DevZero);

    initial repeat(300) #10 clk = ~clk;

    initial begin
    start = 0;
    rst = 1;
    #5;
    rst = 0;
    Divisor = 33'd7;
    Devidend = 33'd120;
    #5;
    start = 1;
    #40;
    start = 0;
    end
endmodule
