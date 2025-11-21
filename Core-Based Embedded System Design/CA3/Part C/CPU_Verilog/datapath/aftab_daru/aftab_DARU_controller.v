// **************************************************************************************
// Filename: aftab_DARU_controller.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_DARU_controller
// Description:
//
// Dependencies:
//
// File content description:
// DARU_cu for AFTAB DARU
//
// **************************************************************************************
`timescale 1ns/1ns

`define waitforStart 2'b00
`define waitforMemready 2'b01
`define complete 2'b10

module aftab_DARU_controller(
    input clk,
    input rst,
    input startDARU,
    input coCnt,
    input memReady,
    output reg iniCnt,
    output reg ldAddr,
    output reg zeroAddr,
    output reg zeroNumBytes,
    output reg initReading,
    output reg ldNumBytes,
    output reg selLdEn,
    output reg readMem,
    output reg enableAddr,
    output reg enableData,
    output reg incCnt,
    output reg zeroCnt,
    output reg completeDARU
);

    reg [1:0] ns, ps;
    reg ldS, zeroS;
    wire loadSUB;

    always @(posedge clk, posedge rst) begin
        if(rst)
            ps <= `waitforStart;
        else
            ps <= ns;
    end

    always @(ps, startDARU, coCnt, memReady) begin
        case (ps)
            `waitforStart: ns = (startDARU) ? `waitforMemready : `waitforStart;
            `waitforMemready: ns = (memReady & coCnt) ? `complete : `waitforMemready;
            `complete: ns = `waitforStart;
            default: ns = `waitforStart;
        endcase
    end

    always @(ps, startDARU, coCnt, memReady) begin
        {iniCnt, ldAddr, zeroCnt, zeroAddr, zeroNumBytes, ldNumBytes, selLdEn,
        readMem, enableAddr, enableData, incCnt, completeDARU, initReading} = 13'b0;
        case (ps)
            `waitforStart: {iniCnt, ldAddr, ldNumBytes, initReading} = {startDARU, startDARU, startDARU, startDARU};
            `waitforMemready: {selLdEn, enableData, readMem, enableAddr, incCnt} = {memReady, memReady, 1'b1, 1'b1, memReady};
            `complete: {completeDARU} = 1'b1;
        endcase
    end

endmodule

