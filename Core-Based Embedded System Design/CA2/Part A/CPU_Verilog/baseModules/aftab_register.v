// **************************************************************************************
// Filename: aftab_register.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_register
// Description:
//
// Dependencies:
//
// File content description:
// register for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_register #( parameter size = 4) (
    input [size-1:0] in,
    input ldR,
    input clk,
    input zero,
    input rst,
    output [size-1:0] out
);

    reg [size-1:0] Rreg;
    assign out = Rreg;

    always @ (posedge clk, posedge rst) begin: RREG
        if(rst)
            Rreg = {(size){1'b0}};
        else if(zero)
            Rreg = {(size){1'b0}};
        else if(ldR)
            Rreg = in;
    end

endmodule
