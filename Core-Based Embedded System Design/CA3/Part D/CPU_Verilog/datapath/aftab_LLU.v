// **************************************************************************************
// Filename: aftab_LLU.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_LLU
// Description:
//
// Dependencies:
//
// File content description:
// LLU for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_LLU #(parameter size = 32) (
    input [size-1:0] a,
    input [size-1:0] b,
    input [1:0] selLogic,
    output [size-1:0] lluResult
);

    assign lluResult = (selLogic == 2'b00) ? a^b :
                       (selLogic == 2'b10) ? a|b :
                       (selLogic == 2'b11) ? a&b :
                       {(size){1'b0}};

endmodule
