// **************************************************************************************
// Filename: aftab_DARU.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_MEM_DARU
// Description:
//
// Dependencies:
//
// File content description:
// DARU for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_MEM_DARU #(parameter size = 32) (
    input clk,
    input rst,
    input startDARU,
    input memReady,
    input dataInstrBar,
    input checkMisalignedDARU,
    input [size-1:0] addrIn,
    input [size/4-1:0] memData,
    input [1:0] nBytes,

    output completeDARU,
    output readMem,
    output instrMisalignedFlag,
    output loadMisalignedFlag,
    output [size-1:0] dataOut,
    output [size-1:0] addrOut
);

    wire ldAddr;
    wire ldNumBytes;
    wire incCnt;
    wire iniCnt;
    wire selLdEn;
    wire enableAddr;
    wire enableData;
    wire coCnt;
    wire initReading;
    wire zeroCnt;
    wire zeroAddr;
    wire zeroNumBytes;
    wire [1:0] readNBytes;

    aftab_DARU_datapath #(size) DP (
        .clk(clk),
        .rst(rst),
        .addrIn(addrIn),
        .memData(memData),
        .nBytes(nBytes),
        .ldAddr(ldAddr),
        .ldNumBytes(ldNumBytes),
        .incCnt(incCnt),
        .iniCnt(iniCnt),
        .selLdEn(selLdEn),
        .enableAddr(enableAddr),
        .enableData(enableData),
        .coCnt(coCnt),
        .dataOut(dataOut),
        .addrOut(addrOut),
        .initReading(initReading),
        .zeroAddr(zeroAddr),
        .zeroNumBytes(zeroNumBytes),
        .zeroCnt(zeroCnt),
        .dataInstbar(dataInstrBar),
        .checkMisalignedDARU(checkMisalignedDARU),
        .instrMisalignedFlag(instrMisalignedFlag),
        .loadMisalignedFlag(loadMisalignedFlag),
        .initValueCnt(2'b00)
    );

    aftab_DARU_controller CU (
        .clk(clk),
        .rst(rst),
        .startDARU(startDARU),
        .memReady(memReady),
        .coCnt(coCnt),
        .iniCnt(iniCnt),
        .incCnt(incCnt),
        .ldNumBytes(ldNumBytes),
        .ldAddr(ldAddr),
        .readMem(readMem),
        .completeDARU(completeDARU),
        .enableAddr(enableAddr),
        .enableData(enableData),
        .selLdEn(selLdEn),
        .initReading(initReading),
        .zeroAddr(zeroAddr),
        .zeroCnt(zeroCnt),
        .zeroNumBytes(zeroNumBytes)
    );

endmodule