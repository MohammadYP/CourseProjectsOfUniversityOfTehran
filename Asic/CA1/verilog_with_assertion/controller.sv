`define Idle 2'b00
`define Load 2'b01
`define Mul 2'b10
`define Done 2'b11

module controller (
    input clk,
    input rst,
    input start,
    input [1:0] cntOut,
    output reg loadA,
    output reg loadB,
    output reg loadR,
    output reg clearA,
    output reg shiftA,
    output reg clearB,
    output reg clearR,
    output reg cntE,
    output reg loadC,
    output reg clearC,
    output reg done
);

    reg [1:0] ps;
    reg [1:0] ns;

    always @(ps) begin

        {loadA, loadB, loadR, clearA, clearB, clearR,
         shiftA, cntE, loadC, clearC, done} <= 0;

        case (ps)
            `Idle : begin
            end 

            `Load : begin
                loadA <= 1'b1;
                loadB <= 1'b1;
                clearR <= 1'b1;
                loadC <= 1'b1;
            end

            `Mul : begin
                cntE <= 1'b1;
                loadR <= 1'b1;
                shiftA <= 1'b1;
            end

            `Done : begin
                done <= 1'b1;
            end
            
        endcase
    end

    always @(ps, start, cntOut) begin
        case (ps)
            `Idle : begin
                ns = (start == 1'b1) ? `Load : `Idle;
            end 

            `Load : begin
                ns = (start == 1'b0) ? `Mul : `Load ;
            end

            `Mul : begin
                ns = (cntOut == 2'b11) ? `Done : `Mul;
            end

            `Done : begin
                ns = `Idle;
            end
            
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            ps = `Idle;
        else 
            ps = ns;
    end
endmodule