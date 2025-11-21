// **************************************************************************************
// Filename: aftab_divider.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_divider
// Description:
//
// Dependencies:
//
// File content description:
// divider for AFTAB AAU
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_divider #(parameter size = 33) (
    input clk,
    input rst,
    input startDiv,
    output doneDiv,
    input [size-1:0] dividend,
    input [size-1:0] divisor,
    output [size-1:0] Q,
    output [size:0] Remainder
);

    wire signR;
    wire ldRegR;
    wire zeroRegR;
    wire Q0;
    wire seldividend;
    wire selshQ;
    wire ldRegQ;
    wire zeroRegQ;
    wire zeroRegM;
    wire ldRegM;
    wire coCnt;
    wire shL_R;
    wire shL_Q;

    aftab_divider_datapath #(size) DP (
        .clk(clk),
        .rst(rst),
        .Dividend(dividend),
        .Divisor(divisor),
        .ldRegR(ldRegR),
        .zeroRegR(zeroRegR),
        .Q0(Q0),
        .seldividend(seldividend),
        .selshQ(selshQ),
        .ldRegQ(ldRegQ),
        .zeroRegQ(zeroRegQ),
        .zeroRegM(zeroRegM),
        .ldRegM(ldRegM),
        .shL_R(shL_R),
        .shL_Q(shL_Q),
        .signR(signR),
        .Q(Q),
        .Remainder(Remainder)
    );

    aftab_divider_controller #(size) CU (
        .clk(clk),
        .rst(rst),
        .startDiv(startDiv),
        .signR(signR),
        .doneDiv(doneDiv),
        .ldRegR(ldRegR),
        .zeroRegR(zeroRegR),
        .seldividend(seldividend),
        .selshQ(selshQ),
        .ldRegQ(ldRegQ),
        .zeroRegQ(zeroRegQ),
        .ldRegM(ldRegM),
        .zeroRegM(zeroRegM),
        .shL_R(shL_R),
        .shL_Q(shL_Q),
        .Q0(Q0)
    );

endmodule