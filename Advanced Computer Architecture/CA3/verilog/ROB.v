
module ROB (
    input         clk,
    input         rst,

    // Allocate (Decode stage)
    input         alloc_req,
    input         alloc_S,
    input         alloc_ST,
    input         alloc_V,
    input  [4:0]  alloc_rd,
    output        alloc_gnt,
    output [2:0]  alloc_tag,

    // WB ports
    input         wb0_valid,
    input  [2:0]  wb0_tag,
    input  [31:0] wb0_data,

    input         wb1_valid,
    input  [2:0]  wb1_tag,
    input  [31:0] wb1_data,

    // Commit info
    output        commit_fire,
    output [2:0]  commit_tag,
    output [1:0]  commit_state,
    output        commit_S,
    output        commit_ST,
    output        commit_V,
    output [4:0]  commit_rd,
    output [31:0] commit_value,

    // Debug
    output [2:0]  head_ptr,
    output [2:0]  tail_ptr,
    output        empty,
    output        full,
    output [3:0]  count_out,

    output [15:0]  dump_state,
    output [7:0]   dump_S,
    output [7:0]   dump_ST,
    output [7:0]   dump_V,
    output [39:0]  dump_rd,
    output [255:0] dump_value
);

    // -----------------------------
    // localparams
    // -----------------------------
    localparam [1:0] ROB_FREE = 2'b00;
    localparam [1:0] ROB_PEND = 2'b01;
    localparam [1:0] ROB_FIN  = 2'b10;

    // -----------------------------
    // cntrl,dp wires
    // -----------------------------
    wire        alloc_we_int;
    wire [2:0]  alloc_tag_int;

    wire        free_we;
    wire [2:0]  free_tag;

    wire        head_finished;

    // Read-port for head (commit check)
    wire [1:0]  r0_state;
    wire        r0_S;
    wire        r0_ST;
    wire        r0_V;
    wire [4:0]  r0_rd;
    wire [31:0] r0_value;

    // Read-port for debug
    wire [1:0]  r1_state;
    wire        r1_S;
    wire        r1_ST;
    wire        r1_V;
    wire [4:0]  r1_rd;
    wire [31:0] r1_value;

    // -----------------------------
    // Ctrl (head/tail/count)
    // commit_allow = 1
    // -----------------------------
    rob_ctrl8 u_ctrl (
        .clk(clk),
        .rst(rst),

        .alloc_req(alloc_req),
        .alloc_gnt(alloc_gnt),
        .alloc_tag(alloc_tag_int),

        .head_finished(head_finished),
        .commit_allow(1'b1),
        .free_we(free_we),
        .free_tag(free_tag),

        .head_ptr(head_ptr),
        .tail_ptr(tail_ptr),
        .empty(empty),
        .full(full),
        .count_out(count_out)
    );

    assign alloc_we_int = alloc_gnt;
    assign alloc_tag    = alloc_tag_int;

    // head finished
    assign head_finished = (r0_state == ROB_FIN);

    // for commit
    assign commit_fire  = free_we;
    assign commit_tag   = free_tag;

    assign commit_state = r0_state;
    assign commit_S     = r0_S;
    assign commit_ST    = r0_ST;
    assign commit_V     = r0_V;
    assign commit_rd    = r0_rd;
    assign commit_value = r0_value;

    // -----------------------------
    // ROB registers (8 entry)
    // -----------------------------
    rob_regs8 u_regs (
        .clk(clk),
        .rst(rst),

        // Read ports
        .raddr0(head_ptr),
        .raddr1(3'd0),

        .r0_state(r0_state),
        .r0_S(r0_S),
        .r0_ST(r0_ST),
        .r0_V(r0_V),
        .r0_rd(r0_rd),
        .r0_value(r0_value),

        .r1_state(r1_state),
        .r1_S(r1_S),
        .r1_ST(r1_ST),
        .r1_V(r1_V),
        .r1_rd(r1_rd),
        .r1_value(r1_value),

        // Dump
        .dump_state(dump_state),
        .dump_S(dump_S),
        .dump_ST(dump_ST),
        .dump_V(dump_V),
        .dump_rd(dump_rd),
        .dump_value(dump_value),

        // Allocate (Decode stage)
        .alloc_we(alloc_we_int),
        .alloc_tag(alloc_tag_int),
        .alloc_S(alloc_S),
        .alloc_ST(alloc_ST),
        .alloc_V(alloc_V),
        .alloc_rd(alloc_rd),

        // WB ports
        .wb0_valid(wb0_valid),
        .wb0_tag(wb0_tag),
        .wb0_data(wb0_data),

        .wb1_valid(wb1_valid),
        .wb1_tag(wb1_tag),
        .wb1_data(wb1_data),

        // Free (Commit stage)
        .free_we(free_we),
        .free_tag(free_tag)
    );

endmodule



module rob_regs8 (
    input         clk,
    input         rst,

    // Read ports
    input  [2:0]  raddr0,
    input  [2:0]  raddr1,

    output [1:0]  r0_state,
    output        r0_S,
    output        r0_ST,
    output        r0_V,
    output [4:0]  r0_rd,
    output [31:0] r0_value,

    output [1:0]  r1_state,
    output        r1_S,
    output        r1_ST,
    output        r1_V,
    output [4:0]  r1_rd,
    output [31:0] r1_value,

    // Dump all entries for Decode
    output [15:0] dump_state,
    output [7:0]  dump_S,
    output [7:0]  dump_ST,
    output [7:0]  dump_V,
    output [39:0] dump_rd,   
    output [255:0] dump_value,

    // Allocate (Decode stage)
    input         alloc_we,
    input  [2:0]  alloc_tag,
    input         alloc_S,
    input         alloc_ST,
    input         alloc_V,
    input  [4:0]  alloc_rd,

    // WB ports
    input         wb0_valid,
    input  [2:0]  wb0_tag,
    input  [31:0] wb0_data,

    input         wb1_valid,
    input  [2:0]  wb1_tag,
    input  [31:0] wb1_data,

    // Free (Commit stage)
    input         free_we,
    input  [2:0]  free_tag
);

    localparam [1:0] ROB_FREE = 2'b00;
    localparam [1:0] ROB_PEND = 2'b01;
    localparam [1:0] ROB_FIN  = 2'b10;

    reg [1:0]  state [0:7];
    reg        S     [0:7];
    reg        ST    [0:7];
    reg        V     [0:7];
    reg [4:0]  rd    [0:7];
    reg [31:0] value [0:7];

    // Combinational reads
    assign r0_state = state[raddr0];
    assign r0_S     = S    [raddr0];
    assign r0_ST    = ST   [raddr0];
    assign r0_V     = V    [raddr0];
    assign r0_rd    = rd   [raddr0];
    assign r0_value = value[raddr0];
    assign r1_state = state[raddr1];
    assign r1_S     = S    [raddr1];
    assign r1_ST    = ST   [raddr1];
    assign r1_V     = V    [raddr1];
    assign r1_rd    = rd   [raddr1];
    assign r1_value = value[raddr1];

    // Dump packing (entry 7 is MSB, entry 0 is LSB)
    assign dump_state = { state[7], state[6], state[5], state[4], state[3], state[2], state[1], state[0] };
    assign dump_S     = { S[7],     S[6],     S[5],     S[4],     S[3],     S[2],     S[1],     S[0]     };
    assign dump_ST    = { ST[7],    ST[6],    ST[5],    ST[4],    ST[3],    ST[2],    ST[1],    ST[0]    };
    assign dump_V     = { V[7],     V[6],     V[5],     V[4],     V[3],     V[2],     V[1],     V[0]     };
    assign dump_rd    = { rd[7],    rd[6],    rd[5],    rd[4],    rd[3],    rd[2],    rd[1],    rd[0]    };
    assign dump_value = { value[7], value[6], value[5], value[4], value[3], value[2], value[1], value[0] };

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) begin
                state[i] <= ROB_FREE;
                S[i]     <= 1'b0;
                ST[i]    <= 1'b0;
                V[i]     <= 1'b0;
                rd[i]    <= 5'b0;
                value[i] <= 32'b0;
            end
        end else begin
            if (alloc_we) begin
                state[alloc_tag] <= ROB_PEND;
                S    [alloc_tag] <= alloc_S;
                ST   [alloc_tag] <= alloc_ST;
                V    [alloc_tag] <= alloc_V;
                rd   [alloc_tag] <= alloc_rd;
            end
            if (wb0_valid) begin
                state[wb0_tag] <= ROB_FIN;
                value[wb0_tag] <= wb0_data;
            end
            if (wb1_valid) begin
                state[wb1_tag] <= ROB_FIN;
                value[wb1_tag] <= wb1_data;
            end
            if (free_we) begin
                state[free_tag] <= ROB_FREE;
                S    [free_tag] <= 1'b0;
                ST   [free_tag] <= 1'b0;
                V    [free_tag] <= 1'b0;
                rd   [free_tag] <= 5'b0;
                value[free_tag] <= 32'b0;
            end
        end
    end

endmodule


module rob_ctrl8 (
    input         clk,
    input         rst,

    input         alloc_req,
    output        alloc_gnt,
    output [2:0]  alloc_tag,

    input        head_finished,
    input        commit_allow,
    output       free_we,
    output [2:0] free_tag,

    output [2:0] head_ptr,
    output [2:0] tail_ptr,
    output       empty,
    output       full,
    output [3:0] count_out
);

    reg [2:0] head;
    reg [2:0] tail;
    reg [3:0] count;

    wire do_alloc;
    wire do_commit;

    assign empty = (count == 4'd0);
    assign full  = (count == 4'd8);

    assign alloc_gnt = alloc_req & ~full;
    assign alloc_tag = tail;

    assign do_alloc  = alloc_gnt;
    assign do_commit = head_finished & commit_allow & ~empty;

    assign free_we  = do_commit;
    assign free_tag = head;

    assign head_ptr  = head;
    assign tail_ptr  = tail;
    assign count_out = count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            head  <= 3'd0;
            tail  <= 3'd0;
            count <= 4'd0;
        end else begin
            case ({do_alloc, do_commit})
                2'b10: begin
                    tail  <= tail + 3'd1;
                    count <= count + 4'd1;
                end
                2'b01: begin
                    head  <= head + 3'd1;
                    count <= count - 4'd1;
                end
                2'b11: begin
                    tail  <= tail + 3'd1;
                    head  <= head + 3'd1;
                    count <= count;
                end
                default: begin
                    head  <= head;
                    tail  <= tail;
                    count <= count;
                end
            endcase
        end
    end

endmodule
