// **************************************************************************************
// Filename: aftab_divider_controller.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_divider_controller
// Description:
//
// Dependencies:
//
// File content description:
// divider_CU for AFTAB AAU
//
// **************************************************************************************
`timescale 1ns/1ns

`define IDLE 2'b00
`define STEP1 2'b01
`define STEP2 2'b10

`define LOG2_CEIL(BITS) ((BITS <= 1) ? 0: (BITS <= 2) ? 1: (BITS <= 4) ? 2: (BITS <= 8) ? 3: (BITS <= 16) ? 4: (BITS <= 32) ? 5: (BITS <= 64) ? 6: (BITS <= 128)? 7:0)

module aftab_divider_controller #(parameter size = 33) (
    input clk,
    input rst,
    input startDiv,
    input signR,
    output reg doneDiv,
    output reg ldRegR,
    output reg zeroRegR,
    output reg seldividend,
    output reg selshQ,
    output reg ldRegQ,
    output reg zeroRegQ,
    output reg ldRegM,
    output reg zeroRegM,
    output reg shL_R,
    output reg shL_Q,
    output Q0
);

    reg [1:0] ps, ns;
    reg incCnt;
    reg initCnt;
    wire co;

    aftab_counter #(`LOG2_CEIL(size)+1) counter(
        .dataOut(),
        .initValue(6'b011110),
        .co(co),
        .zero(1'b0),
        .incCnt(incCnt),
        .iniCnt(initCnt),
        .clk(clk),
        .rst(rst)
    );

    assign Q0 = ~signR;

    always @(posedge clk, posedge rst) begin
        if(rst)
            ps <= `IDLE;
        else
            ps <= ns;
    end

    always @(ps, startDiv, co) begin
        case(ps)
            `IDLE: ns <= (startDiv) ? `STEP1 : `IDLE;
            `STEP1: begin
                if (co == 1'b1)
                    ns <= `IDLE;
                else
                    ns <= `STEP2;
            end
            `STEP2: ns <=`STEP1;
            default: ns <= `IDLE;
        endcase
    end

    always @(ps, startDiv, co) begin
        {ldRegR, zeroRegR, seldividend, selshQ, ldRegQ, zeroRegQ, zeroRegM, ldRegM, doneDiv, incCnt, initCnt, shL_R, shL_Q} = 13'd0;
        case(ps)
            `IDLE: begin
                {initCnt, zeroRegR, ldRegQ, ldRegM, seldividend} = 5'b11111;
            end
            `STEP1: begin
                {shL_R, shL_Q} = 2'b11;
                if (co == 1'b1)
                    doneDiv = 1'b1;
            end
            `STEP2: {ldRegR, ldRegQ, selshQ, incCnt} = 4'b1111;
        endcase
    end

endmodule