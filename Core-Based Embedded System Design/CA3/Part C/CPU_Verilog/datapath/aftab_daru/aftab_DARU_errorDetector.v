// **************************************************************************************
// Filename: aftab_DARU_errorDetector.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_DARU_errorDetector
// Description:
//
// Dependencies:
//
// File content description:
// DARU_dp for AFTAB DARU
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_DARU_errorDetector #(parameter size = 32)(
    input [1:0] nBytes,
    input [1:0] addrIn,
    input dataInstBar,
    input checkMisalignedDARU,
    output instrMisalignedFlag,
    output loadMisalignedFlag
);

    wire dataReadingError;
    wire instReadingError;
    wire misalignedErrorP;
    wire cmp_01;
    wire cmp_10;
    wire cmp_11;
    wire [2:0] inReg;
    wire [2:0] outReg;

    assign cmp_01 = (addrIn == 2'b01) ? 1'b1 : 1'b0;
    assign cmp_10 = (addrIn == 2'b10) ? 1'b1 : 1'b0;
    assign cmp_11 = (addrIn == 2'b11) ? 1'b1 : 1'b0;

    assign misalignedErrorP = (nBytes == 2'b01) ? (cmp_01 | cmp_11) :
                              (nBytes == 2'b11) ? (cmp_01 | cmp_10 | cmp_11) : 1'b0;
    assign loadMisalignedFlag = (dataInstBar == 1'b1) ? (misalignedErrorP & checkMisalignedDARU) : 1'b0;
	assign instrMisalignedFlag = (dataInstBar == 1'b0) ? (misalignedErrorP & checkMisalignedDARU) : 1'b0;
endmodule