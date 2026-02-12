`define RT      6'b000000

`define addi    6'b001000
`define addiu   6'b001001
`define slti    6'b001010
`define sltiu   6'b001011
`define andi    6'b001100
`define ori     6'b001101
`define xori    6'b001110
`define lui     6'b001111

`define lw      6'b100011
`define sw      6'b101011

`define beq     6'b000100
`define bne     6'b000101

`define j       6'b000010
`define jal     6'b000011

module Hazard_Unit (
    input [4:0] rs,
    input [4:0] rt,
    input [5:0] opcode,

    input MemRead_E,

    input we_E,
    input [4:0] ws_E,

    output stall
);
    
    wire re1_D;
    wire re2_D;

    assign re1_D =  (opcode == `RT)|
                    (opcode == `addi)|
                    (opcode == `addiu)|
                    (opcode == `slti)|
                    (opcode == `sltiu)|
                    (opcode == `andi)|
                    (opcode == `ori)|
                    (opcode == `xori)|
                    (opcode == `lui)|
                    (opcode == `lw)|
                    (opcode == `sw)|
                    (opcode == `beq)|
                    (opcode == `bne)|
                    (opcode == `j)|
                    (opcode == `jal);

    assign re2_D = (opcode == `RT)|(opcode == `sw);

    assign stall = ((rs == ws_E) & (MemRead_E == 1'b1) & (ws_E != 1'b0) & re1_D) |
                   ((rt == ws_E) & (MemRead_E == 1'b1) & (ws_E != 1'b0) & re2_D);

endmodule