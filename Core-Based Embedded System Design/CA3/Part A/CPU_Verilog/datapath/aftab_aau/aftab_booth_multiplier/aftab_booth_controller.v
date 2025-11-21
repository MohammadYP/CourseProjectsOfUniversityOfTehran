// **************************************************************************************
// Filename: aftab_booth_controller.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_booth_controller
// Description:
//
// Dependencies:
//
// File content description:
// booth_controller for AFTAB AAU
//
// **************************************************************************************

`timescale 1ns/1ns

`define ADD 2'b01
`define SUB 2'b10
`define IDLE 2'b00
`define INIT 2'b01
`define COUNT_SHIFT 2'b10
`define COMPLETED 2'b11
`define LOG2_CEIL(BITS) ((BITS <= 1) ? 0: (BITS <= 2) ? 1: (BITS <= 4) ? 2: (BITS <= 8) ? 3: (BITS <= 16) ? 4: (BITS <= 32) ? 5: (BITS <= 64) ? 6: (BITS <= 128)? 7:0)

module aftab_booth_controller #(parameter size = 4) (
    input startBooth,
    input clk,
    input rst,
    input [1:0] op,
    output reg shrMr,
    output reg ldMr,
    output reg ldM,
    output reg ldP,
    output reg zeroP,
    output reg sel,
    output reg subsel,
    output reg done
);

    reg [1:0] p_state, n_state;
    wire co;
    reg cnt_en;
    reg cnt_rst;
    reg iniCnt;

    aftab_counter #(`LOG2_CEIL(size)) counter(
        .dataOut(),
        .initValue({1'b0, {(`LOG2_CEIL(size) - 1){1'b1}}}),
        .co(co),
        .zero(1'b0),
        .incCnt(cnt_en),
        .iniCnt(iniCnt),
        .clk(clk),
        .rst(rst)
    );

    always @(posedge clk, posedge rst) begin
        if (rst)
            p_state <= `IDLE;
        else
            p_state <= n_state;
    end


    always @(p_state, startBooth, op, co) begin
        {ldM, ldMr, ldP, zeroP, shrMr, sel, subsel, done, cnt_rst, cnt_en, iniCnt} <= 11'b0;
        case(p_state)
            `IDLE: begin
            end
            `INIT: begin
                ldMr <= 1'b1;
                zeroP <= 1'b1;
                ldM <= 1'b1;
                iniCnt <= 1'b1;
            end
            `COUNT_SHIFT: begin
                cnt_en <= 1'b1;
                shrMr <= 1'b1;
                ldP  <= 1'b1;
                if (op == `SUB) begin
                    subsel <= 1'b1;
                    sel <= 1'b1;
                end
                else if (op == `ADD)
                    sel <= 1'b1;
            end
            `COMPLETED: begin
                done <= 1'b1;
            end
        endcase
    end

    always @(p_state, startBooth, op, co) begin
        n_state <= `COMPLETED;
        case(p_state)
            `IDLE:
                if (startBooth)
                    n_state <= `INIT;
                else
                    n_state <= `IDLE;
            `INIT:
                n_state <= `COUNT_SHIFT;
            `COUNT_SHIFT:
                if (~co)
                    n_state <= `COUNT_SHIFT;
                else
                    n_state <= `COMPLETED;
            `COMPLETED:
                n_state <= `IDLE;
        endcase
    end

endmodule
