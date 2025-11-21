module Bus #(
    parameter DATA_WIDTH = 8,
    parameter ADDRESS_WiDTH = 32
)(
    input clk,
    input rst,
    input readMem,
    input writemem,
    input [ADDRESS_WiDTH - 1:0] addressBus,
    input [DATA_WIDTH - 1:0] dataBusIn,
    output memDataReady,
    output [DATA_WIDTH - 1:0] dataBusOut

);
    
    wire sel_InstMem;
    wire sel_DataMem;
    wire sel_SPI_IO;
    wire readySPI;
    wire readySRAM;
    wire readIO;
    wire CSbar;
    wire DO;
    wire DI;
    wire [DATA_WIDTH - 1:0] IM_out;
    wire [DATA_WIDTH - 1:0] DM_out;
    wire [DATA_WIDTH - 1:0] IO_out;

    SPI spi(
        .clk(clk),
        .rst(rst),
        .cs(sel_InstMem),
        .readMem(readMem),
        .addressBus(addressBus[23:0]),
        .dataIn(dataBusIn),
        .ready(readySPI),
        .dataOut(IM_out)
    );

    SRAM sram(
        .clk(clk),
        .rst(rst),
        .cs(sel_DataMem),
        .wen(writemem),
        .addressBus(addressBus[11:0]),
        .memDataIN(dataBusIn),
        .memReady(readySRAM),
        .memDataOut(DM_out)
    );

    off_chip_io io(
        .clk(clk),
        .rst(rst),
        .DO(DO),
        .read(readMem & sel_SPI_IO),
        .write(writemem & sel_SPI_IO),
        .address({8'b0, addressBus[23:0]}),
        .DI(DI),
        .ready(readIO),
        .CSbar(CSbar),
        .dataIn(dataBusIn),
        .dataOut(IO_out)
    );

    off_chip_virtual_flash off_chip_flash(
        .SCK(clk),
        .CSbar(CSbar),
        .DI(DI),
        .DO(DO)
    );

    assign sel_InstMem = ~(|addressBus[31:12]);
    assign sel_DataMem = (addressBus[31:12] == 20'h00100);
    assign sel_SPI_IO = (addressBus[31:4] == 28'h0100_000);

    // assign sel_InstMem = (addressBus === 'x || addressBus === 'z) ? 1'b1 : ~(|addressBus[31:12]);
    // assign sel_DataMem = (addressBus === 'x || addressBus === 'z) ? 1'b1 : (addressBus[31:12] == 20'h00100);

    assign memDataReady = (sel_InstMem == 1'b1) ? readySPI :
                          (sel_DataMem == 1'b1) ? readySRAM :
                          (sel_SPI_IO == 1'b1) ? readIO : 
                          1'b0;
    assign dataBusOut = (sel_InstMem == 1'b1) ? IM_out :
                        (sel_DataMem == 1'b1) ? DM_out :
                        (sel_SPI_IO == 1'b1) ? IO_out :
                        8'b0;  


endmodule