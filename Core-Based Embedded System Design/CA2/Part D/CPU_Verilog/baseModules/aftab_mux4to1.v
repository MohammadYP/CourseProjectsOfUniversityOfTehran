// **************************************************************************************
// Filename: aftab_mux4to1.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_mux4to1
// Description:
//
// Dependencies:
//
// File content description:
// mux4to1 for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_mux4to1 #(parameter size = 32) (
    input [size-1:0] i0,
    input [size-1:0] i1,
    input [size-1:0] i2,
    input [size-1:0] i3,
    input [1:0] sel,
    output [size-1:0] dataOut
);

    assign dataOut = (sel == 2'd3) ? i3 :
                     (sel == 2'd2) ? i2 :
                     (sel == 2'd1) ? i1 : i0;

endmodule