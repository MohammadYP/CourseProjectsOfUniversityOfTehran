// **************************************************************************************
// Filename: aftab_DAWU.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_MEM_DAWU
// Description:
//
// Dependencies:
//
// File content description:
// DAWU for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_MEM_DAWU #(parameter size = 32) (
    input [size-1:0] addrIn,
    input [size-1:0] dataIn,
    input [1:0] nBytes,
    input startDAWU,
    input memReady,
    input clk,
    input rst,
    input checkMisalignedDAWU,
    output [size-1:0] addrOut,
    output [size/4-1:0] dataOut,
    output storeMisalignedFlag,
    output completeDAWU,
    output writeMem
);

    wire coCnt;
    wire LdAddr;
    wire zeroAddr;
    wire ldNumBytes;
    wire zeroNumBytes;
    wire incCnt;
    wire iniCnt;
    wire LdData;
    wire enableAddr;
    wire enableData;
    wire zeroData;
    wire zeroCnt;

    aftab_DAWU_datapath #(size) DP(
        .addrIn(addrIn),
        .dataIn(dataIn),
        .nBytes(nBytes),
        .LdAddr(LdAddr),
        .LdNumBytes(ldNumBytes),
        .incCnt(incCnt),
        .iniCnt(iniCnt),
        .LdData(LdData),
        .enableAddr(enableAddr),
        .enableData(enableData),
        .clk(clk),
        .rst(rst),
        .addrOut(addrOut),
        .dataOut(dataOut),
        .coCnt(coCnt),
        .zeroCnt(zeroCnt),
        .zeroNumBytes(zeroNumBytes),
        .zeroAddr(zeroAddr),
        .zeroData(zeroData),
        .initValueCnt(2'b00),
        .checkMisalignedDAWU(checkMisalignedDAWU),
        .storeMisalignedFlag(storeMisalignedFlag)
    );

    aftab_DAWU_controller CU (
        .startDAWU(startDAWU),
        .memRdy(memReady),
        .coCnt(coCnt),
        .clk(clk),
        .rst(rst),
        .iniCnt(iniCnt),
        .LdAddr(LdAddr),
        .LdNumBytes(ldNumBytes),
        .LdData(LdData),
        .enableData(enableData),
        .enableAddr(enableAddr),
        .writeMem(writeMem),
        .incCnt(incCnt),
        .completeDAWU(completeDAWU),
        .zeroCnt(zeroCnt),
        .zeroNumBytes(zeroNumBytes),
        .zeroAddr(zeroAddr),
        .zeroData(zeroData)
    );

endmodule