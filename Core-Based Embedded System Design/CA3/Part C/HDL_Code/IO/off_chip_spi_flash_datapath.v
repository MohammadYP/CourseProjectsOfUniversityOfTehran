module off_chip_spi_flash_datapath (
    input clk,
    input rst,
    input cntECnt,
    input clearCnt,
    input loadSh1,
    input loadSh3,
    input shift1,
    input shift2,
    input shift3,
    input DO,
    input sel,
    input [31:0] writeData,
    
    output DI,
    output [5:0] countOut,
    output [31:0] readData
);
    
    wire [31:0] shiftRegOut;
    wire [63:0] writeShiftRegOut;

    spi_io_counter #(
        .SIZE(6)
    ) counter (
        .clk(clk),
        .rst(rst),
        .cntE(cntECnt),
        .load(1'b0),
        .clear(clearCnt),
        .dataIn(6'b0),
        .dataOut(countOut)
    );

    shift_spi_io_register #(
        .SIZE(32)
    ) shifReg1(
        .clk(clk),
        .rst(rst),
        .load(loadSh1),
        .clear(1'b0),
        .shift(shift1),
        .serIn(1'b0),
        .dataIn(32'h03000000),
        .dataOut(shiftRegOut)
    );

    shift_spi_io_register #(
        .SIZE(32)
    ) shifReg2(
        .clk(clk),
        .rst(rst),
        .load(1'b0),
        .clear(1'b0),
        .shift(shift2),
        .serIn(DO),
        .dataIn(32'h3000),
        .dataOut(readData)
    );

    shift_spi_io_register #(
        .SIZE(64)
    ) shifReg3(
        .clk(clk),
        .rst(rst),
        .load(loadSh3),
        .clear(1'b0),
        .shift(shift3),
        .serIn(DO),
        .dataIn({32'h2000, writeData}),
        .dataOut(writeShiftRegOut)
    );   

    assign DI = sel ? shiftRegOut[31] : writeShiftRegOut[63];

endmodule