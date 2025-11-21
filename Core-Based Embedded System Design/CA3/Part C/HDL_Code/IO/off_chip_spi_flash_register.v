module off_chip_spi_flash_register #(
    parameter SIZE = 32
) (
    input clk,
    input rst,
    input load,
    input [SIZE - 1:0] in,
    output reg [SIZE - 1:0] out
);
    
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            out <= {(SIZE){1'b0}};
        end
        else if(load) begin
            out <= in;
        end
    end

endmodule