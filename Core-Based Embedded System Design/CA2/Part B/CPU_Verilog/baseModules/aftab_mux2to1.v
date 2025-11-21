// **************************************************************************************
// Filename: aftab_mux2to1.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_mux2to1
// Description:
//
// Dependencies:
//
// File content description:
// mux2to1 for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_mux2to1 #(parameter size = 33)(
    input [size-1:0] i0,
    input [size-1:0] i1,
    input sel,
    output [size-1:0] result
);

    assign result = (sel == 1'b0) ? i0 :
                    (sel == 1'b1) ? i1 : 32'b0;

endmodule
