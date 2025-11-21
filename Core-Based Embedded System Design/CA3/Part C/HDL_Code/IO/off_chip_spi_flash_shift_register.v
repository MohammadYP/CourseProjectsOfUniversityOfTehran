module shift_spi_io_register #( parameter SIZE = 8) (
    input clk,
    input rst,
    input load,
    input clear,
    input shift,
    input serIn,
    input [SIZE - 1:0] dataIn,
    output reg [SIZE - 1:0] dataOut
);

    always @ (posedge clk, posedge rst) begin 
        if(rst)
            dataOut = {(SIZE){1'b0}};
        else if(clear)
            dataOut = {(SIZE){1'b0}};
        else if(shift)
            dataOut = {dataOut[SIZE - 2:0], serIn};
        else if(load)
            dataOut = dataIn;
        
    end

endmodule
