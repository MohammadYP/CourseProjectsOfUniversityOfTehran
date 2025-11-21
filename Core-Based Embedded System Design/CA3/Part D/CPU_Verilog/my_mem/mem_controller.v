module mem_controller #(
    parameter dataWidth = 8,
    parameter addressWidth = 32
)(
    input clk,
    input rst,
    input readmem,
    input writemem,
    input [addressWidth-1:0] addressBus,
    input [dataWidth-1:0] dataBusIn,
    input load_gpio,
    input [31:0] in_gpio,
    output [dataWidth-1:0] dataBusOut,
    output memDataReady,
    output gpio_interrupt,
    output [31:0] out_gpio
);
    
    wire sel_InstMem;
    wire sel_DataMem;
    wire sel_gpio;
    wire sel_fact;
    wire [dataWidth-1:0] IM_out;
    wire [dataWidth-1:0] DM_out;
    wire [dataWidth-1:0] GPIO_out;
    wire [dataWidth-1:0] fact_out;

    InstrMem IM(
        .addressBus(addressBus),
        .memDataOut(IM_out)
    );

    DataMem DM(
        .write(writemem & sel_DataMem),
        .addressBus(addressBus - 32'h0010_0000),
        .memDataIN(dataBusIn),
        .memDataOut(DM_out)
    );

    GPIO gpio(
        .clk(clk),
        .rst(rst),
        .writeBus(writemem & sel_gpio),
        .load_gpio(load_gpio),
        .dataBusIn(dataBusIn),
        .addressBus(addressBus - 32'h0100_0000),
        .in_gpio(in_gpio),
        .interruptBus(gpio_interrupt),
        .dataBusOut(GPIO_out),
        .out_gpio(out_gpio)
    );

    wrapper_factorial w_fact(
    .clk(clk),
    .rst(rst),
    .writeBus(writemem & sel_fact),
    .dataBusIn(dataBusIn),
    .addressBus(addressBus - 32'h1000_0000),
    .dataBusOut(fact_out)
);

    assign sel_InstMem = ~(|addressBus[31:12]);
    assign sel_DataMem = (addressBus[31:12] == 20'h00100);
    assign sel_gpio = (addressBus[31:4] == 28'h0100_000);
    assign sel_fact = (addressBus[31:4] == 28'h1000_000);

    assign memDataReady = 1'b1;
    assign dataBusOut = (sel_InstMem == 1'b1) ? IM_out :
                        (sel_DataMem == 1'b1) ? DM_out :
                        (sel_gpio == 1'b1) ? GPIO_out :
                        (sel_fact == 1'b1) ? fact_out :
                        8'b0;  


endmodule