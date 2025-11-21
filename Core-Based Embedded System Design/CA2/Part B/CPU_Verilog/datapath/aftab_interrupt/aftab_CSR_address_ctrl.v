// **************************************************************************************
// Filename: aftab_CSR_address_ctrl.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_CSR_address_ctrl
// Description:
//
// Dependencies:
//
// File content description:
// This combinatorial unit checks if an intsruction attempts to access a non-existing CSR register
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_CSR_address_ctrl (
    input [11:0] addressRegBank,
    output validAddressCSR
);

  	assign validAddressCSR =   addressRegBank == 12'h300 ? 1'b1 :
                                addressRegBank == 12'h344 ? 1'b1 :
                                addressRegBank == 12'h304 ? 1'b1 :
                                addressRegBank == 12'h305 ? 1'b1 :
                                addressRegBank == 12'h341 ? 1'b1 :
                                addressRegBank == 12'h342 ? 1'b1 :
                                addressRegBank == 12'h343 ? 1'b1 :
                                addressRegBank == 12'h303 ? 1'b1 :
                                addressRegBank == 12'h302 ? 1'b1 :
                                addressRegBank == 12'h000 ? 1'b1 :
                                addressRegBank == 12'h044 ? 1'b1 :
                                addressRegBank == 12'h004 ? 1'b1 :
                                addressRegBank == 12'h005 ? 1'b1 :
                                addressRegBank == 12'h041 ? 1'b1 :
                                addressRegBank == 12'h042 ? 1'b1 :
                                addressRegBank == 12'h043 ? 1'b1 :
                                // addressRegBank == 12'h001 ? 1'b1 : for floating point
                                // addressRegBank == 12'h002 ? 1'b1 :
                                // addressRegBank == 12'h003 ? 1'b1 :
                                1'b0;

endmodule
