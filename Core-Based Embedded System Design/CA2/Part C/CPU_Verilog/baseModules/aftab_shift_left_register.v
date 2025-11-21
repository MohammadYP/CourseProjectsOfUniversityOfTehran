// **************************************************************************************
// Filename: aftab_shift_left_register.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_shift_left_register
// Description:
//
// Dependencies:
//
// File content description:
// shift_left_register for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_shift_left_register #(parameter size = 32) (
	input [size-1:0] dataIn,
    input sh_L_en,
    input init,
    input serIn,
    input clk,
    input rst,
    input Ld,
    output reg [size-1:0] dataOut,
    output reg serOut
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            {dataOut} <= {(size){1'b0}};
            serOut <= 1'b0;
        end
        else if (init) begin
            dataOut <= {(size){1'b0}};
            serOut <= 1'b0;
        end
        else if (Ld) begin
            dataOut <= dataIn;
        end
        else if (sh_L_en) begin
            dataOut <= {dataOut[size-2:0], serIn};
            serOut <= dataOut[size-1];
        end
        else begin
            dataOut <= dataOut;
            serOut <= serOut;
        end
    end

endmodule