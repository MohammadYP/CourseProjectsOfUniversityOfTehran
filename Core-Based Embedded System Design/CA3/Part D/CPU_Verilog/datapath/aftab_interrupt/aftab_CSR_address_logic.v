// **************************************************************************************
// Filename: aftab_CSR_address_logic.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_CSR_address_logic
// Description:
//
// Dependencies:
//
// File content description:
// aftab_CSR_address_logic for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_CSR_address_logic (
	input [11:0] addressRegBank,
  	output ldMieReg,
  	output ldMieUieField,
  	output mirrorUstatus,
  	output mirrorUie,
  	output mirrorUip,
  	output mirror
);

  	wire mirrorUstatusTemp, mirrorUieTemp, mirrorUipTemp;

	assign ldMieReg = addressRegBank == 12'h304 ? 1'b1 : 1'b0;
	assign ldMieUieField = addressRegBank == 12'h300 ? 1'b1 : 1'b0;
	assign mirrorUstatusTemp = addressRegBank[7:0] == 8'h00 ? 1'b1 : 1'b0;
	assign mirrorUieTemp = addressRegBank[7:0] == 8'h04 ? 1'b1 : 1'b0;
	assign mirrorUipTemp = addressRegBank[7:0] == 8'h44 ? 1'b1 : 1'b0;
	assign mirrorUstatus = mirrorUstatusTemp;
	assign mirrorUie = mirrorUieTemp;
	assign mirrorUip = mirrorUipTemp;
	assign mirror = (mirrorUstatusTemp | mirrorUieTemp) | mirrorUipTemp;

endmodule
