module datapath (
    input clk,
    input rst,
    input loadA,
    input loadB,
    input loadR,
    input clearA,
    input clearB,
    input clearR,
    input shiftA,
    input cntE,
    input loadC,
    input clearC,
    input [7:0] inA,
    input [7:0] inB,
    output [1:0] cntOut,
    output [15:0] outR
);

    wire [2:0] sel;
    wire [7:0] outB;
    wire [7:0] _outB;
    wire [8:0] outA;
    wire [15:0] inR;
    wire [15:0] variantB;
    wire [15:0] shiftedVariantB;

    shift2_register #(
        .size(9)
    ) regA (
        .clk(clk),
        .rst(rst),
        .load(loadA),
        .clear(clearA),
        .shift(shiftA),
        .dataIn({inA, 1'b0}),
        .dataOut(outA)
    );

    register #(
        .size(8)
    ) regB (
        .clk(clk),
        .rst(rst),
        .load(loadB),
        .clear(clearB),
        .dataIn(inB),
        .dataOut(outB)
    );

    encoder enc(
        .block(outA[2:0]),
        .sel(sel)
    );

    register #(
        .size(16)
    ) resReg (
        .clk(clk),
        .rst(rst),
        .load(loadR),
        .clear(clearR),
        .dataIn(inR),
        .dataOut(outR)
    );

    assign _outB = ~outB + 1;

    assign variantB = (sel == 3'b000) ? 16'b0 : 
                      (sel == 3'b001) ? {{(8){outB[7]}}, outB} : 
                      (sel == 3'b010) ? {{(7){outB[7]}}, outB, 1'b0} :
                      (sel == 3'b011) ? {{(8){_outB[7]}}, _outB} :
                      {{(7){_outB[7]}}, _outB, 1'b0};

    counter #(
        .size(2)
    ) counter1 (
        .clk(clk),
        .rst(rst),
        .cntE(cntE),
        .load(loadC),
        .clear(clearC),
        .dataIn(2'b00),
        .dataOut(cntOut)
    );
    
    assign shiftedVariantB = (cntOut == 2'b00) ? variantB : 
                             (cntOut == 2'b01) ? {variantB[13:0], 2'b0} : 
                             (cntOut == 2'b10) ? {variantB[11:0], 4'b0} : 
                             {variantB[9:0], 6'b0};

    assign inR = outR + shiftedVariantB;
    
endmodule