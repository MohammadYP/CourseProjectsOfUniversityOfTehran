module SPI (
    input clk,
    input rst,
    input cs,
    input readMem,
    input [23:0] addressBus,
    input [7:0] dataIn,

    output ready,
    output [7:0] dataOut
);

    wire SCK;
    wire CSbar;
    wire DI;
    wire DO;

    spi_flash_controller spi_cnt(
        .clk(clk),
        .rst(rst),
        .chipSel(cs),
        .readMem(readMem),
        .addressBus(addressBus),
        .dataIn(dataIn),
        .dataOut(dataOut),
        .ready(ready),
        .SCK(SCK),
        .CSbar(CSbar),
        .DI(DI),
        .DO(DO)
    );
    
    virtual_flash vir_flash(
        .SCK(SCK),
        .CSbar(CSbar),
        .DI(DI),
        .DO(DO)
    );

endmodule