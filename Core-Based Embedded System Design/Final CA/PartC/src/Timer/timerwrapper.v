module timerWrapper(
    input clk,
    input rst,
    input [2:0] addressIn,
    input read,
    input write,
    input [7:0] dataIn,
    
    output [7:0] dataOut,
    output IRQ
);
    wire [31:0] outTimer;
    reg [31:0] shreg;
    always @(posedge clk, posedge rst) begin
        if(rst)
            shreg <= 0;
        else if (write)
            shreg <= {dataIn,shreg[31:8]};
        else 
            shreg <= shreg;
    end
    timer cpuTimer (
        .clk(clk),
        .rst(rst),
        .read(read),
        .write(write),
        .IRQTime(shreg),
        .dataOut(outTimer),
        .IRQ(IRQ)
    );
    assign dataOut =    (addressIn == 3'd4) ? outTimer[7:0] :
                        (addressIn == 3'd5) ? outTimer[15:8] :
                        (addressIn == 3'd6) ? outTimer[23:16] :
                        (addressIn == 3'd7) ? outTimer[31:24] :
                        outTimer[7:0];
    

    
endmodule