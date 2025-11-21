// **************************************************************************************
// Filename: aftab_BSU.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_BSU
// Description:
//
// Dependencies:
//
// File content description:
// BSU for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_BSU #(parameter size = 32) (
    input [size-1:0] dataIn,
    input [4:0] shiftAmount,
    input [1:0] selShift,
    output reg [size-1:0] dataOut
);

    wire [size-1:0] decoderOut, d;

    decoder#(size) DCD(shiftAmount, decoderOut);

    assign d = (decoderOut & {(size){dataIn[31]}});

    always @(dataIn, shiftAmount, selShift) begin
    if(selShift == 2'b00)
        dataOut = (dataIn << shiftAmount);
    else if(selShift == 2'b10)
        dataOut = (dataIn >> shiftAmount);
    else if(selShift == 2'b11)
        dataOut = (dataIn >> shiftAmount) | d;
    else
        dataOut =  {(size){1'b0}};
    end

endmodule

module decoder #(parameter size = 32) (
    input [4:0] shiftAmount,
    output [size-1:0] outPut
);

    wire [size-1:0] a, b;
    assign a = ~(32'd0);
    assign b = (a >> shiftAmount);
    assign outPut = ~b;

endmodule