// **************************************************************************************
// Filename: aftab_AAU.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_AAU
// Description:
//
// Dependencies:
//
// File content description:
// AAU for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_AAU #(parameter size = 32) (
    input [size-1:0] A,
    input [size-1:0] B,
    input clk,
    input rst,
    input multAAU,
    input divideAAU,
    input signedSigned,
    input signedUnsigned,
    input unsignedUnsigned,
    output [size-1:0] H,
    output [size-1:0] L,
    output completeAAU,
    output dividedByZeroFlag
);

    wire [size:0] input1;
    wire [size:0] input2;
    wire completeMult;
    wire completeDivide;
    wire signedUnsignedbarDiv;
    wire [2*size+1:0] multOut;
    wire [size-1:0] Quotient;
    wire [size-1:0] Remainder;
    wire [size-1:0] resMultL;
    wire [size-1:0] resMultH;

    assign input1 = (unsignedUnsigned == 1'b1) ? {1'b0, A} :
                    (signedSigned == 1'b1 || signedUnsigned == 1'b1) ? {A[size-1], A} :
                    {(size+1){1'b0}};

    assign input2 = (unsignedUnsigned == 1'b1 || signedUnsigned == 1'b1) ? {1'b0, B} :
                    (signedSigned == 1'b1) ?  {B[size-1], B} :
                    {(size+1){1'b0}};

     aftab_booth_multiplier #(size+1) MULT(
        .M(input1),
        .Mr(input2),
        .P(multOut),
        .clk(clk),
        .rst(rst),
        .start(multAAU),
        .done(completeMult)
    );
    assign resMultL = multOut[size-1:0];
    assign resMultH = multOut[2*size-1:size];

    assign signedUnsignedbarDiv = (signedSigned == 1'b1) ? 1'b1 :
                           (unsignedUnsigned == 1'b1) ? 1'b0 :
                           1'b0;

    aftab_signed_divider #(size) SGN_DIV(
        .clk(clk),
        .rst(rst),
        .startSDiv(divideAAU),
        .SignedUnsignedbar(signedUnsignedbarDiv),
        .dividend(A),
        .divisor(B),
        .dividedByZeroFlag(dividedByZeroFlag),
        .doneSDiv(completeDivide),
        .Qout(Quotient),
        .Remout(Remainder)
    );

    assign H = (completeMult == 1'b1) ? resMultH :
               (completeDivide == 1'b1) ? Quotient :
               {(size){1'b0}};

    assign L = (completeMult == 1'b1) ? resMultL :
               (completeDivide == 1'b1) ? Remainder :
               {(size){1'b0}};

    assign completeAAU = completeDivide | completeMult;

endmodule