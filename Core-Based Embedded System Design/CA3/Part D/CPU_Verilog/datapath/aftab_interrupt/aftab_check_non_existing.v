// **************************************************************************************
// Filename: aftab_check_non_existing.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_check_non_existing
// Description:
//
// Dependencies:
//
// File content description:
// aftab_check_non_existing for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_check_non_existing (
	input [11:0] CSR_AddrIn,
    output nonExistingCSR
);

	assign nonExistingCSR = (
				CSR_AddrIn == 12'h300 || CSR_AddrIn == 12'h302 ||
				CSR_AddrIn == 12'h303 || CSR_AddrIn == 12'h304 ||
				CSR_AddrIn == 12'h305 || CSR_AddrIn == 12'h341 ||
				CSR_AddrIn == 12'h342 || CSR_AddrIn == 12'h343 ||
				CSR_AddrIn == 12'h344 || CSR_AddrIn == 12'h000 ||
				CSR_AddrIn == 12'h004 || CSR_AddrIn == 12'h005 ||
				CSR_AddrIn == 12'h041 || CSR_AddrIn == 12'h042 ||
				CSR_AddrIn == 12'h043 || CSR_AddrIn == 12'h044 ||
				CSR_AddrIn == 12'h001 || CSR_AddrIn == 12'h002 ||
				CSR_AddrIn == 12'h003 
				) ? 1'b0 : 1'b1;

endmodule