`timescale 1ns/1ns

module data_path(
    input clk,
    input rst,
    input [1:0] RegDst,
    input [1:0] Jmp,
    input DataC,
    input RegWrite,
    input AluSrc,
    input Branch,
    input BranchNe,
    input MemRead,
    input MemWrite,
    input MemtoReg,
    input [4:0] AluOperation,
    output [5:0] func,
    output [5:0] opcode
);

    wire [31:0] in_pc, out_pc, instruction;
    wire [31:0] write_data_reg,read_data1_reg,read_data2_reg;
    wire [31:0] pc_adder,mem_read_data,inst_extended;
    wire [31:0] alu_input2,alu_result;
    wire [31:0] read_data_mem,shifted_inst_extended;
    wire [31:0] out_adder2,out_branch,shamt_extended;
    wire [4:0] write_reg;
    wire [25:0] shl2_inst;

    wire and_z_b,zero;
    wire flush_ctrl;

    wire [31:0] pc_adder_W;
    wire [31:0] out_adder2_W;
    wire [31:0] alu_result_W;
    wire [31:0] read_data_mem_W;
    wire zero_W, MemtoReg_W, BranchNe_W, Branch_W, DataC_W;
    wire [1:0] Jmp_W;
    wire RegWrite_W;
    wire [4:0] write_reg_w;
    wire [31:0] read_data1_reg_W;
    wire [25:0] shl2_inst_W;

    wire stall;
    wire [31:0] instruction_E;
    wire [31:0] pc_adder_E;
    wire [31:0] out_adder2_E;
    wire [31:0] read_data1_reg_E;
    wire [31:0] read_data2_reg_E;
    wire [31:0] alu_input2_E;
    wire MemtoReg_E;
    wire MemWrite_E;
    wire MemRead_E;
    wire BranchNe_E;
    wire Branch_E;
    wire DataC_E;
    wire [4:0] write_reg_E;
    wire [1:0] Jmp_E;
    wire RegWrite_E;
    wire [4:0] AluOperation_E;
    wire [25:0] shl2_inst_E;

    wire         alloc_req;
    wire         alloc_S;
    wire         alloc_ST;
    wire         alloc_V;
    wire [4:0]   alloc_rd;
    wire         alloc_gnt;
    wire [2:0]   alloc_tag;
    wire         mem_CDB_valid;
    wire [2:0]   mem_CDB_id;
    wire [31:0]  mem_CDB_value;
    wire         int_CDB_valid;
    wire [2:0]   int_CDB_id;
    wire [31:0]  int_CDB_value;
    wire         commit_fire;
    wire [2:0]   commit_tag;
    wire [1:0]   commit_state;
    wire         commit_S;
    wire         commit_ST;
    wire         commit_V;
    wire [4:0]   commit_rd;
    wire [31:0]  commit_value;
    wire [2:0]   head_ptr;
    wire [2:0]   tail_ptr;
    wire         empty;
    wire         full;
    wire [3:0]   count_out;
    wire [15:0]  dump_state;
    wire [7:0]   dump_S;
    wire [7:0]   dump_ST;
    wire [7:0]   dump_V;
    wire [39:0]  dump_rd;
    wire [255:0] dump_value;

    wire [4:0]   regp1;
    wire [3:0]   P_index_p1;
    wire [4:0]   regp2;
    wire [3:0]   P_index_p2;
    wire         update;
    wire [4:0]   regdest;
    wire [3:0]   P_index_wr;
    wire         clear;
    wire [4:0]   regclear;
    wire [3:0]   checkP_index;

    wire        int_valid_E;
    wire [2:0]  int_id_E;
    wire [4:0]  int_AluOperation_E;
    wire [4:0]  int_shamt_E;
    wire [31:0] int_srcA_E;
    wire [31:0] int_scrB_E;

// Fetch stage

pc PC(
    .clk(clk),
    .rst(rst),
    .stall(stall), // ***
    .in(in_pc),
    .out(out_pc)
);

adder adder_pc(
    .data1(out_pc),
    .data2(32'd4),
    .sum(pc_adder)
);

mux3_to_1 #(32) mux_jmp(
    .data1(out_branch),
    .data2({pc_adder[31:26], shl2_inst_E}), // jump
    .data3(int_srcA_E),
    .sel(Jmp_E),
    .out(in_pc)
);

assign and_z_b =(int_valid_E == 1'b1 && (zero & Branch_E) | (~zero & BranchNe_E));

mux2_to_1 #(32) mux_branch(
    .data1(pc_adder),
    .data2(out_adder2_E),
    .sel(and_z_b),
    .out(out_branch)
);

inst_memory IM(
    .clk(clk),
    .rst(rst),
    .adr(out_pc),
    .instruction(instruction)
);

// STAGE Fetch - Decode

wire instruction_valid_D;
wire [31:0] srcA;
wire [31:0] srcB;
wire [31:0] pc_adder_D;
wire [31:0] instruction_D;

PipeReg #(
    .SIZE(65)
) stage_FD (
    .clk(clk),
    .rst(rst),
    .flush(flush_ctrl),
    .stall(stall),
    .in({pc_adder, instruction, 1'b1}),
    .out({pc_adder_D, instruction_D, instruction_valid_D})
);

// STAGE decode

assign func   = instruction_D[5:0];
assign opcode = instruction_D[31:26];

mux3_to_1 #5 mux_rd(
    .data1(instruction_D[20:16]),
    .data2(instruction_D[15:11]),
    .data3(5'd31),
    .sel(RegDst),
    .out(write_reg)
);

reg_file RF(
    .clk(clk),
    .rst(rst),
    .RegWrite(commit_fire & commit_V), 
    .read_reg1(instruction_D[25:21]),
    .read_reg2(instruction_D[20:16]),
    .write_reg(commit_rd), 
    .write_data(commit_value),
    .read_data1(read_data1_reg),
    .read_data2(read_data2_reg)
);

sign_extension SE(
    .primary(instruction_D[15:0]),
    .extended(inst_extended)
);

shl2 #26 shl_j(
    .adr(instruction_D[25:0]),
    .sh_adr(shl2_inst)
);

shl2 #32 shl_branch(
    .adr(inst_extended),
    .sh_adr(shifted_inst_extended)
);

adder adder_branch(
    .data1(shifted_inst_extended),
    .data2(pc_adder_D),
    .sum(out_adder2)
);

assign shamt_extended = {27'd0, instruction_D[10:6]};

registerStatus rs(
    .clk(clk),
    .rst(rst),
    .regp1(regp1),
    .P_index_p1(P_index_p1),
    .regp2(regp2),
    .P_index_p2(P_index_p2),
    .update(update),
    .regdest(regdest),
    .P_index_wr(P_index_wr),
    .clear(clear),
    .regclear(regclear),
    .checkP_index(checkP_index)
);

    assign clear = (checkP_index[2:0] ==  commit_tag) ? commit_fire & commit_V : 1'b0;
    assign regclear = commit_rd;

    wire issue_full;
    wire decode_stall;
    wire valid_instruction;

    wire        Pj_D;
    wire        Pk_D;
    wire [2:0]  id_D;
    wire [2:0]  Qj_D;
    wire [2:0]  Qk_D;
    wire [31:0] scrA_D;
    wire [31:0] srcB_D;

    wire        Pi_I;
    wire        Pj_I;
    wire        Pk_I;
    wire [2:0]  id_I;
    wire [2:0]  Qi_I;
    wire [2:0]  Qj_I;
    wire [2:0]  Qk_I;
    wire [31:0] scrA_I;
    wire [31:0] srcB_I;

    decode_decide dd(
        .clk(clk),
        .rst(rst),
        .instruction_valid_D(instruction_valid_D),
        .r1(instruction_D[25:21]),
        .r2(instruction_D[20:16]),
        .rd(write_reg),
        .opcode(opcode),
        .RegWrite(RegWrite),
        .P_index_p1(P_index_p1),
        .regp1(regp1),
        .P_index_p2(P_index_p2),
        .regp2(regp2),
        .update(update),
        .regdest(regdest),
        .P_index_wr(P_index_wr),
        .read_data1_reg(read_data1_reg),
        .read_data2_reg(read_data2_reg),
        .mem_CDB_valid(mem_CDB_valid),
        .mem_CDB_id(mem_CDB_id),
        .mem_CDB_value(mem_CDB_value),
        .int_CDB_valid(int_CDB_valid),
        .int_CDB_id(int_CDB_id),
        .int_CDB_value(int_CDB_value),
        .rob_full(full),
        .alloc_gnt(alloc_gnt),
        .alloc_tag(alloc_tag),
        .dump_state(dump_state),
        .dump_value(dump_value),
        .alloc_req(alloc_req),
        .alloc_S(alloc_S),
        .alloc_ST(alloc_ST),
        .alloc_V(alloc_V),
        .alloc_rd(alloc_rd),
        .Pj(Pj_D),
        .Pk(Pk_D),
        .id(id_D),
        .Qj(Qj_D),
        .Qk(Qk_D),
        .scrA(scrA_D),
        .srcB(srcB_D),
        .Jmp(Jmp),
        .Branch(Branch),
        .BranchNe(BranchNe),
        .Branch_E(Branch_E),
        .BranchNe_E(BranchNe_E),
        .int_valid_E(int_valid_E),
        .and_z_b(and_z_b),
        .Jmp_E(Jmp_E),
        .issue_full(issue_full),
        .valid_instruction(valid_instruction),
        .decode_stall(decode_stall),
        .flush_ctrl(flush_ctrl)
    );

    assign stall = issue_full | decode_stall;

    assign Pi_I = Pk_D;
    assign Pj_I = Pj_D;
    assign Pk_I = (AluSrc == 1'b1) ? 1'b0 : Pk_D;
    assign id_I = id_D;
    assign Qi_I = Qk_D;
    assign Qj_I = Qj_D;
    assign Qk_I = Qk_D;
    assign scrA_I = scrA_D;
    assign srcB_I = (AluSrc == 1'b1) ? inst_extended : srcB_D;

    // issue 

    wire        mem_MemRead;
    wire        mem_MemWrite;
    wire        mem_valid;
    wire [2:0]  mem_id;
    wire [31:0] mem_srcA;
    wire [31:0] mem_scrB;
    wire [31:0] mem_store_data;

    wire        int_valid;
    wire [2:0]  int_id;
    wire [4:0]  int_AluOperation;
    wire [4:0]  int_shamt;
    wire [31:0] int_srcA;
    wire [31:0] int_scrB;

    wire        int_Branch;
    wire        int_BranchNe;
    wire [1:0]  int_Jmp;
    wire [25:0] int_shl2_inst;
    wire [31:0] int_out_adder2;


    Issue issue(
        .clk(clk),
        .rst(rst),
        .inst(instruction_D),
        .Pi(Pi_I),
        .Pj(Pj_I),
        .Pk(Pk_I),
        .id(id_I),
        .Qi(Qi_I),
        .Qj(Qj_I),
        .Qk(Qk_I),
        .StoreData(srcB_D),
        .srcA(scrA_I),
        .scrB(srcB_I),
        .Branch(Branch),
        .BranchNe(BranchNe),
        .Jmp(Jmp),
        .shl2_inst(shl2_inst),
        .out_adder2(out_adder2),
        .AluOperation(AluOperation),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .mem_CDB_valid(mem_CDB_valid),
        .mem_CDB_id(mem_CDB_id),
        .mem_CDB_value(mem_CDB_value),
        .int_CDB_valid(int_CDB_valid),
        .int_CDB_id(int_CDB_id),
        .int_CDB_value(int_CDB_value),
        .valid_instruction(valid_instruction),
        .issue_full(issue_full),
        .mem_MemRead(mem_MemRead),
        .mem_MemWrite(mem_MemWrite),
        .mem_valid(mem_valid),
        .mem_id(mem_id),
        .mem_srcA(mem_srcA),
        .mem_scrB(mem_scrB),
        .mem_store_data(mem_store_data),
        .int_valid(int_valid),
        .int_id(int_id),
        .int_AluOperation(int_AluOperation),
        .int_shamt(int_shamt),
        .int_srcA(int_srcA),
        .int_scrB(int_scrB),
        .int_Branch(int_Branch),
        .int_BranchNe(int_BranchNe),
        .int_Jmp(int_Jmp),
        .int_shl2_inst(int_shl2_inst),
        .int_out_adder2(int_out_adder2)
    );

    // STAGE Issue - Exe (int)

    PipeReg #(
        .SIZE(140)
    ) stage_IE (
        .clk(clk),
        .rst(rst),
        .flush(1'b0), 
        .stall(1'b0),
        .in({int_valid, int_id, int_AluOperation, // 1 + 3 + 5 = 9
             int_shamt, int_srcA, int_scrB, // 5 + 32 + 32 = 69
             int_Branch, int_BranchNe, int_Jmp, // 1 + 1 + 2 = 4
             int_shl2_inst, int_out_adder2}), // 26 + 32 = 58
        .out({int_valid_E, int_id_E, int_AluOperation_E, 
              int_shamt_E, int_srcA_E, int_scrB_E,
              Branch_E, BranchNe_E, Jmp_E,
              shl2_inst_E, out_adder2_E}) 
    );

    // Exe (int)

    ALU aluCore(
        .A(int_srcA_E),
        .B(int_scrB_E),
        .shamt(int_shamt_E),
        .AluOperation(int_AluOperation_E),
        .Result(alu_result),
        .Zero(zero)
    );

    // STAGE Exe(int) - WB

    PipeReg #(
        .SIZE(36)
    ) stage_EW (
        .clk(clk),
        .rst(rst),
        .flush(1'b0), 
        .stall(1'b0),
        .in({int_valid_E, int_id_E, alu_result}), // 1 + 3 + 32
        .out({int_CDB_valid, int_CDB_id, int_CDB_value})
    );

    // STAGE Issue - Mem

    wire        mem_MemRead_M;
    wire        mem_MemWrite_M;
    wire        mem_valid_M;
    wire [2:0]  mem_id_M;
    wire [31:0] mem_srcA_M;
    wire [31:0] mem_scrB_M;
    wire [31:0] mem_store_data_M;

    PipeReg #(
        .SIZE(102)
    ) stage_IM (
        .clk(clk),
        .rst(rst),
        .flush(1'b0), 
        .stall(1'b0),
        .in({mem_MemRead, mem_MemWrite, mem_valid, mem_id, 
             mem_srcA, mem_scrB, mem_store_data}),
        .out({mem_MemRead_M, mem_MemWrite_M, mem_valid_M, mem_id_M, // 1 + 1 + 1 + 3 = 6
             mem_srcA_M, mem_scrB_M, mem_store_data_M}) // 32 + 32 + 32 = 96
    );

    // memory

    MemPipe MP(
        .clk(clk),
        .rst(rst),
        .mem_MemRead_M(mem_MemRead_M),
        .mem_MemWrite_M(mem_MemWrite_M), 
        .mem_valid_M(mem_valid_M),
        .mem_id_M(mem_id_M),
        .mem_srcA_M(mem_srcA_M),
        .mem_scrB_M(mem_scrB_M),
        .mem_store_data_M(mem_store_data_M),
        .mem_CDB_valid(mem_CDB_valid),
        .mem_CDB_id(mem_CDB_id),
        .mem_CDB_value(mem_CDB_value)
    );

    // wb 

    ROB rob(
        .clk(clk),
        .rst(rst),
        .alloc_req(alloc_req),
        .alloc_S(alloc_S),
        .alloc_ST(alloc_ST),
        .alloc_V(alloc_V),
        .alloc_rd(alloc_rd),
        .alloc_gnt(alloc_gnt),
        .alloc_tag(alloc_tag),
        .wb0_valid(mem_CDB_valid),
        .wb0_tag(mem_CDB_id),
        .wb0_data(mem_CDB_value),
        .wb1_valid(int_CDB_valid),
        .wb1_tag(int_CDB_id),
        .wb1_data(int_CDB_value),
        .commit_fire(commit_fire),
        .commit_tag(commit_tag),
        .commit_state(commit_state),
        .commit_S(commit_S),
        .commit_ST(commit_ST),
        .commit_V(commit_V),
        .commit_rd(commit_rd),
        .commit_value(commit_value),
        .head_ptr(head_ptr),
        .tail_ptr(tail_ptr),
        .empty(empty),
        .full(full),
        .count_out(count_out),
        .dump_state(dump_state),
        .dump_S(dump_S),
        .dump_ST(dump_ST),
        .dump_V(dump_V),
        .dump_rd(dump_rd),
        .dump_value(dump_value)
    );

endmodule
