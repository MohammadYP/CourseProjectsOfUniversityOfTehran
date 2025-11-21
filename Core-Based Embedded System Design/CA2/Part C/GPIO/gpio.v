module GPIO (
    input clk,
    input rst,
    // input readBus,
    input writeBus,
    input load_gpio,
    input [7:0] dataBusIn,
    input [31:0] addressBus,
    input [31:0] in_gpio,

    output interruptBus,
    output [7:0] dataBusOut,
    output [31:0] out_gpio
);
    
    wire int_en;
    wire int_sts;
    wire loadCNF;
    wire loadResult;
    wire [7:0] outCNF;
    wire [31:0] resultIn;
    wire [31:0] nOut;

    gpio_register #(
        .SIZE(32)
    ) nReg (
        .clk(clk),
        .rst(rst),
        .load(load_gpio & int_en),
        .in(in_gpio),
        .out(nOut)
    );

    gpio_register #(
        .SIZE(32)
    ) resultReg (
        .clk(clk),
        .rst(rst),
        .load(loadResult),
        .in(resultIn),
        .out(out_gpio)
    );

    gpio_CNFregister #(
        .SIZE(8)
    ) CNFReg (
        .clk(clk),
        .rst(rst),
        .load(loadCNF),
        .NewData(load_gpio & int_en),
        .in(dataBusIn),
        .out(outCNF)
    );
    // 0 : int_en
    // 1 : int_sts
    // 2-7 : reserved

    assign int_en = outCNF[0];
    assign int_sts = outCNF[1];

    assign interruptBus = int_en & int_sts;

    // decoder

    assign dataBusOut = (addressBus == 32'd0) ? nOut[7:0] :
                        (addressBus == 32'd1) ? nOut[15:8] :
                        (addressBus == 32'd2) ? nOut[23:16] :
                        (addressBus == 32'd3) ? nOut[31:24] :
                        (addressBus == 32'd8) ? outCNF[7:0] :
                        8'b0;

    assign loadCNF = (writeBus & addressBus == 32'd8);
    assign loadResult = (writeBus & ((addressBus == 32'd4)
                                  | (addressBus == 32'd5)
                                  | (addressBus == 32'd6)
                                  | (addressBus == 32'd7)));

    assign resultIn = (addressBus == 32'd4) ? {out_gpio[31:8], dataBusIn[7:0]} :
                      (addressBus == 32'd5) ? {out_gpio[31:15], dataBusIn[7:0], out_gpio[7:0]} :
                      (addressBus == 32'd6) ? {out_gpio[31:24], dataBusIn[7:0], out_gpio[15:0]} :
                      (addressBus == 32'd7) ? {dataBusIn[7:0], out_gpio[23:0]} :
                      32'b0;
endmodule