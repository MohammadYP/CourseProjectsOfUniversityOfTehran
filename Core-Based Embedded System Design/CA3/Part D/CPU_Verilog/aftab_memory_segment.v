// **************************************************************************************
// Filename: aftab_memory_segment.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_memory_segment
// Description:
//
// Dependencies:
//
// File content description:
// aftab_memory_segment for AFTAB testing
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_memory_segment #(
    parameter dataWidth = 8,
    parameter addressWidth = 32,
    parameter segmentID = 1,
    parameter segmentSize = 2048,
    parameter blockSize = 2048,
    parameter startingAddress = 0,
    parameter cycle = 25, // ns
    parameter timer = 5, // ns
    parameter filenum = 1
)
(
    input readmem,
    input writemem,
    input [addressWidth-1:0] addressBus,
    input [dataWidth-1:0] dataBusIn,
    output [dataWidth-1:0] dataBusOut,
    output reg memDataReady
);

    // integer countSeg = 0;
    // integer countBlock = 0;
    // wire [9:0] s;
    // wire [9:0] b;

    // assign s = segmentSize;
    // assign b = blockSize;

    // genvar i;
    // generate
    //     for (i = 0; i < 9 ; i=i+1) begin:
    //         if (s[i] == 1'b1)
    //             countSeg = countSeg + 1;
    //         if (b[i] == 1'b1)
    //             blockSize = blockSize + 1;
    //     end
    //     assert (countSeg != 1)
    //         $display( "Invalid segmentSize")
    //     assert (countBlock != 1)
    //         $display( "Invalid segmentSize")

    // endgenerate

    reg [dataWidth-1:0] mem [0:blockSize-1];
    wire cs;

    initial begin
        if(filenum == 1)        $readmemh( "memCopy.mem", mem );
        else if(filenum == 2)   $readmemh( "memCopy.mem", mem );
        else $readmemh( "memCopy.mem", mem );
    end

    assign cs = ((startingAddress <= addressBus) && (addressBus < (startingAddress + segmentSize))) ? 1'b1 : 1'b0;

    assign dataBusOut = ((readmem == 1'b1) && (cs == 1'b1)) ? mem[addressBus % blockSize] : {(dataWidth){1'bz}};

    wire [addressWidth-1:0] addr;
    assign addr = addressBus;

    always @(cs, addr, writemem, readmem) begin
        if (cs == 1'b1 && (writemem == 1'b1 || readmem == 1'b1)) begin
            memDataReady = 1'b0;
            #(timer) memDataReady <= 1'b1;
            #(cycle) memDataReady <= 1'b0;
        end
        else
            memDataReady = 1'b0;
    end

    always @(cs, addr, writemem) begin
        if (writemem) begin
            #(timer) if (writemem) mem[addressBus % blockSize] = dataBusIn;
        end
    end

endmodule