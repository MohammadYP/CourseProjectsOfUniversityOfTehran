// **************************************************************************************
// Filename: aftab_comparator.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_comparator
// Description:
//
// Dependencies:
//
// File content description:
// comparator for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_comparator #(parameter size = 32) (
    input [size-1:0] a,
    input [size-1:0] b,
    input comparedSignedUnsignedBar,
    output lt,
    output eq,
    output gt
);

    // wire [size-1:0] sub;

    // assign sub = (a-b);
    // assign lt = (comparedSignedUnsignedBar == 1'b1 && a != b) ? sub[size-1] : a < b;
    // assign eq = (a == b) ;
    // assign gt = (comparedSignedUnsignedBar == 1'b1 && a != b) ? ~sub[size-1] : a > b;

    wire l1, l2, l3;
    wire e1, e2, e3;
    wire g1, g2, g3;

    wire [size-1:0] aa;
    wire [size-1:0] bb;

    assign aa = (comparedSignedUnsignedBar) ? {~a[size-1], a[size-2:0]} : a;
    assign bb = (comparedSignedUnsignedBar) ? {~b[size-1], b[size-2:0]} : b;

    assign l1 = (aa[7:0] < bb[7:0]);
    assign g1 = (aa[7:0] > bb[7:0]);
    assign e1 = (aa[7:0] == bb[7:0]);

    assign l2 = (aa[15:8] < bb[15:8]) | (aa[15:8] == bb[15:8])&l1;
    assign g2 = (aa[15:8] > bb[15:8]) | (aa[15:8] == bb[15:8])&g1;
    assign e2 = (aa[15:8] == bb[15:8])&e1;

    assign l3 = (aa[23:16] < bb[23:16]) | (aa[23:16] == bb[23:16])&l2;
    assign g3 = (aa[23:16] > bb[23:16]) | (aa[23:16] == bb[23:16])&g2;
    assign e3 = (aa[23:16] == bb[23:16])&e2;

    assign lt = (aa[31:24] < bb[31:24]) | (aa[31:24] == bb[31:24])&l3;
    assign gt = (aa[31:24] > bb[31:24]) | (aa[31:24] == bb[31:24])&g3;
    assign eq = (aa[31:24] == bb[31:24])&e3;

endmodule