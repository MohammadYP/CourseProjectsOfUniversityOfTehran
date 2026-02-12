// `define Free    3'b000
// `define Load1   3'b001
// `define Load2   3'b010
// `define Int1    3'b011
// `define Int2    3'b100
// `define Int3    3'b101

`define lw      6'b100011
`define sw      6'b101011

`define beq     6'b000100
`define bne     6'b000101

`define j       6'b000010
`define jal     6'b000011

module Issue (
    input           clk,
    input           rst,

    input [31:0]    inst,

    input           Pi,
    input           Pj,
    input           Pk,
 
    input [2:0]     id,

    input [2:0]     Qi,
    input [2:0]     Qj, 
    input [2:0]     Qk,

    input [31:0]    StoreData,
    input [31:0]    srcA,
    input [31:0]    scrB,

    // commands 
    input           Branch,
    input           BranchNe,
    input [1:0]     Jmp,
    input [25:0]    shl2_inst,
    input [31:0]    out_adder2,
    input [4:0]     AluOperation,

    input           MemRead,
    input           MemWrite, 

    // CDB
    input           mem_CDB_valid,
    input [2:0]     mem_CDB_id,
    input [31:0]    mem_CDB_value,

    input           int_CDB_valid,
    input [2:0]     int_CDB_id,
    input [31:0]    int_CDB_value,

    // control signal
    input valid_instruction,
    output issue_full,

    // mem pipe signals 
    output          mem_valid,
    output          mem_MemRead,
    output          mem_MemWrite,
    output [2:0]    mem_id,         
    output [31:0]   mem_srcA,
    output [31:0]   mem_scrB,
    output [31:0]   mem_store_data,

    // int pipe signals
    output          int_valid,
    output [2:0]    int_id,  
    output [4:0]    int_AluOperation,
    output [4:0]    int_shamt,
    output [31:0]   int_srcA,
    output [31:0]   int_scrB,

    input           int_Branch,
    input           int_BranchNe,
    input [1:0]     int_Jmp,
    input [25:0]    int_shl2_inst,
    input [31:0]    int_out_adder2
);

    // decode instruction type

    wire       mem_issue;
    wire       mem_buffer_full;
    reg        load_mem_buffer;

    wire       int_issue;
    wire       int_buffer_full;
    wire [1:0] int_issue_idx;
    reg        load_int_buffer;

    wire [5:0] opcode = inst[31:26];

    always @(*) begin
        load_mem_buffer = 1'b0;
        load_int_buffer = 1'b0;
        if(issue_full  == 1'b0 && valid_instruction == 1'b1) begin
            if(opcode == `lw || opcode == `sw) begin
                load_mem_buffer = 1'b1;
            end
            else begin
                load_int_buffer = 1'b1;
            end
        end
    end
    assign issue_full = int_buffer_full | (mem_buffer_full == 1'b1 && mem_issue == 1'b0); // *** maybe branch and jump
    
    // integer reservation station

    reg [153:0] IRS [0:2];

    task automatic load_new_irs_entry(
        input int idx
    );
    begin
        IRS[idx][70] <= 1'b1;
        IRS[idx][81:79] <= id;
        IRS[idx][76:71] <= opcode;
        IRS[idx][86:82] <= AluOperation;
        IRS[idx][91:87] <= inst[10:6]; // shamt
        IRS[idx][123:92] <= out_adder2;
        IRS[idx][149:124] <= shl2_inst;
        IRS[idx][151:150] <= Jmp;
        IRS[idx][152] <= BranchNe;
        IRS[idx][153] <= Branch;

        // Operand J
        if (Pj == 1'b0) begin
            IRS[idx][78] <= 1'b0;
            IRS[idx][69:38] <= srcA;
        end else begin
            IRS[idx][78] <= 1'b1;
            IRS[idx][5:3] <= Qj;
        end
        
        // Operand k
        if (Pk == 1'b0) begin
            IRS[idx][77] <= 1'b0;
            IRS[idx][37:6] <= scrB;
        end else begin
            IRS[idx][77] <= 1'b1;
            IRS[idx][2:0] <= Qk;
        end

    end
    endtask

    task automatic int_check_CDB(
        input int idx_src,
        input int idx_dest
    );
    begin
        if (IRS[idx_src][70] && mem_CDB_valid) begin // busy & check mem pipe
            // Qj (base)
            if (IRS[idx_src][78] && IRS[idx_src][5:3] == mem_CDB_id) begin
                IRS[idx_dest][78] <= 1'b0;
                IRS[idx_dest][69:38] <= mem_CDB_value;
            end
            // Qk (offset)
            if (IRS[idx_src][77] && IRS[idx_src][2:0] == mem_CDB_id) begin
                IRS[idx_dest][77] <= 1'b0;
                IRS[idx_dest][37:6] <= mem_CDB_value;
            end
        end

        if (IRS[idx_src][70] && int_CDB_valid) begin // busy & check int pipe
            // Qj (base)
            if (IRS[idx_src][78] && IRS[idx_src][5:3] == int_CDB_id) begin
                IRS[idx_dest][78] <= 1'b0;
                IRS[idx_dest][69:38] <= int_CDB_value;
            end
            // Qk (offset)
            if (IRS[idx_src][77] && IRS[idx_src][2:0] == int_CDB_id) begin
                IRS[idx_dest][77] <= 1'b0;
                IRS[idx_dest][37:6] <= int_CDB_value;
            end
        end
    end
    endtask


    // Branch       : 153
    // BranchNe     : 152
    // Jmp          : 151 - 150
    // shl2_inst    : 149 - 124
    // out_adder2   : 123 -  92
    // shamt        : 91  -  87
    // AluOperation : 86  -  82 
    // id           : 81  -  79
    // Pj           : 78
    // Pk           : 77
    // opcode       : 76  -  71
    // busy         : 70
    // Vj           : 69  -  38
    // Vk           : 37  -   6
    // Qj           : 5   -   3   SrcA
    // Qk           : 2   -   0   ScrB

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            IRS[0] = 0;
            IRS[1] = 0;
            IRS[2] = 0;
        end
        else begin
            // check for cdb
            int_check_CDB(0, 0);
            int_check_CDB(1, 1);
            int_check_CDB(2, 2);

            if(load_int_buffer == 1'b1 ) begin // load
                if(IRS[0][70] == 1'b0) begin
                    load_new_irs_entry(0);
                end
                else if(IRS[1][70] == 1'b0) begin
                    load_new_irs_entry(1);
                end
                else if(IRS[2][70] == 1'b0) begin
                    load_new_irs_entry(2);
                end
            end
            if(int_issue == 1'b1) begin // issue
                if(IRS[0][70] == 1'b1 && IRS[0][78] == 1'b0 && IRS[0][77] == 1'b0) begin
                    IRS[0][70] <= 1'b0;
                end
                else if(IRS[1][70] == 1'b1 && IRS[1][78] == 1'b0 && IRS[1][77] == 1'b0) begin
                    IRS[1][70] <= 1'b0;
                end
                else if(IRS[2][70] == 1'b1 && IRS[2][78] == 1'b0 && IRS[2][77] == 1'b0) begin
                    IRS[2][70] <= 1'b0;
                end
            end
        end
    end

    assign int_buffer_full = IRS[0][70] & IRS[1][70] & IRS[2][70];


    // memory reservation station

    reg [119:0] MRS [0:1];

    task automatic load_new_mrs_entry(
        input int idx
    );
    begin
        MRS[idx][105] <= 1'b1;
        MRS[idx][117:115] <= id;
        MRS[idx][111:106] <= opcode;
        MRS[idx][118] <= MemWrite;
        MRS[idx][119] <= MemRead;

        // Operand k for sw value
        MRS[idx][112] <= 1'b0;
        MRS[idx][40:9] <= scrB;

        // Operand J
        if (Pj == 1'b0) begin
            MRS[idx][113] <= 1'b0;
            MRS[idx][72:41] <= srcA;
        end 
        else begin
            MRS[idx][113] <= 1'b1;
            MRS[idx][5:3] <= Qj;
        end

        // Operand I (only for sw)
        if (opcode == `sw) begin
            if (Pi == 1'b0) begin
                MRS[idx][114] <= 1'b0;
                MRS[idx][104:73] <= StoreData;
            end 
            else begin
                MRS[idx][114] <= 1'b1;
                MRS[idx][8:6] <= Qi;
            end
        end 
        else begin
            MRS[idx][114] <= 1'b0;
        end
    end
    endtask

    task automatic mem_check_CDB(
        input int idx_src,
        input int idx_dest
    );
    begin
        if (MRS[idx_src][105] && mem_CDB_valid) begin // busy & check mem pipe
            // Qi (dest)
            if (MRS[idx_src][114] && MRS[idx_src][8:6] == mem_CDB_id) begin
                MRS[idx_dest][114] <= 1'b0;
                MRS[idx_dest][104:73] <= mem_CDB_value;
            end
            // Qj (base)
            if (MRS[idx_src][113] && MRS[idx_src][5:3] == mem_CDB_id) begin
                MRS[idx_dest][113] <= 1'b0;
                MRS[idx_dest][72:41] <= mem_CDB_value;
            end
            // Qk (offset)
            if (MRS[idx_src][112] && MRS[idx_src][2:0] == mem_CDB_id) begin
                MRS[idx_dest][112] <= 1'b0;
                MRS[idx_dest][40:9] <= mem_CDB_value;
            end
        end

        if (MRS[idx_src][105] && int_CDB_valid) begin // busy & check int pipe
            // Qi (dest)
            if (MRS[idx_src][114] && MRS[idx_src][8:6] == int_CDB_id) begin
                MRS[idx_dest][114] <= 1'b0;
                MRS[idx_dest][104:73] <= int_CDB_value;
            end
            // Qj (base)
            if (MRS[idx_src][113] && MRS[idx_src][5:3] == int_CDB_id) begin
                MRS[idx_dest][113] <= 1'b0;
                MRS[idx_dest][72:41] <= int_CDB_value;
            end
            // Qk (offset)
            if (MRS[idx_src][112] && MRS[idx_src][2:0] == int_CDB_id) begin
                MRS[idx_dest][112] <= 1'b0;
                MRS[idx_dest][40:9] <= int_CDB_value;
            end
        end
    end
    endtask
    // MemRead  : 119
    // MemWrite : 118
    // id       : 117 - 115
    // Pi       : 114
    // Pj       : 113
    // Pk       : 112
    // opcode   : 111 - 106
    // busy     : 105
    // Vi       : 104 -  73
    // Vj       : 72  -  41
    // Vk       : 40  -   9
    // Qi       : 8   -   6   dest
    // Qj       : 5   -   3   base register
    // Qk       : 2   -   0   offset(imm)

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1) begin
            MRS[0] <= 0;
            MRS[1] <= 0;
        end
        else begin
            
            if(load_mem_buffer == 1'b1 && mem_issue == 1'b0) begin // just load
                if(MRS[0][105] == 1'b0) begin
                    load_new_mrs_entry(0);
                end
                else if(MRS[1][105] == 1'b0) begin
                    mem_check_CDB(0,0);
                    load_new_mrs_entry(1);
                end
            end
            else if(load_mem_buffer == 1'b1 && mem_issue == 1'b1) begin // load and issue
                if(MRS[0][105] == 1'b1 && MRS[1][105] == 1'b1) begin // both full
                    MRS[0] <= MRS[1];
                    mem_check_CDB(1,0);
                    load_new_mrs_entry(1);
                end
                else begin // only one is full
                    load_new_mrs_entry(0);
                end
            end
            else if(load_mem_buffer == 1'b0 && mem_issue == 1'b1) begin // just issue
                MRS[0] <= MRS[1];
                MRS[1] <= 0;
                mem_check_CDB(1,0);
            end
            else begin
                mem_check_CDB(0,0);
                mem_check_CDB(1,1);
            end
        end
    end

    assign mem_buffer_full = MRS[0][105] & MRS[1][105];

    // issue logic

    assign mem_issue = (MRS[0][105] == 1'b1 &&
                        (MRS[0][111:106] != `sw || MRS[0][114] == 1'b0) &&
                        MRS[0][113] == 1'b0 &&
                        MRS[0][112] == 1'b0) ?
                        1'b1 : 1'b0; 

    assign int_issue = (IRS[0][70] && IRS[0][78] == 1'b0 && IRS[0][77] == 1'b0) ? 1'b1 :
                       (IRS[1][70] && IRS[1][78] == 1'b0 && IRS[1][77] == 1'b0) ? 1'b1 : 
                       (IRS[2][70] && IRS[2][78] == 1'b0 && IRS[2][77] == 1'b0) ? 1'b1 : 
                       1'b0;
    
    assign int_issue_idx = (IRS[0][70] && IRS[0][78] == 1'b0 && IRS[0][77] == 1'b0) ? 2'b00 :
                           (IRS[1][70] && IRS[1][78] == 1'b0 && IRS[1][77] == 1'b0) ? 2'b01 : 
                           (IRS[2][70] && IRS[2][78] == 1'b0 && IRS[2][77] == 1'b0) ? 2'b10 : 
                           2'b00;

    assign mem_valid = mem_issue;
    assign mem_MemRead = MRS[0][119];
    assign mem_MemWrite = MRS[0][118];
    assign mem_id = MRS[0][117:115];
    assign mem_srcA = MRS[0][72:41];
    assign mem_scrB = MRS[0][40:9];
    assign mem_store_data = MRS[0][104:73];

    assign int_valid = int_issue;
    assign int_id = IRS[int_issue_idx][81:79];
    assign int_AluOperation = IRS[int_issue_idx][86:82];
    assign int_shamt = IRS[int_issue_idx][91:87];
    assign int_srcA = IRS[int_issue_idx][69:38];
    assign int_scrB = IRS[int_issue_idx][37:6];
    assign int_Branch = IRS[int_issue_idx][153];
    assign int_BranchNe = IRS[int_issue_idx][152];
    assign int_Jmp = IRS[int_issue_idx][151:150];
    assign int_shl2_inst = IRS[int_issue_idx][149:124];
    assign int_out_adder2 = IRS[int_issue_idx][123:92];
    
endmodule