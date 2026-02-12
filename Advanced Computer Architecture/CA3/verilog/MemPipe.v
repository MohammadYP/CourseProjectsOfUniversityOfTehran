module MemPipe(
    input clk,
    input rst,
    input mem_MemRead_M, 
    input mem_MemWrite_M, 
    input mem_valid_M, 
    input [2:0] mem_id_M, 
    input [31:0] mem_srcA_M, 
    input [31:0] mem_scrB_M, 
    input [31:0] mem_store_data_M,

    output mem_CDB_valid,
    output [2:0] mem_CDB_id,
    output [31:0] mem_CDB_value
);

wire mem_MemRead_M2;
wire mem_MemWrite_M2;
wire mem_valid_M2;
wire [2:0] mem_id_M2;
wire [31:0] MEM_address;
wire [31:0] MEM_address_M2;
wire [31:0] mem_store_data_M2;
wire [31:0] mem_CDB_value_M2;

assign MEM_address = mem_srcA_M + mem_scrB_M;

PipeReg #(
    .SIZE(70)
) stage_IM (
    .clk(clk),
    .rst(rst),
    .flush(1'b0), 
    .stall(1'b0),
    .in({mem_MemRead_M, mem_MemWrite_M, mem_valid_M, mem_id_M,
         MEM_address,mem_store_data_M}),
    .out({mem_MemRead_M2, mem_MemWrite_M2, mem_valid_M2, mem_id_M2, // 1 + 1 + 1 + 3 = 6
         MEM_address_M2, mem_store_data_M2}) // 32 + 32  = 64
);


data_memory DM(
    .clk(clk),
    .rst(rst),
    .mem_read(mem_MemRead_M2 & mem_valid_M2),
    .mem_write(mem_MemWrite_M2 & mem_valid_M2),
    .adr(MEM_address_M2),
    .write_data(mem_store_data_M2),
    .read_data(mem_CDB_value_M2),
    .out1(),
    .out2()
);

PipeReg #(
    .SIZE(36)
) stage_IM2 (
    .clk(clk),
    .rst(rst),
    .flush(1'b0), 
    .stall(1'b0),
    .in({mem_valid_M2, mem_id_M2, mem_CDB_value_M2}), // 1 + 3 + 32
    .out({mem_CDB_valid, mem_CDB_id, mem_CDB_value})
);

endmodule