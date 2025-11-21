// **************************************************************************************
// Filename: aftab_DARU_TB.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_DARU_TB
// Description:
//
// Dependencies:
//
// File content description:
// DARU_TB for AFTAB DARU testing
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_DARU_TB();
    reg clk = 1;
    reg rst = 0;
    reg startDARU, memReady;
    reg dataInstrBar = 1;
    reg checkMisalignedDARU = 0;
    reg [31:0] addrIn;
    reg [7:0] memData;
    reg [1:0] nBytes;

    wire completeDARU, readMem;
    wire [31:0] dataOut, addrOut;
    wire instrMisalignedFlag;
    wire loadMisalignedFlag;

    aftab_DARU MUT(clk, rst, startDARU, nBytes, addrIn, memData, memReady, dataInstrBar,
    checkMisalignedDARU, instrMisalignedFlag, loadMisalignedFlag, completeDARU,
    dataOut, addrOut, readMem);

    initial repeat (500)
        #10 clk = ~clk;
    initial begin
        rst=1;
        startDARU = 0;
        #30;
        rst=0;
        #20
        dataInstrBar = 1;
        startDARU = 1;
        #10
        memReady=0;
        addrIn = 32'd100;
        nBytes = 2'd3;
        #100
        startDARU = 0;
        memData = 8'b10010011;
        memReady=1;
        #20
        memReady=0;
        #60
        memReady = 1;
        memData = 8'b00000000;
        #20;
        memReady = 0;
        #60
        memReady = 1;
        memData = 8'b01000000;
        #20
        memReady = 0;
        #60 memReady = 1;
        memData = 8'b00000001;
        #20;
        memReady = 0;
        #60;
        nBytes = 2'd0;
        memReady = 0;
        checkMisalignedDARU = 1;
        #100;
        nBytes = 2'd1;
        #100;
    end

endmodule