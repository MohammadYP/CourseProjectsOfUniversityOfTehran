// **************************************************************************************
// Filename: aftab_BSU_TB.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_BSU_TB
// Description:
//
// Dependencies:
//
// File content description:
// BSUTB for AFTAB BSU testing
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_BSU_TB();

    reg [31:0] dataIn;
    reg [4:0] shiftAmount;
    reg [1:0] selShift;
    wire [31:0] dataOut;

    aftab_BSU test(dataIn, shiftAmount, selShift, dataOut);

    initial begin
        dataIn = 32'b10000000_11111111_00000000_10101010;
        shiftAmount = 5'd3;
        selShift = 2'b10;
        #10;
        selShift = 2'b11;
        #10;
        selShift = 2'b00;
        #10;
        #50;
        dataIn = 32'd30;
        selShift = 2'b11;
        #10;
    end

endmodule