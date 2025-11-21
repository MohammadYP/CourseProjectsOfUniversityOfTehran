// **************************************************************************************
// Filename: aftab_booth.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_booth_multiplier
// Description:
//
// Dependencies:
//
// File content description:
// booth for AFTAB AAU
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_booth_multiplier #( parameter size = 33) (
    input [size-1:0] M,
    input [size-1:0] Mr,
    input clk,
    input rst,
    input start,
    output done,
    output [2*size-1:0] P
);

    wire [1:0] op;
    wire shrMr;
    wire ldMr;
    wire ldM;
    wire ldP;
    wire zeroP;
    wire sel;
    wire subsel;

    aftab_booth_datapath #(33) DP (
        .M(M),
        .Mr(Mr),
        .clk(clk),
        .rst(rst),
        .shrMr(shrMr),
        .ldMr(ldMr),
        .ldM(ldM),
        .ldP(ldP),
        .zeroP(zeroP),
        .sel(sel),
        .subsel(subsel),
        .P(P),
        .op(op)
    );

    aftab_booth_controller #(33) CU (
        .startBooth(start),
        .clk(clk),
        .rst(rst),
        .op(op),
        .shrMr(shrMr),
        .ldMr(ldMr),
        .ldM(ldM),
        .ldP(ldP),
        .zeroP(zeroP),
        .sel(sel),
        .subsel(subsel),
        .done(done)
    );

endmodule
