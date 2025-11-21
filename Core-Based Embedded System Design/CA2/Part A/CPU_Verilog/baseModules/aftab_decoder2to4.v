// **************************************************************************************
// Filename: aftab_decoder2to4.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_decoder2to4
// Description:
//
// Dependencies:
//
// File content description:
// decoder for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_decoder2to4 (
    input [1:0] dataIn,
    input En,
    output [3:0] dataOut
);

    wire [3:0] dcdData;
    assign dcdData = (dataIn == 2'd0) ? 4'b0001 :
                     (dataIn == 2'd1) ? 4'b0010 :
                     (dataIn == 2'd2) ? 4'b0100 :
                     (dataIn == 2'd3) ? 4'b1000 : 4'b0000;
    assign dataOut = (En == 1'b1) ? dcdData : 4'b0000;

endmodule