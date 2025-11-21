module gpio_CNFregister #(
    parameter SIZE = 32
) (
    input clk,
    input rst,
    input load,
    input NewData,
    input [SIZE - 1:0] in,
    output reg [SIZE - 1:0] out
);
    
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            out <= {(SIZE){1'b0}};
        end
        else if(NewData) begin
            out <= {out[SIZE - 1:2], 1'b1, out[1'b0]};
        end
        else if(load) begin
            out <= in;
        end
    end

endmodule