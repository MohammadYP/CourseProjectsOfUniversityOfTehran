// **************************************************************************************
// Filename: aftab_DAWU_TB.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_DAWU_TB
// Description:
//
// Dependencies:
//
// File content description:
// DAWU_TB for AFTAB DAWU testing
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_DAWU_TB();
    reg clk = 1;
    reg rst = 0;
    reg startDAWU, memReady;
    reg checkMisalignedDAWU = 0;
    reg [31:0]addrIn, dataIn;
    reg [1:0]nBytes;

    wire completeDAWU, writeMem;
    wire [7:0]dataOut;
    wire [31:0] addrOut;
    wire storeMisalignedFlag;

    DAWU #(32)MUT(addrIn, dataIn, nBytes, startDAWU, memReady, clk, rst,
    checkMisalignedDAWU, addrOut, dataOut, storeMisalignedFlag,
    completeDAWU, writeMem);

    initial repeat (500)
        #10 clk = ~clk;

    initial begin
        rst=1;
        startDAWU = 0;
        addrIn = 32'b00000011_00000000_11111111_01010101;
        dataIn = 32'b10101010_00000000_11111111_00001111;
        nBytes = 2'd3;
        #40;
        rst=0;
        #185
        startDAWU = 1;
        #15
        memReady=0;
        #100
        startDAWU = 0;
        #100;
        memReady=1;
        #20
        memReady=0;
        #60
        memReady = 1;
        #20;
        memReady = 0;
        #60
        memReady = 1;
        #20
        memReady = 0;
        #60 memReady = 1;
        #20;
        memReady = 0;
        #60;
        #100;
    end

endmodule