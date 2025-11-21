// **************************************************************************************
// Filename: aftab_CSRISL.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_CSRISL
// Description:
//
// Dependencies:
//
// File content description:
// aftab_CSRISL for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_CSRISL #(parameter len = 32) (
	input selP1,
	input selIm,
	input selReadWrite,
	input clr,
	input set,
	input selPC,
	input selmip,
	input selCause,
	input selTval,
	input machineStatusAlterationPreCSR,
	input userStatusAlterationPreCSR,
	input machineStatusAlterationPostCSR,
	input userStatusAlterationPostCSR,
	input mirrorUstatus,
	input mirrorUie,
	input mirrorUip,
	input mirrorUser,
	input [1:0] curPRV,
	input [4:0] ir19_15,
	input [len-1 : 0] CCmip,
	input [len-1 : 0] causeCode,
	input [len-1 : 0] trapValue,
	input [len-1 : 0] P1,
	input [len-1 : 0] PC,
	input [len-1 : 0] outCSR,
	output [1:0] previousPRV,
	output [len-1 : 0] inCSR
);

	wire [len-1 : 0] orRes;
	wire [len-1 : 0] andRes;
	wire [len-1 : 0] regOrImm;
	wire [len-1 : 0] preInCSR;

	assign regOrImm = (selP1) ? (P1) :
		(selIm) ? ({27'b0, ir19_15}) :
		(1'b0);

	assign orRes = outCSR | regOrImm;

	assign andRes = outCSR & (~regOrImm);

	assign preInCSR = (selReadWrite) ? (regOrImm) :
                      (set) ? (orRes) :
                      (clr) ? (andRes) :
                      (selmip) ? (CCmip) :
                      (selCause) ? (causeCode) :
                      (selTval) ? (trapValue) :
                      (selPC) ? (PC) :
                      (machineStatusAlterationPreCSR) ? ({outCSR[31:13], curPRV, outCSR[10:8], outCSR[3], outCSR[6:4], 1'b0, outCSR[2:0]}) :
                      (userStatusAlterationPreCSR) ? ({outCSR[31:5], outCSR[0], outCSR[3:1], 1'b0}) :
                      (machineStatusAlterationPostCSR) ? ({outCSR[31:8], 1'b0, outCSR[6:4], 1'b1, outCSR[2:0]}) :
                      (userStatusAlterationPostCSR) ? ({outCSR[31:5], 1'b0, outCSR[3:1], 1'b1}) :
                      (32'b0);

	assign inCSR = (mirrorUser && mirrorUstatus) ? (preInCSR & 32'h00000011) :
	               (mirrorUser && (mirrorUie || mirrorUip)) ? (preInCSR & 32'h00000111) :
	               (preInCSR);

	assign previousPRV = outCSR[12:11];

endmodule
