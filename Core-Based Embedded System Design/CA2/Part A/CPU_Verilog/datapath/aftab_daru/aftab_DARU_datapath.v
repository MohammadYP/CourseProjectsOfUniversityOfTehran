// **************************************************************************************
// Filename: aftab_DARU_datapath.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_DARU_datapath
// Description:
//
// Dependencies:
//
// File content description:
// DARU_dp for AFTAB DARU
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_DARU_datapath #(parameter size = 32) (
    input clk,
    input rst,
    input [size-1:0] addrIn,
    input [1:0] nBytes,
    input ldAddr,
    input incCnt,
    input iniCnt,
    input selLdEn,
    input enableAddr,
    input enableData,
    input ldNumBytes,
    input initReading,
    input zeroAddr,
    input zeroNumBytes,
    input zeroCnt,
    input dataInstbar,
    input checkMisalignedDARU,
    input [1:0] initValueCnt,
    input [(size/4)-1:0] memData,
    output coCnt,
    output instrMisalignedFlag,
    output loadMisalignedFlag,
    output [size-1:0] addrOut,
    output [size-1:0] dataOut
);

    wire [size-1:0] readAddr;
    wire [size-1:0] readAddrFinal;
    wire [1:0] readNBytes;
    wire [1:0] cntNumBytes;
    wire [3:0] memDataEn;

    wire [size/4-1:0] dataIn;
    assign dataIn = enableData ? memData : {(size/4){1'bz}};

    aftab_register #(32) addrReg(
        .in(addrIn),
        .out(readAddr),
        .ldR(ldAddr),
        .zero(zeroAddr),
        .clk(clk),
        .rst(rst)
    );

    aftab_register #(2) numBytesReg(
        .in(nBytes),
        .out(readNBytes),
        .ldR(ldNumBytes),
        .zero(zeroNumBytes),
        .clk(clk),
        .rst(rst)
    );

    aftab_decoder2to4 dcdr(
        .dataIn(cntNumBytes),
        .En(selLdEn),
        .dataOut(memDataEn)
    );

    aftab_counter #(2) cntrNumBytes(
        .dataOut(cntNumBytes),
        .initValue(initValueCnt),
        .incCnt(incCnt),
        .iniCnt(iniCnt),
        .zero(zeroCnt),
        .co(),
        .clk(clk),
        .rst(rst)
    );

    genvar i;
    generate
    for (i = 0; i < size/8 ; i=i+1) begin: Registers
        aftab_register #(size/4) memDataReg(
            .rst(rst),
            .clk(clk),
            .zero(initReading),
            .ldR(memDataEn[i]),
            .in(dataIn),
            .out(dataOut[8*i+7:8*i])
        );
    end
    endgenerate

    aftab_opt_adder #(size) Adder (
        .a(readAddr),
        .b(cntNumBytes),
        .sum(readAddrFinal)
    );

    aftab_DARU_errorDetector ERROR_UNIT(
        .nBytes(nBytes),
        .addrIn(addrIn[1:0]),
        .dataInstBar(dataInstbar),
        .checkMisalignedDARU(checkMisalignedDARU),
        .instrMisalignedFlag(instrMisalignedFlag),
        .loadMisalignedFlag(loadMisalignedFlag)
    );

    assign coCnt = (cntNumBytes == readNBytes) ? 1'b1 : 1'b0;
    assign addrOut = enableAddr ? readAddrFinal : {(size){1'bz}};

endmodule
