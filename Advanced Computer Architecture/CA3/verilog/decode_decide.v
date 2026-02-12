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


module decode_decide (
    input clk,
    input rst,

    // instruction
    input instruction_valid_D,
    input [4:0]   r1,
    input [4:0]   r2,
    input [4:0]   rd,
    input [5:0]   opcode,
    input         RegWrite,
    // register status
    input  [3:0]  P_index_p1,
    output [4:0]  regp1,
    input  [3:0]  P_index_p2,
    output [4:0]  regp2,

    output reg    update,
    output [4:0]  regdest,
    output [3:0]  P_index_wr,

    // read from register file
    input [31:0]   read_data1_reg,
    input [31:0]   read_data2_reg,

    // from CDBs
    input          mem_CDB_valid,
    input [2:0]    mem_CDB_id,
    input [31:0]   mem_CDB_value,

    input          int_CDB_valid,
    input [2:0]    int_CDB_id,
    input [31:0]   int_CDB_value,

    // from ROB
    input          rob_full,
    input          alloc_gnt,
    input [2:0]    alloc_tag,

    input [15:0]    dump_state,
    input [255:0]  dump_value,

    // to ROB
    output reg       alloc_req,
    output reg       alloc_S,
    output reg       alloc_ST,
    output reg       alloc_V,
    output reg [4:0] alloc_rd,

    // issue
    output reg       Pj,
    output reg       Pk,
    output     [2:0] id,
    output reg [2:0] Qj, 
    output reg [2:0] Qk,

    output reg [31:0] scrA,
    output reg [31:0] srcB,

    // stall
    input [1:0]     Jmp,
    input           Branch,
    input           BranchNe,


    input           Branch_E,
    input           BranchNe_E,
    input           int_valid_E,
    input           and_z_b,
    input [1:0]     Jmp_E,

    input           issue_full,
    output reg      valid_instruction,
    output          decode_stall,
    output          flush_ctrl
);

    // stall handling

    wire set_spec;
    wire clear_spec;
    wire taken_spec;
    reg speculation;

    always @(posedge clk, posedge rst) begin
        if(rst) 
            speculation <= 1'b0;
        else if(clear_spec)
            speculation <= 1'b0;
        else if(set_spec)
            speculation <= 1'b1;
    end

    assign set_spec = (instruction_valid_D == 1'b1 &&
                        ~(Jmp == 2'b00 &&
                        Branch == 1'b0 &&
                        BranchNe == 1'b0)) ? 
                        1'b1 : 1'b0;

    assign flush_ctrl = taken_spec & speculation;
    assign taken_spec = (int_valid_E  == 1'b1 && 
                          ~(and_z_b == 1'b0 &&
                          Jmp_E == 2'b00));
    assign clear_spec = taken_spec || (int_valid_E  == 1'b1 && (Branch_E || BranchNe_E));

    assign decode_stall = (rob_full == 1'b1 ||
                           issue_full == 1'b1 ||
                           (speculation == 1'b1 && clear_spec == 1'b0) ) ? 
                           1'b1 : 1'b0;

    // to ROB
    always @(*) begin
        alloc_req <= 0;
        alloc_S <= 0;
        alloc_ST <= 0;
        alloc_V <= 0;
        alloc_rd <= 0;
        valid_instruction <= 0;
        update <= 1'b0;

        if(decode_stall == 1'b0 && instruction_valid_D && flush_ctrl == 1'b0) begin
            alloc_req <= 1'b1; 
            alloc_ST <= (opcode == `sw);
            alloc_V <= RegWrite;
            update <= RegWrite;
            alloc_rd <= rd;
            valid_instruction <= 1'b1;
        end
        // else if(instruction_valid_D && (int_valid_E  == 1'b1 && (Branch_E || BranchNe_E)) && (and_z_b == 1'b0)) begin
        //     alloc_req <= 1'b1; 
        //     alloc_ST <= (opcode == `sw);
        //     alloc_V <= RegWrite;
        //     update <= RegWrite;
        //     alloc_rd <= rd;
        //     valid_instruction <= 1'b1;
        // end
    end
    assign id = alloc_tag;

    assign P_index_wr = {1'b1, alloc_tag};
    assign regdest = rd;
    // providing issue inputs

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

    assign regp1 = r1;
    assign regp2 = r2;

    // 3 : pending
    // 2 - 0 : index

    wire [1:0] stateP1;
    wire [1:0] stateP2;

    assign stateP1 = dump_state[(P_index_p1[2:0]<<1) + 1 -: 2];
    assign stateP2 = dump_state[(P_index_p2[2:0]<<1) + 1 -: 2];

    // source A
    always @(*) begin
        scrA <= read_data1_reg;
        Pj <= 1'b0;
        Qj <= 3'b000;
        if(re1_D) begin
            if(P_index_p1[3] == 1'b1) begin
                if(stateP1 == 2'b10) begin // hit in ROB
                    // scrA <= dump_value[(P_index_p1[2:0] << 5) + 31:P_index_p1[2:0] << 5];
                    scrA <= dump_value[(P_index_p1[2:0] << 5) + 31 -: 32]; 
                end
                else if(mem_CDB_valid == 1'b1 && mem_CDB_id == P_index_p1[2:0]) begin
                    scrA <= mem_CDB_value;
                end
                else if(int_CDB_valid == 1'b1 && int_CDB_id == P_index_p1[2:0]) begin
                    scrA <= int_CDB_value;
                end
                else begin
                    Pj <= 1'b1;
                    Qj <= P_index_p1[2:0];
                end
            end
        end
    end

    // source B
    always @(*) begin
        srcB <= read_data2_reg;
        Pk <= 1'b0;
        Qk <= 3'b000;
        if(re2_D) begin
            if(P_index_p2[3] == 1'b1) begin
                if(stateP2 == 2'b10) begin // hit in ROB
                    // srcB <= dump_value[(P_index_p2[2:0] << 5) + 31:P_index_p2[2:0] << 5];
                    srcB <= dump_value[(P_index_p2[2:0] << 5) + 31 -: 32];
                end
                else if(mem_CDB_valid == 1'b1 && mem_CDB_id == P_index_p2[2:0]) begin
                    srcB <= mem_CDB_value;
                end
                else if(int_CDB_valid == 1'b1 && int_CDB_id == P_index_p2[2:0]) begin
                    srcB <= int_CDB_value;
                end
                else begin
                    Pk <= 1'b1;
                    Qk <= P_index_p2[2:0];
                end
            end
        end
    end    

endmodule