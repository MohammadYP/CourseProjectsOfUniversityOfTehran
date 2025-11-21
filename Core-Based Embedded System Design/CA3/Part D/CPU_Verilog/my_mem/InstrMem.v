module InstrMem #(
    parameter dataWidth = 8,
    parameter blockSize = 4096,
    parameter addressWidth = 32
)
(
    input [addressWidth - 1:0] addressBus,
    output [dataWidth - 1:0] memDataOut
);
    reg [dataWidth-1:0] mem [0:blockSize-1];
    initial begin
        $readmemh( "InstrMem.txt", mem );
    end

    assign memDataOut = mem[addressBus];

endmodule