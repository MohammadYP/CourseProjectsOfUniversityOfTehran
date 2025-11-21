// **************************************************************************************
// Filename: aftab_register_bank.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_register_bank
// Description:
//
// Dependencies:
//
// File content description:
// aftab_register_bank for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_register_bank #(parameter len = 32)
(
	input clk,
	input rst,
	input writeRegBank,
	input [11:0] addressRegBank,
	input [len-1 : 0] inputRegBank,
	input loadMieReg,
	input loadMieUieField,
	output [len-1 : 0] outRegBank,
	output mirrorUstatus,
	output mirrorUie,
	output mirrorUip,
	output mirror,
	output ldMieReg,
	output ldMieUieField,
	output outMieFieldCCreg,
	output outUieFieldCCreg,
	output [len-1 : 0] outMieCCreg,
	output MSTATUS_INT_MODE
);

	wire [4:0] translatedAddress;

	aftab_CSR_registers #(.len(32)) CSR_registers (
		.clk(clk),
		.rst(rst),
		.writeRegBank(writeRegBank),
		.addressRegBank(translatedAddress),
		.inputRegBank(inputRegBank),
		.outRegBank(outRegBank),
		.MSTATUS_INT_MODE(MSTATUS_INT_MODE)
	);

	assign translatedAddress = {addressRegBank[8], addressRegBank[6], addressRegBank[2:0]};

	// aftab_check_non_existing check_non_existing_CSR (
	// 	.CSR_AddrIn(addressRegBank),
	// 	.nonExistingCSR(nonExistingCSR)
	// );

	aftab_CSR_address_logic CSR_address_logic (
		.addressRegBank(addressRegBank),
		.ldMieReg(ldMieReg),
		.ldMieUieField(ldMieUieField),
		.mirrorUstatus(mirrorUstatus),
		.mirrorUie(mirrorUie),
		.mirrorUip(mirrorUip),
		.mirror(mirror)
	);

	aftab_register #(.size(32)) mieCCregister (
		.clk(clk),
		.rst(rst),
		.zero(1'b0),
		.ldR(loadMieReg),
		.in(inputRegBank),
		.out(outMieCCreg)
	);

	aftab_oneBitReg mieFieldCCregister (
		.clk(clk),
		.rst(rst),
		.zero(1'b0),
		.load(loadMieUieField),
		.inReg(inputRegBank[3]),
		.outReg(outMieFieldCCreg)
	);

	aftab_oneBitReg uieFieldCCregister (
		.clk(clk),
		.rst(rst),
		.zero(1'b0),
		.load(loadMieUieField),
		.inReg(inputRegBank[0]),
		.outReg(outUieFieldCCreg)
	);
endmodule
