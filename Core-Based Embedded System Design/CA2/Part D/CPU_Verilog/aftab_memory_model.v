// **************************************************************************************
// Filename: aftab_memory_model.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_memory_model
// Description:
//
// Dependencies:
//
// File content description:
// aftab_memory_model for AFTAB testing
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_memory_model #(
    parameter dataWidth = 8,
    parameter sector1Size = 4096,
    parameter sector2Size = 4096,
    parameter addressWidth = 32,
    parameter cycle = 25, // ns
    parameter timer = 5 // ns
)
(
    input readmem,
    input writemem,
    input [addressWidth-1:0] addressBus,
    input [dataWidth-1:0] dataBusIn,
    output [dataWidth-1:0] dataBusOut,
    output memDataReady
);

    wire memDataReady1;
    wire memDataReady2;

    aftab_memory_segment  #(
        .dataWidth(dataWidth),
        .addressWidth(addressWidth),
        .segmentID(),
        .segmentSize(sector1Size),
        .blockSize(sector1Size),
        .startingAddress(0),
        .cycle(cycle),
        .timer(timer),
        .filenum(1)
    ) seg1 (
        .readmem(readmem),
        .writemem(writemem),
        .addressBus(addressBus),
        .dataBusIn(dataBusIn),
        .dataBusOut(dataBusOut),
        .memDataReady(memDataReady1)
    );


    aftab_memory_segment  #(
        .dataWidth(dataWidth),
        .addressWidth(addressWidth),
        .segmentID(),
        .segmentSize(sector2Size),
        .blockSize(sector2Size),
        .startingAddress(sector1Size),
        .cycle(cycle),
        .timer(timer),
        .filenum(2)
    ) seg2 (
        .readmem(readmem),
        .writemem(writemem),
        .addressBus(addressBus),
        .dataBusIn(dataBusIn),
        .dataBusOut(dataBusOut),
        .memDataReady(memDataReady2)
    );

    assign memDataReady = (memDataReady1 == 1'b1 || memDataReady2 == 1'b1) ? 1'b1 : 1'b0;

endmodule