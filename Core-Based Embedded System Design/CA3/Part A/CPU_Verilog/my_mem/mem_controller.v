module mem_controller #(
    parameter dataWidth = 8,
    parameter addressWidth = 32
)(
    input readmem,
    input writemem,
    input [addressWidth-1:0] addressBus,
    input [dataWidth-1:0] dataBusIn,
    output [dataWidth-1:0] dataBusOut,
    output memDataReady
);
    
    wire sel_InstMem;
    wire sel_DataMem;
    wire [dataWidth-1:0] IM_out;
    wire [dataWidth-1:0] DM_out;

    InstrMem IM(
        .addressBus(addressBus),
        .memDataOut(IM_out)
    );

    DataMem DM(
        .write(writemem),
        .addressBus(addressBus - 32'h0010_0000),
        .memDataIN(dataBusIn),
        .memDataOut(DM_out)
    );

    assign sel_InstMem = ~(|addressBus[31:12]);
    assign sel_DataMem = (addressBus[31:12] == 20'h00100);

    assign memDataReady = 1'b1;
    assign dataBusOut = (sel_InstMem == 1'b1) ? IM_out :
                        (sel_DataMem == 1'b1) ? DM_out :
                        8'b0;  


endmodule