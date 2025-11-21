// **************************************************************************************
// Filename: aftab_mux2to1_2sel.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_mux2to1_2sel
// Description:
//
// Dependencies:
//
// File content description:
// mux2to1 for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_mux2to1_2sel #(parameter size = 32) (
    input [size-1:0] i0,
    input [size-1:0] i1,
    input s0,
    input s1,
    output [size-1:0] w
);

    assign w = (s0 == 1'b1) ? i0 :
               (s1 == 1'b1) ? i1 :
               {(size){1'b0}};

endmodule
