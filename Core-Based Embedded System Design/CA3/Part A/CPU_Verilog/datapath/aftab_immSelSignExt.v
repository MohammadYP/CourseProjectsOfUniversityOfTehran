// **************************************************************************************
// Filename: aftab_immSelSignExt.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_immSelSignExt
// Description:
//
// Dependencies:
//
// File content description:
// immSelSignExt for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_immSelSignExt #(parameter size = 32) (
    input IR7,
    input IR20,
    input IR31,
    input [3:0] IR11_8,
    input [7:0] IR19_12,
    input [3:0] IR24_21,
    input [5:0] IR30_25,
    input selI,
    input selS,
    input selBUJ,
    input selIJ,
    input selSB,
    input selU,
    input selISBJ,
    input selIS,
    input selB,
    input selJ,
    input selISB,
    input selUJ,
    output [size-1:0] Imm
);

    assign Imm [0] = (selI == 1'b1) ? IR20 :
                     (selS == 1'b1) ? IR7 :
                     (selBUJ == 1'b1) ? 1'b0 :
                     1'b0;

    assign Imm [4:1] = (selIJ == 1'b1) ? IR24_21 :
                       (selSB == 1'b1) ? IR11_8 :
                       (selU == 1'b1) ? 4'b0000 :
                       4'b0000;

    assign Imm [10:5] = (selISBJ == 1'b1) ? IR30_25 :
                        (selU == 1'b1) ? 5'b00000 :
                        5'b00000;

    assign Imm[11] = (selIS == 1'b1) ? IR31 :
                     (selB == 1'b1) ? IR7 :
                     (selU == 1'b1) ? 1'b0 :
                     (selJ == 1'b1) ? IR20 :
                     1'b0;

    assign Imm[19:12] = (selISB == 1'b1) ? {(8){IR31}} :
                        (selUJ == 1'b1) ? IR19_12 :
                        8'b00000000;

    assign Imm[30:20] = (selISBJ == 1'b1) ? {(11){IR31}} :
                        (selU == 1'b1) ? {IR30_25, IR24_21, IR20} :
                        11'b00000000000;

    assign Imm[31] = IR31;

endmodule