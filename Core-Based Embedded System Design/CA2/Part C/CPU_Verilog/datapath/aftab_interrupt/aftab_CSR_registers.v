// **************************************************************************************
// Filename: aftab_CSR_registers.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_CSR_registers
// Description:
//
// Dependencies:
//
// File content description:
// aftab_CSR_registers for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_CSR_registers #(parameter len = 32)
(
	input clk,
    input rst,
    input writeRegBank,
    input [4:0] addressRegBank,
    input [len-1 : 0] inputRegBank,
    output reg [len-1 : 0] outRegBank,
    output MSTATUS_INT_MODE
);

    (* ramstyle = "M9K" *) reg [31:0] rData [0:31];

    integer i;

    always@(posedge clk, posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1)
            rData[i] <= 32'b0;
    end
    else begin
        if(writeRegBank) begin
            rData[addressRegBank] <= inputRegBank;
        end
            outRegBank <= rData[addressRegBank];
    end
    end

    assign MSTATUS_INT_MODE = rData[16][7];

endmodule
