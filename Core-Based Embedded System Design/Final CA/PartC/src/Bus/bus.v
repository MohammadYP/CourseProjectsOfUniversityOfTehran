module Bus #(
    parameter DATA_WIDTH = 8,
    parameter ADDRESS_WiDTH = 32
)(
    input clk,
    input rst,
    input readMem,
    input writemem,
    input to_embedded,
    input [ADDRESS_WiDTH - 1:0] addressBus,
    input [DATA_WIDTH - 1:0] dataBusIn,
    output memDataReady,
    output uart_interrupt,
    output [DATA_WIDTH - 1:0] dataBusOut

);
    
    wire sel_InstMem;
    wire sel_DataMem;
    wire sel_HTS;
    wire sel_Timer;
    wire sel_Pump;
    wire sel_FLS;
    wire sel_RX;
    wire sel_TX;

    wire readySPI;
    wire readySRAM;
    wire readyHTS;
    wire readyTimer;
    wire readyPump;
    wire readyFLS;
    wire readyRX;
    wire readyTX;

    wire [DATA_WIDTH - 1:0] IM_out;
    wire [DATA_WIDTH - 1:0] DM_out;
    wire [DATA_WIDTH - 1:0] HTS_out;
    wire [DATA_WIDTH - 1:0] Timer_out;
    wire [DATA_WIDTH - 1:0] FLS_out;
    wire [DATA_WIDTH - 1:0] RX_out;
    wire [DATA_WIDTH - 1:0] TX_out;

    wire pump_activated;

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

    HumidityTemperatureSensor #(
        .ADDRESSH(7'd4),
        .ADDRESST(7'd8)
    ) HTS (
            .clk(clk),
            .rst(rst),
            .addr(addressBus[6:0]),
            .data_in(dataBusIn),
            .enable(sel_HTS),
            .read(readMem),
            .HTS_out(HTS_out),
            .ready(readyHTS)
    );

    timerWrapper timer(
        .clk(clk),
        .rst(rst),
        .addressIn(addressBus[2:0]),
        .read(sel_Timer & readMem),
        .write(sel_Timer & writemem),
        .dataIn(dataBusIn),
        .dataOut(Timer_out),
        .IRQ() ///////////////////////////// check later 
    );

    pumpWrapper pump(
        .clk(clk),
        .rst(rst),
        .write(sel_Pump & writemem),
        .address(addressBus[1:0]),
        .dataIn(dataBusIn),
        .pump_activated(pump_activated)
    );

    FLSWrapper FLS(
        .clk(clk),
        .rst(rst),
        .pump_activated(pump_activated),
        .address(addressBus[1:0]),
        .sensOut(FLS_out)
    );

    RX_wrapper UART_RX(
        .clk(clk),
        .rst(rst),
        .read(sel_RX & readMem),
        .write(sel_RX & writemem),
        .r_Rx_Serial(to_embedded),
        .addr(addressBus[3:0]),
        .data_in(dataBusIn),
        .interrupt(uart_interrupt),
        .ready(readyRX),
        .data_out(RX_out)
    );

    TX_wrapper UART_TX(
        .clk(clk),
        .rst(rst),
        .read(sel_TX & readMem),
        .write(sel_TX & writemem),
        .addr(addressBus[2:0]),
        .data_in(dataBusIn),
        .ready(readyTX),
        .data_out(TX_out)
    );

    assign sel_InstMem = ~(|addressBus[31:12]);
    assign sel_DataMem = (addressBus[31:12] == 20'h0010_0);
    assign sel_HTS = (addressBus[31:8] == 24'hFFFF_FF);
    assign sel_Timer = (addressBus[31:8] == 24'hFFFF_F0);
    assign sel_Pump = (addressBus[31:8] == 24'hFFFF_0F);
    assign sel_FLS = (addressBus[31:8] == 24'hFFFF_00);
    assign sel_RX = (addressBus[31:8] == 24'hFFF0_00);
    assign sel_TX = (addressBus[31:8] == 24'hFFF1_00);

    assign memDataReady = (sel_InstMem == 1'b1) ? readySPI :
                          (sel_DataMem == 1'b1) ? readySRAM :
                          (sel_HTS == 1'b1) ? readyHTS :
                          (sel_Timer == 1'b1) ? readyTimer : 
                          (sel_Pump == 1'b1) ? readyPump :
                          (sel_FLS == 1'b1) ? readyFLS :
                          (sel_RX == 1'b1) ? readyRX :
                          (sel_TX == 1'b1) ? readyTX :
                          1'b0;
    assign dataBusOut = (sel_InstMem == 1'b1) ? IM_out :
                        (sel_DataMem == 1'b1) ? DM_out :
                        (sel_HTS == 1'b1) ? HTS_out :
                        (sel_Timer == 1'b1) ? Timer_out :
                        (sel_FLS == 1'b1) ? FLS_out :
                        (sel_RX == 1'b1) ? RX_out :
                        (sel_TX == 1'b1) ? TX_out :
                        8'b0;  

    assign readyTimer = 1'b1;
    assign readyPump = 1'b1;
    assign readyFLS = 1'b1;

endmodule