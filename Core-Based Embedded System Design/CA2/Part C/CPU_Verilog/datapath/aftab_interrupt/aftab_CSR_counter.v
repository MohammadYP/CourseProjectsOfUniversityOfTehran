// **************************************************************************************
// Filename: aftab_CSR_counter.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_CSR_counter
// Description:
//
// Dependencies:
//
// File content description:
// aftab_CSR_counter for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_CSR_counter #(parameter len = 3) (
	input clk,
    input rst,
    input dnCnt,
    input upCnt,
    input ldCnt,
    input zeroCnt,
    input [len-1 : 0] ldValue,
    output [len-1 : 0] outCnt
);

    reg [len-1 : 0] temp;

    wire coCntup;
    wire coCntdn;

    assign coCntup = (temp == {(len){1'b1}}) ? (1'b1) : (1'b0);
    assign coCntdn = (temp == {(len){1'b0}}) ? (1'b1) : (1'b0);
    assign outCnt = temp;

    always@(posedge clk, posedge rst) begin
        if (rst)
            temp <= {(len){1'b0}};
        else if (zeroCnt)
            temp <= {(len){1'b0}};
        else if (ldCnt)
            temp <= ldValue;
        else if (upCnt && (~coCntup))
            temp <= temp + 1;
        else if (dnCnt && (~coCntdn))
            temp <= temp - 1;
    end

endmodule
