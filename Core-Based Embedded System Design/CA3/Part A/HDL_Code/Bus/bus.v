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
    wire readySPI;
    wire [DATA_WIDTH - 1:0] IM_out;
    wire [DATA_WIDTH - 1:0] DM_out;

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

    // InstrMem IM(
    //     .addressBus(addressBus),
    //     .memDataOut(IM_out)
    // );

    DataMem DM(
        .write(writemem),
        .addressBus(addressBus - 32'h0010_0000),
        .memDataIN(dataBusIn),
        .memDataOut(DM_out)
    );

    assign sel_InstMem = ~(|addressBus[31:12]);
    assign sel_DataMem = (addressBus[31:12] == 20'h00100);

    // assign sel_InstMem = (addressBus === 'x || addressBus === 'z) ? 1'b1 : ~(|addressBus[31:12]);
    // assign sel_DataMem = (addressBus === 'x || addressBus === 'z) ? 1'b1 : (addressBus[31:12] == 20'h00100);

    assign memDataReady = (sel_InstMem == 1'b1) ? readySPI :
                          (sel_DataMem == 1'b1) ? 1'b1 :
                          1'b0;
    assign dataBusOut = (sel_InstMem == 1'b1) ? IM_out :
                        (sel_DataMem == 1'b1) ? DM_out :
                        8'b0;  


endmodule