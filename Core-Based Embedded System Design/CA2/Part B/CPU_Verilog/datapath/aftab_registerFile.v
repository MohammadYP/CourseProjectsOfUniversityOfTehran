// **************************************************************************************
// Filename: aftab_registerFile.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_registerFile
// Description:
//
// Dependencies:
//
// File content description:
// regFile for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_registerFile #(parameter size = 32) (
    input clk,
    input rst,
    input setZero,
    input setOne,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [size-1:0] writeData,
    input writeRegFile,
    output [size-1:0] p1,
    output [size-1:0] p2
);

    reg [size-1:0] register_file [0:31];
    integer i;

    assign p1 = (rs1 == 5'b0) ? {(size){1'b0}} : register_file[rs1];
    assign p2 = (rs2 == 5'b0) ? {(size){1'b0}} : register_file[rs2];

    always @(posedge clk, posedge rst)begin
        if (rst == 1'b1)
        for (i = 0; i < 32 ; i = i + 1)
            register_file[i] <= 32'd0;
        else if(rd != 5'd0)
        if(setZero == 1'b1)
            register_file[rd] <= 32'd0;
        else if(setOne == 1'b1)
            register_file[rd] <= 32'd1;
        else if (writeRegFile == 1'b1)
            register_file[rd]<=writeData;
        end

endmodule