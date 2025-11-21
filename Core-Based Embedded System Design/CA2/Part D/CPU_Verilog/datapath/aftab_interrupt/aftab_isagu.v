// **************************************************************************************
// Filename: aftab_isagu.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_isagu
// Description:
//
// Dependencies:
//
// File content description:
// aftab_isagu for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_isagu #(parameter len = 32)
(
	input [len-1 : 0] tvecBase,
	input [5:0] causeCode,
	output [1:0] modeTvec,
	output [len-1 : 0] interruptStartAddressDirect,
	output [len-1 : 0] interruptStartAddressVectored
);

	assign modeTvec = tvecBase[1:0];
	assign interruptStartAddressDirect = tvecBase;
	assign interruptStartAddressVectored = {2'b00, (tvecBase[len-1 : 2] + {causeCode, 2'b00})};

endmodule
