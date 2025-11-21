// **************************************************************************************
// Filename: aftab_opt_adder.v
// Project: AFTAB
// Version: 1.0
// Date: 06/05/2019 04:41:33 PM
//
// Module Name: aftab_opt_adder
// Description:
//
// Dependencies:
//
// File content description:
// adder_opt_adder for AFTAB datapath
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_opt_adder #(parameter size = 4) (
    input [size-1:0] a,
    input [1:0] b,
    output [size-1:0] sum
);

    wire [size-1:0] cin;
    wire [size-1:0] cout;

    aftab_adder #(1) full_adder1 (
        .a(a[0]),
        .b(b[0]),
        .cin(1'b0),
        .cout(cout[0]),
        .sum(sum[0])
    );

    aftab_adder #(1) full_adder2 (
        .a(a[1]),
        .b(b[1]),
        .cin(cout[0]),
        .cout(cout[1]),
        .sum(sum[1])
    );

    genvar i;
    generate
    for (i = 2; i < size ; i=i+1) begin: half_adders
        aftab_adder #(1) half_adder (
            .a(a[i]),
            .b(cout[i-1]),
            .cin(1'b0),
            .cout(cout[i]),
            .sum(sum[i])
        );
    end
    endgenerate


endmodule
