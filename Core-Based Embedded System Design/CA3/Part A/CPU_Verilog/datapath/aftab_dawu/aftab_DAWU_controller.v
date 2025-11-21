// **************************************************************************************
// Filename: aftab_DAWU_controller.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_DAWU_controller
// Description:
//
// Dependencies:
//
// File content description:
// DAWU_cu for AFTAB DAWU
//
// **************************************************************************************
`timescale 1ns/1ns

`define waitforStartDAWU 1'b0
`define waitforWrite 1'b1

module aftab_DAWU_controller(
    input startDAWU,
    input memRdy,
    input coCnt,
    input clk,
    input rst,
    output reg iniCnt,
    output reg LdAddr,
    output reg LdNumBytes,
    output reg LdData,
    output reg enableData,
    output reg enableAddr,
    output reg writeMem,
    output reg incCnt,
    output reg completeDAWU,
    output reg zeroCnt,
    output reg zeroNumBytes,
    output reg zeroAddr,
    output reg zeroData
);

    reg ns, ps;

    always @(posedge clk, posedge rst) begin
        if(rst)
            ps <= `waitforStartDAWU;
        else
            ps <= ns;
    end

    always @(ps,startDAWU, coCnt, memRdy) begin
        case (ps)
            `waitforStartDAWU: ns = (startDAWU) ? `waitforWrite : `waitforStartDAWU;
            `waitforWrite: ns = (memRdy & coCnt) ? `waitforStartDAWU : `waitforWrite;
        endcase
    end

    always @(ps, startDAWU, coCnt, memRdy) begin
        {iniCnt, LdAddr, LdNumBytes, LdData, enableData, enableAddr,
        writeMem, incCnt, completeDAWU, zeroCnt, zeroNumBytes,
        zeroAddr, zeroData} = 13'd0;
        case (ps)
            `waitforStartDAWU: begin
                {iniCnt, LdAddr, LdNumBytes, LdData} = (startDAWU) ? 4'b1111 : 4'b0000;
                if (coCnt & memRdy) begin
                    completeDAWU = 1'b1;
                end
            end
            `waitforWrite: begin
                {enableData, enableAddr, writeMem} = 3'b111;
                if (memRdy) begin
                    incCnt = 1'b1;
                end
                if (coCnt & memRdy) begin
                    completeDAWU = 1'b1;
                end
            end
        endcase
    end

endmodule

