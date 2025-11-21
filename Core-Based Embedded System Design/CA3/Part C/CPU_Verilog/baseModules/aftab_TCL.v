// **************************************************************************************
// Filename: aftab_TCL.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_TCL
// Description:
//
// Dependencies:
//
// File content description:
// TCL for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_TCL #(parameter size = 33)(
    input [size-1:0] In,
    output [size-1:0] Out,
    input enable
);

    assign Out = (enable == 1) ? (~{In} + 1) : In;

endmodule