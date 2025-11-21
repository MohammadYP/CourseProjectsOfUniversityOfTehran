// **************************************************************************************
// Filename: aftab_divider_datapath.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_divider_datapath
// Description:
//
// Dependencies:
//
// File content description:
// divider_DP for AFTAB AAU
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_divider_datapath #(parameter size = 33) (
    input clk,
    input rst,
    input [size-1:0] Dividend,
    input [size-1:0] Divisor,
    input ldRegR,
    input zeroRegR,
    input Q0,
    input seldividend,
    input selshQ,
    input ldRegQ,
    input zeroRegQ,
    input zeroRegM,
    input ldRegM,
    input shL_R,
    input shL_Q,
    output signR,
    output [size-1:0] Q,
    output [size:0] Remainder
);

    wire [size:0] AddResult;
    wire [size:0] sub;
    wire [size:0] M;
    wire [size:0] divisorp;
    wire [size:0] Rprev;
    wire [size-1:0] temp;
    wire [size-1:0] outMux1;
    wire [size-1:0] Qprev;
    wire posNegbar;
    wire leftbitOutQ;

    assign signR = sub[size];

    aftab_shift_left_register #(size+1) RegR(
        .dataIn(AddResult),
        .sh_L_en(shL_R),
        .init(zeroRegR),
        .serIn(leftbitOutQ),
        .clk(clk),
        .rst(rst),
        .Ld(ldRegR),
        .dataOut(Rprev),
        .serOut()
    );

    aftab_shift_left_register #(size) RegQ(
        .dataIn(outMux1),
        .sh_L_en(shL_Q),
        .init(zeroRegQ),
        .serIn(1'b0),
        .clk(clk),
        .rst(rst),
        .Ld(ldRegQ),
        .dataOut(Qprev),
        .serOut(leftbitOutQ)
    );

    assign divisorp = {1'b0, Divisor};

    aftab_register #(size+1) RegM(
        .in(divisorp),
        .ldR(ldRegM),
        .clk(clk),
        .zero(zeroRegM),
        .rst(rst),
        .out(M)
    );

    aftab_adder_subtractor #(size+1) SUB (
        .a(Rprev),
        .b(M),
        .subsel(1'b1),
        .pass(1'b0),
        .cout(),
        .result(sub)
    );

    assign temp = {Qprev[size-1:1], Q0};

    aftab_mux2to1_2sel #(size) Mux1 (
        .i0(Dividend),
        .i1(temp),
        .s0(seldividend),
        .s1(selshQ),
        .w(outMux1)
    );

    assign posNegbar = ~sub[size];

    aftab_mux2to1_2sel #(size+1) MuxAR(
        .i0(sub),
        .i1(Rprev),
        .s0(posNegbar),
        .s1(sub[size]),
        .w(AddResult)
    );

    assign Remainder = Rprev;

    assign Q = Qprev;

endmodule