// **************************************************************************************
// Filename: aftab_oneBitReg.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_oneBitReg
// Description:
//
// Dependencies:
//
// File content description:
// aftab_oneBitReg for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_oneBitReg
(
	input clk,
	input rst,
	input zero,
	input load,
	input inReg,
	output reg outReg
);

	always @(posedge clk, posedge rst)
	begin
		if(rst == 1'b1)
			outReg <= 1'b0;
		else
		begin
			if(zero == 1'b1)
				outReg <= 1'b0;
			else if(load == 1'b1)
				outReg <= inReg;
		end
	end

endmodule
