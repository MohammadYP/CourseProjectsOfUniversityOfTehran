// **************************************************************************************
// Filename: aftab_signed_divider.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_signed_divider
// Description:
//
// Dependencies:
//
// File content description:
// signed_divider for AFTAB AAU
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_signed_divider #(parameter size = 33)(
    input clk,
    input rst,
    input startSDiv,
    input SignedUnsignedbar,
    input [size-1:0] dividend,
    input [size-1:0] divisor,
    output dividedByZeroFlag,
    output doneSDiv,
    output [size-1:0] Qout,
    output [size-1:0] Remout
);

    wire [size:0] Remp;
    wire [size-1:0] ddIn;
    wire [size-1:0] drIn;
    wire [size-1:0] Qp;
    wire endd;
    wire endr;
    wire enQ;
    wire enR;
    wire safeStart;
    wire divisorZero;

    assign divisorZero = (|divisor == 0) ? 1'b1 : 1'b0;

    assign dividedByZeroFlag = startSDiv & divisorZero;

    assign safeStart = ~divisorZero & startSDiv;

    assign endd = dividend[size-1] & SignedUnsignedbar;

    assign endr = divisor[size-1] & SignedUnsignedbar;

    assign enQ = (dividend[size-1] ^ divisor[size-1]) & SignedUnsignedbar;

    assign enR = dividend[size-1] & SignedUnsignedbar;

    aftab_TCL #(size) TCLdividend(
        .enable(endd),
        .In(dividend),
        .Out(ddIn)
    );

    aftab_TCL #(size) TCLdivisor(
        .enable(endr),
        .In(divisor),
        .Out(drIn)
    );

    aftab_divider #(size) unsignedDiv(
        .clk(clk),
        .rst(rst),
        .startDiv(safeStart),
        .doneDiv(doneSDiv),
        .dividend(ddIn),
        .divisor(drIn),
        .Q(Qp),
        .Remainder(Remp)
    );

    aftab_TCL #(size) TCLQ (
        .enable(enQ),
        .In(Qp),
        .Out(Qout)
    );

    aftab_TCL #(size) TCLRem (
        .enable(enR),
        .In(Remp[size-1:0]),
        .Out(Remout)
    );

endmodule