// **************************************************************************************
// Filename: aftab_sulu.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_sulu
// Description:
//
// Dependencies:
//
// File content description:
// sulu for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_sulu #(parameter size = 32) (
    input loadByteSigned,
    input loadHalfSigned,
    input load,
    input [size-1:0] dataIn,
    output [size-1:0] dataOut
);

    assign dataOut = (loadByteSigned == 1'b1) ? {{24{dataIn[7]}}, dataIn[7:0]} :
                     (loadHalfSigned == 1'b1) ? {{16{dataIn[15]}}, dataIn[15:0]} :
                     (load == 1'b1) ? dataIn :
                     {(size){1'b0}};

endmodule