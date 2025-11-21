module DataMem #(
    parameter dataWidth = 8,
    parameter blockSize = 4096,
    parameter addressWidth = 32
)(
    input write,
    input [addressWidth - 1:0] addressBus,
    input [dataWidth - 1:0] memDataIN,
    output [dataWidth - 1:0] memDataOut
);

    reg [dataWidth - 1:0] mem [0:blockSize - 1];
    initial begin
        $readmemh( "DataMem.txt", mem );
    end

    assign memDataOut = mem[addressBus];

    always @(write, memDataIN, addressBus) begin
        if(write) begin
            mem[addressBus] = memDataIN;
        end
    end

endmodule