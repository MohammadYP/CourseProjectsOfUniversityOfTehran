module counter #(parameter size = 2) (
    input clk,
    input rst,
    input cntE,
    input load,
    input clear,
    input [size-1 : 0] dataIn,
    output reg [size-1 : 0] dataOut
);

    always @(posedge clk, posedge rst) begin
        if(rst)
            dataOut <= {(size){1'b0}};
        else if(clear)
            dataOut <= {(size){1'b0}};
        else if(load)
            dataOut <= dataIn;
        else if(cntE)
            dataOut <= dataOut + 1;
        else
            dataOut <= dataOut;
    end
endmodule
