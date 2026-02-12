`timescale 1ns/1ns

// OPCODES
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

// `define NOP     6'b111111

// FUNCT
`define ADD     6'b100000
`define ADDU    6'b100001
`define SUB     6'b100010
`define SUBU    6'b100011
`define ANDf    6'b100100
`define ORf     6'b100101
`define XORf    6'b100110
`define NORf    6'b100111
`define SLT     6'b101010
`define SLTU    6'b101011
`define SLL     6'b000000
`define SRL     6'b000010
`define SRA     6'b000011
`define SLLV    6'b000100
`define SRLV    6'b000110
`define SRAV    6'b000111
`define JR      6'b001000
`define JALR    6'b001001

// ALU Ops
`define OP_ADD    5'd0
`define OP_ADDU   5'd1
`define OP_SUB    5'd2
`define OP_SUBU   5'd3
`define OP_AND    5'd4
`define OP_OR     5'd5
`define OP_XOR    5'd6
`define OP_NOR    5'd7
`define OP_SLT    5'd8
`define OP_SLTU   5'd9
`define OP_SLL    5'd10
`define OP_SRL    5'd11
`define OP_SRA    5'd12
`define OP_SLLV   5'd13
`define OP_SRLV   5'd14
`define OP_SRAV   5'd15
`define OP_LUI    5'd16

module cntrl(
    input  [5:0] opcode,
    input  [5:0] func,
    output reg [1:0] RegDst,
    output reg [1:0] Jmp,
    output reg DataC,
    output reg Regwrite,
    output reg AluSrc,
    output reg Branch,
    output reg BranchNe,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg [4:0] AluOperation
);

always @(*) begin

    RegDst <= 0;
    Jmp <= 0;
    DataC <= 0;
    Regwrite <= 0;
    AluSrc <= 0;
    Branch <= 0;
    BranchNe <= 0;
    MemRead <= 0;
    MemWrite <= 0;
    MemtoReg <= 0;
    AluOperation <= `OP_ADD;

    case(opcode)

        `RT: begin
            RegDst <= 2'b01;
            Regwrite <= 1;

            case(func)
                `ADD:  AluOperation <= `OP_ADD;
                `ADDU: AluOperation <= `OP_ADDU;
                `SUB:  AluOperation <= `OP_SUB;
                `SUBU: AluOperation <= `OP_SUBU;

                `ANDf: AluOperation <= `OP_AND;
                `ORf:  AluOperation <= `OP_OR;
                `XORf: AluOperation <= `OP_XOR;
                `NORf: AluOperation <= `OP_NOR;

                `SLT:  AluOperation <= `OP_SLT;
                `SLTU: AluOperation <= `OP_SLTU;

                `SLL:  AluOperation <= `OP_SLL;
                `SRL:  AluOperation <= `OP_SRL;
                `SRA:  AluOperation <= `OP_SRA;

                `SLLV: AluOperation <= `OP_SLLV;
                `SRLV: AluOperation <= `OP_SRLV;
                `SRAV: AluOperation <= `OP_SRAV;

                `JR: begin
                    Regwrite <= 0;
                    Jmp <= 2'b10;
                end

                `JALR: begin
                    Jmp <= 2'b10;
                    RegDst <= 2'b10;
                    Regwrite <= 1;
                    DataC <= 1;
                end
            endcase
        end

        `addi:  begin Regwrite<=1; AluSrc<=1; AluOperation<=`OP_ADD; end
        `addiu: begin Regwrite<=1; AluSrc<=1; AluOperation<=`OP_ADDU; end
        `slti:  begin Regwrite<=1; AluSrc<=1; AluOperation<=`OP_SLT; end
        `sltiu: begin Regwrite<=1; AluSrc<=1; AluOperation<=`OP_SLTU; end
        `andi:  begin Regwrite<=1; AluSrc<=1; AluOperation<=`OP_AND; end
        `ori:   begin Regwrite<=1; AluSrc<=1; AluOperation<=`OP_OR; end
        `xori:  begin Regwrite<=1; AluSrc<=1; AluOperation<=`OP_XOR; end

        `lui: begin
            Regwrite <= 1;
            AluSrc <= 1;
            AluOperation <= `OP_LUI;
        end

        `lw: begin
            Regwrite<=1; MemRead<=1; MemtoReg<=1; AluSrc<=1;
            AluOperation<=`OP_ADD;
        end

        `sw: begin
            MemWrite<=1; AluSrc<=1; AluOperation<=`OP_ADD;
        end

        `beq: begin Branch<=1;   AluOperation<=`OP_SUB; end
        `bne: begin BranchNe<=1; AluOperation<=`OP_SUB; end

        `j:   begin Jmp<=2'b01; end
        `jal: begin Jmp<=2'b01; RegDst<=2'b10; Regwrite<=1; DataC<=1; end
        // `NOP: begin  end

    endcase
end

endmodule
