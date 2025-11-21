module encoder (
    input [2:0] block,
    output [2:0] sel
);

    // 0 0
    // 1 x
    // 2 2x
    // 3 -x
    // 4 -2x

    assign sel = (block == 3'b000) ? 3'b000:
                 (block == 3'b001) ? 3'b001:
                 (block == 3'b010) ? 3'b001:
                 (block == 3'b011) ? 3'b010:
                 (block == 3'b100) ? 3'b100:
                 (block == 3'b101) ? 3'b011:
                 (block == 3'b110) ? 3'b011:
                 3'b000;
endmodule