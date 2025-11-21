module fact_CNFregister #(
    parameter SIZE = 32
) (
    input clk,
    input rst,
    input load,
    input done,
    input [SIZE - 1:0] in,
    output reg [SIZE - 1:0] out
);
    
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            out <= {(SIZE){1'b0}};
        end
        else if(out[1] == 1'b1) begin
            out <= {out[7:3], 2'b0, out[0]};
        end
        else if(done == 1'b1) begin
            out <= {out[7:3], 1'b1, out[1:0]};
        end
        else if(load) begin
            out <= in;
        end
    end

endmodule