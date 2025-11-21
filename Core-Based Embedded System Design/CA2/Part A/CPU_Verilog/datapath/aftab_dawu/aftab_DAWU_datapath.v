// **************************************************************************************
// Filename: aftab_DAWU_datapath.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_DAWU_datapath
// Description:
//
// Dependencies:
//
// File content description:
// DAWU_dp for AFTAB DAWU
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_DAWU_datapath #(parameter size = 32)(
    input [size-1:0] addrIn,
    input [size-1:0] dataIn,
    input [1:0] nBytes,
    input [1:0] initValueCnt,
    input LdAddr,
    input LdNumBytes,
    input incCnt,
    input iniCnt,
    input LdData,
    input enableAddr,
    input enableData,
    input clk,
    input rst,
    input zeroCnt,
    input zeroNumBytes,
    input zeroAddr,
    input zeroData,
    input checkMisalignedDAWU,
    output [size-1:0] addrOut,
    output [size/4-1:0] dataOut,
    output coCnt,
    output storeMisalignedFlag
);


    wire [size-1:0] addrRegOut;
    wire [size/4-1:0] dataReg0Out, dataReg1Out, dataReg2Out, dataReg3Out, MuxOut;
    wire [1:0] nBytesRegOut, byteCntOut, orOut;

    aftab_register #(32) DAWUaddrReg(
        .in(addrIn),
        .out(addrRegOut),
        .ldR(LdAddr),
        .zero(zeroAddr),
        .clk(clk),
        .rst(rst)
    );

    aftab_register #(8) DAWUdataReg0(
        .in(dataIn[7:0]),
        .out(dataReg0Out),
        .ldR(LdData),
        .zero(zeroData),
        .clk(clk),
        .rst(rst)
    );

    aftab_register #(8) DAWUdataReg1(
        .in(dataIn[15:8]),
        .out(dataReg1Out),
        .ldR(LdData),
        .zero(zeroData),
        .clk(clk),
        .rst(rst)
    );

    aftab_register #(8) DAWUdataReg2(
        .in(dataIn[23:16]),
        .out(dataReg2Out),
        .ldR(LdData),
        .zero(zeroData),
        .clk(clk),
        .rst(rst)
    );

    aftab_register #(8) DAWUdataReg3(
        .in(dataIn[31:24]),
        .out(dataReg3Out),
        .ldR(LdData),
        .zero(zeroData),
        .clk(clk),
        .rst(rst)
    );

    aftab_register #(2) DAWUnumBytesReg(
        .in(nBytes),
        .out(nBytesRegOut),
        .ldR(LdNumBytes),
        .zero(zeroNumBytes),
        .clk(clk),
        .rst(rst)
    );

    aftab_counter #(2) DAWUcntrNumBytes(
        .dataOut(byteCntOut),
        .initValue(initValueCnt),
        .incCnt(incCnt),
        .iniCnt(iniCnt),
        .zero(zeroCnt),
        .co(),
        .clk(clk),
        .rst(rst)
    );

    aftab_mux4to1 #(size/4) DAWUmux(
        .i0(dataReg0Out),
        .i1(dataReg1Out),
        .i2(dataReg2Out),
        .i3(dataReg3Out),
        .sel(byteCntOut),
        .dataOut(MuxOut)
    );

    aftab_DAWU_errorDetector DAWU_ERROR_UNIT(
        .nBytes(nBytes),
        .addrIn(addrIn[1:0]),
        .checkMisalignedDAWU(checkMisalignedDAWU),
        .storeMisalignedFlag(storeMisalignedFlag)
    );

    wire [1:0] par_addr;
    wire par_co;

    assign coCnt = (nBytesRegOut == byteCntOut);

    assign {par_co, par_addr} = addrRegOut[1:0] + byteCntOut;

    assign orOut = (addrRegOut[1:0] | byteCntOut);

    assign addrOut = (enableAddr) ? {addrRegOut[size-1:2], par_addr} : 32'bz;

    assign dataOut = (enableData) ? MuxOut : 8'bz;

endmodule
