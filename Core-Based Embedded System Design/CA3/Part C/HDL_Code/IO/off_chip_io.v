module off_chip_io (
    input clk,
    input rst,
    input DO,
    input read,
    input write,
    input [7:0] dataIn,
    input [31:0] address,

    output DI,
    output ready,
    output CSbar,
    output [7:0] dataOut
);

    wire cntECnt;
    wire clearCnt;
    wire loadSh1;
    wire loadSh3;
    wire shift1;
    wire shift2;
    wire shift3;
    wire sel;
    wire [5:0] countOut;
    wire [31:0] readData;
    wire [31:0] writeData;
    wire [31:0] writeRegIn;

    off_chip_spi_flash_datapath dp(
        .clk(clk),
        .rst(rst),
        .cntECnt(cntECnt),
        .clearCnt(clearCnt),
        .loadSh1(loadSh1),
        .loadSh3(loadSh3),
        .shift1(shift1),
        .shift2(shift2),
        .shift3(shift3),
        .DO(DO),
        .sel(sel),
        .writeData(writeData),
        .DI(DI),
        .countOut(countOut),
        .readData(readData)
   );

    off_chip_spi_flash_controller cu(
        .clk(clk),
        .rst(rst),
        .read(read),
        .write(write),
        .countOut(countOut),
        .cntECnt(cntECnt),
        .clearCnt(clearCnt),
        .loadSh1(loadSh1),
        .loadSh3(loadSh3),
        .shift1(shift1),
        .shift2(shift2),
        .shift3(shift3),
        .sel(sel),
        .ready(ready),
        .CSbar(CSbar)
    );

    wire loadReg;

    off_chip_spi_flash_register #(
        .SIZE(32)
        ) dataInReg (
            .clk(clk),
            .rst(rst),
            .load(loadReg),
            .in(writeRegIn),
            .out(writeData)
        );

    assign loadReg = (address == 32'd4) | 
                     (address == 32'd5) | 
                     (address == 32'd6) | 
                     (address == 32'd7);

    assign writeRegIn = (address == 32'd4) ? {writeData[31:8], dataIn} :
                        (address == 32'd5) ? {writeData[31:16], dataIn, writeData[7:0]} :
                        (address == 32'd6) ? {writeData[31:24], dataIn, writeData[15:0]} :
                        (address == 32'd7) ? {dataIn, writeData[23:0]} :
                        32'b0;

    assign dataOut = (address == 32'd0) ? readData[7:0] :
              (address == 32'd1) ? readData[15:8] :
              (address == 32'd2) ? readData[23:16] : 
              (address == 32'd3) ? readData[31:24] :
              8'b0;

endmodule