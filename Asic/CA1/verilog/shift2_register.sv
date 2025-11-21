module shift2_register #( parameter size = 8) (
    input clk,
    input rst,
    input load,
    input clear,
    input shift,
    input [size-1 : 0] dataIn,
    output reg [size-1 : 0] dataOut
);

    always @ (posedge clk, posedge rst) begin 
        if(rst)
            dataOut = {(size){1'b0}};
        else if(clear)
            dataOut = {(size){1'b0}};
        else if(shift)
            dataOut = {2'b0, dataOut[size-1 : 2]};
        else if(load)
            dataOut = dataIn;
        
    end

endmodule
