module SRAM (
    input clk,
    input rst,
    input cs,
    input wen,
    input [11:0] addressBus,
    input [7:0] memDataIN,
    output reg memReady,
    output [7:0] memDataOut
);

    M31HDSP200GB180W_4096X8X1CM16 sram(
        .CLK(clk),
        .CEN(~cs),
        .WEN(~wen),
        .A(addressBus),
        .D(memDataIN),
        .Q(memDataOut)
    );

    reg ps, ns;

    always@(*) begin 
        memReady = 1'b0;
        ns = 1'b0;
        case (ps)
            1'b0: begin
                memReady = cs ? 1'b0 : 1'b1;
                ns = cs ? 1'b1 : 1'b0;
            end 
            1'b1: begin
                memReady = 1'b1;
                ns = 1'b0;
            // default: 
            //     ns = 1'b0;
            end
        endcase

    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1)
            ps <= 0;
        else
            ps <= ns;
    end

    // always @(posedge clk, posedge rst) begin
    //     if(rst == 1'b1)
    //         memReady = 1'b1;
    //     else if(cs == 1'b1) begin
    //         if(memReady == 1'b1 )
    //             memReady = 1'b0;
    //         else 
    //             memReady = 1'b1;
    //     end
    // end

endmodule