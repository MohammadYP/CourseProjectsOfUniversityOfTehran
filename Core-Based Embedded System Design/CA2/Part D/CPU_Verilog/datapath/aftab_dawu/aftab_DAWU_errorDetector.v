// **************************************************************************************
// Filename: aftab_DAWU_errorDetector.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_DAWU_errorDetector
// Description:
//
// Dependencies:
//
// File content description:
// DAWU_errorDetector for AFTAB DAWU
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_DAWU_errorDetector #(parameter size = 32) (
    input [1:0] nBytes,
    input [1:0] addrIn,
    input checkMisalignedDAWU,
    output storeMisalignedFlag
);

    wire cmp_01;
    wire cmp_10;
    wire cmp_11;

    assign cmp_01 = (addrIn == 2'b01) ? 1'b1 : 1'b0;
    assign cmp_10 = (addrIn == 2'b10) ? 1'b1 : 1'b0;
    assign cmp_11 = (addrIn == 2'b11) ? 1'b1 : 1'b0;

    assign storeMisalignedFlag = (nBytes == 2'B01) ? ((cmp_01 | cmp_11) & checkMisalignedDAWU) :
                                 (nBytes == 2'b11) ? ((cmp_01 | cmp_10 | cmp_11) & checkMisalignedDAWU) : 1'b0;
endmodule