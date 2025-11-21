// **************************************************************************************
// Filename: aftab_AAU_TB.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_AAU_TB
// Description:
//
// Dependencies:
//
// File content description:
// AAUTB for AFTAB AAU testing
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_AAU_TB();
    reg [31:0] A, B;
    reg clk=1;
    reg rst;
    reg startAAU, multAAU, divideAAU, signedSigned, signedUnsigned, unsignedUnsigned;
    wire [31:0] H, L;
    wire completeAAU;
    wire dev0;

    aftab_AAU MUT(A, B, clk, rst, multAAU, divideAAU, signedSigned, signedUnsigned, unsignedUnsigned,
            H, L , completeAAU, dev0);

    initial repeat (1000) #10 clk = ~clk;

    initial begin
    rst = 1;
    //1
    multAAU=1;
    divideAAU=0;
    signedSigned=1;
    signedUnsigned=0;
    unsignedUnsigned=0;
    A = 32'd40;
    B= -32'd2;
    #20;
    rst=0;
    #50;
    multAAU=0;
    #2000;
    //2
    multAAU=1;
    divideAAU=0;
    signedSigned=0;
    signedUnsigned=1;
    unsignedUnsigned=0;
    A = 32'd1;
    B= -32'd2;
    #20;
    #60;
    multAAU=0;
    #2000;
    //3
    multAAU=0;
    divideAAU=1;
    signedSigned=0;
    signedUnsigned=1;
    unsignedUnsigned=0;
    A = -32'd120;
    B= 32'd7;
    #55;
    divideAAU=0;
    #2000;
    //4
    multAAU=0;
    divideAAU=1;
    signedSigned=0;
    signedUnsigned=0;
    unsignedUnsigned=1;
    A = 32'd121;
    B= 32'd7;
    #20;
    #60;
    divideAAU=0;
    #200;
    end
endmodule