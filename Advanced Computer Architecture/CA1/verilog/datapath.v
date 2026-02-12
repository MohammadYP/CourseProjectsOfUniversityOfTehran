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
    output [5:0] opcode,
    output [31:0] out1,
    output [31:0] out2
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


// Fetch stage

pc PC(
    .clk(clk),
    .rst(rst),
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
    .data2({pc_adder[31:26], shl2_inst_W}),
    .data3(read_data1_reg_W),
    .sel(Jmp_W),
    .out(in_pc)
);

assign and_z_b = (zero_W & Branch_W) | (~zero_W & BranchNe_W);

mux2_to_1 #(32) mux_branch(
    .data1(pc_adder),
    .data2(out_adder2_W),
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

wire [31:0] pc_adder_D;
wire [31:0] instruction_D;

PipeReg #(
    .SIZE(64)
) stage_FD (
    .clk(clk),
    .rst(rst),
    .in({pc_adder, instruction}),
    .out({pc_adder_D, instruction_D})
);

// Decode 

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
    .RegWrite(RegWrite_W),
    .read_reg1(instruction_D[25:21]),
    .read_reg2(instruction_D[20:16]),
    .write_reg(write_reg_w),
    .write_data(write_data_reg), 
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


mux2_to_1 #(32) mux_alu_input(
    .data1(read_data2_reg),
    .data2(inst_extended),
    .sel(AluSrc),
    .out(alu_input2)
);



// mux3_to_1 #(32) mux_alu_input(
//     .data1(read_data2_reg),
//     .data2(inst_extended),
//     .data3(read_data2_reg),
//     .sel({(AluOperation==5'd10)||(AluOperation==5'd11)||(AluOperation==5'd12), AluSrc}),
//     .out(alu_input2)
// );

// Stage Decode - Exe

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

    PipeReg #(
        .SIZE(237)
    ) stage_DE (
        .clk(clk),
        .rst(rst),
        .in({RegWrite, out_adder2, alu_input2, read_data1_reg, read_data2_reg, // 1 + 32 + 32 + 32 + 32 = 129
             MemtoReg, MemWrite, MemRead, BranchNe, Branch, DataC, shl2_inst, // 1 + 1 + 1 + 1 + 1 + 1 + 26 = 32
             Jmp, AluOperation, pc_adder_D, instruction_D, write_reg}), // 2 + 5 + 32 + 32 + 5 = 76
        .out({RegWrite_E, out_adder2_E, alu_input2_E, read_data1_reg_E, read_data2_reg_E,
              MemtoReg_E, MemWrite_E, MemRead_E, BranchNe_E, Branch_E, DataC_E, shl2_inst_E,
              Jmp_E, AluOperation_E, pc_adder_E, instruction_E, write_reg_E})
    );

// Exe

    ALU aluCore(
        .A(read_data1_reg_E),
        .B(alu_input2_E),
        .shamt(instruction_E[10:6]),
        .AluOperation(AluOperation_E),
        .Result(alu_result),
        .Zero(zero)
    );

// Stage Exe - Mem

    wire zero_M, MemtoReg_M, MemWrite_M,
         MemRead_M, BranchNe_M, Branch_M,
         DataC_M, RegWrite_M;
    wire [1:0] Jmp_M;
    wire [4:0] write_reg_M;
    wire [31:0] alu_result_M;
    wire [31:0] out_adder2_M;
    wire [31:0] read_data2_reg_M;
    wire [31:0] pc_adder_M;
    wire [31:0] read_data1_reg_M;
    wire [25:0] shl2_inst_M;

    PipeReg #(
        .SIZE(201)
    ) stage_EM (
        .clk(clk),
        .rst(rst),
        .in({RegWrite_E, out_adder2_E, read_data2_reg_E, alu_result, zero, MemtoReg_E, MemWrite_E, // 1 + 32 + 32 + 32 + 1 + 1 + 1 = 100
              MemRead_E, BranchNe_E, Branch_E, DataC_E, Jmp_E, pc_adder_E, write_reg_E, read_data1_reg_E, shl2_inst_E}),  // 1 + 1 + 1 + 1 + 2 + 32 + 5 + 32 + 26 = 101
        .out({RegWrite_M, out_adder2_M, read_data2_reg_M, alu_result_M, zero_M, MemtoReg_M, MemWrite_M,
              MemRead_M, BranchNe_M, Branch_M, DataC_M, Jmp_M, pc_adder_M, write_reg_M, read_data1_reg_M, shl2_inst_M})
    );

// Mem

data_memory DM(
    .clk(clk),
    .rst(rst),
    .mem_read(MemRead_M),
    .mem_write(MemWrite_M),
    .adr(alu_result_M),
    .write_data(read_data2_reg_M),
    .read_data(read_data_mem),
    .out1(out1),
    .out2(out2)
);

// Stage Mem - WB

    PipeReg #(
        .SIZE(199)
    ) stage_MW (
        .clk(clk),
        .rst(rst),
        .in({RegWrite_M, read_data_mem, alu_result_M, out_adder2_M, zero_M, read_data1_reg_M, // 1 + 32 + 32 + 32 + 1 + 32 = 130
             MemtoReg_M, BranchNe_M, Branch_M, DataC_M, Jmp_M, pc_adder_M, write_reg_M, shl2_inst_M}), // 1 + 1 + 1 + 1 + 2 + 32 + 5 + 26 = 69
        .out({RegWrite_W, read_data_mem_W, alu_result_W, out_adder2_W, zero_W, read_data1_reg_W,
             MemtoReg_W, BranchNe_W, Branch_W, DataC_W, Jmp_W, pc_adder_W, write_reg_w, shl2_inst_W})
    );

// WB

mux2_to_1 #32 mux_mem(
    .data1(alu_result_W),
    .data2(read_data_mem_W),
    .sel(MemtoReg_W),
    .out(mem_read_data)
);

mux2_to_1 #32 mux_regData(
    .data1(mem_read_data),
    .data2(pc_adder_W),
    .sel(DataC_W),
    .out(write_data_reg)
);

endmodule
