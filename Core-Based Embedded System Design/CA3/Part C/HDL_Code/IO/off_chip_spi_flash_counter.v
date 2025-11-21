module spi_io_counter #(parameter SIZE = 2) (
    input clk,
    input rst,  
    input cntE,
    input load,
    input clear,
    input [SIZE - 1:0] dataIn,
    output reg [SIZE - 1:0] dataOut
);

    always @(posedge clk, posedge rst) begin
        if(rst)
            dataOut <= {(SIZE){1'b0}};
        else if(clear)
            dataOut <= {(SIZE){1'b0}};
        else if(load)
            dataOut <= dataIn;
        else if(cntE)
            dataOut <= dataOut + 1;
        else
            dataOut <= dataOut;
    end
endmodule
