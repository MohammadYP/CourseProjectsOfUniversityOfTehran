// **************************************************************************************
// Filename: aftab_CSR_addressing_decoder.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_CSR_addressing_decoder
// Description:
//
// Dependencies:
//
// File content description:
// aftab_CSR_addressing_decoder for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_CSR_addressing_decoder (
	input [2:0] cntOutput,
	output [11:0] outAddr
);

	assign outAddr[11:8] = 4'b0011;
	assign outAddr[7] = 1'b0;
	assign outAddr[6] = cntOutput == 3'b000 ? 1'b1 :
						cntOutput == 3'b001 ? 1'b1 :
						cntOutput == 3'b010 ? 1'b1 :
						cntOutput == 3'b111 ? 1'b1 :
						1'b0;
	assign outAddr[5:3] = 3'b000;
	assign outAddr[2:0] = cntOutput == 3'b001 ? 3'b010 : // mcause
                          cntOutput == 3'b100 ? 3'b000 : // mstatus
                          cntOutput == 3'b010 ? 3'b001 : // mepc
                          cntOutput == 3'b011 ? 3'b101 : // mtvec
                          cntOutput == 3'b101 ? 3'b000 :
                          cntOutput == 3'b110 ? 3'b000 :
                          cntOutput == 3'b111 ? 3'b011 : // mtval
                          3'b000;

endmodule
