// **************************************************************************************
// Filename: aftab_booth_datapath.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_booth_datapath
// Description:
//
// Dependencies:
//
// File content description:
// booth_datapath for AFTAB AAU
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_booth_datapath #(parameter size = 33) (
    input clk,
    input rst,
    input shrMr,
    input ldMr,
    input ldM,
    input ldP,
    input zeroP,
    input sel,
    input subsel,
    input [size-1:0] M,
    input [size-1:0] Mr,
    output [2*size-1:0] P,
    output [1:0] op
);

    // Register M
    wire [size-1:0] outM;
    aftab_register #(size) mReg (
        .in(M),
        .out(outM),
        .clk(clk),
        .zero(1'b0),
        .rst(rst),
        .ldR(ldM)
    );

    // Shift Register Mr
    wire [size:0] outMr;
    wire seiMr;
    aftab_shift_right_register #(size+1) MrReg (
        .dataIn({Mr , 1'b0}),
        .dataOut(outMr),
        .init(1'b0),
        .clk(clk),
        .rst(rst),
        .sh_R_en(shrMr),
        .serIn(seiMr),
        .serOut(),
        .Ld(ldMr)
    );

    // Register P
    wire [size-1:0] Pout;
    wire [size-1:0] Pin;
    aftab_register #(size) pReg (
        .in(Pin),
        .out(Pout),
        .clk(clk),
        .zero(zeroP),
        .rst(rst),
        .ldR(ldP)
    );

    // Adder_Subtractor
    wire [size-1:0] result;
    aftab_adder_subtractor #(size) addSub (
        .a(Pout),
        .b(outM),
        .subsel(subsel),
        .pass(1'b0),
        .cout(),
        .result(result)
    );

    // Arithmetic Right Shift on Pout
    assign Pin = (sel) ? {result[size - 1] , result[size - 1:1]} : {Pout[size - 1] , Pout[size - 1:1]};

    assign seiMr = (sel) ? result[0] : Pout[0];

    assign op = outMr[1:0];

    assign P = {Pout , outMr[size:1]};
endmodule
