module TX_wrapper (
    input clk,
    input rst,
    input read,
    input write,
    input [2:0] addr,
    input [7:0] data_in,

    output ready,
    output [7:0] data_out

);
    
    wire r_Tx_DV;
    wire o_Tx_Active;
    wire [7:0] r_Tx_Byte;

    uart_tx #(
        .CLKS_PER_BIT(87)
    ) UART_TX_INST (
        .i_Clock(clk),
        .i_Tx_DV(r_Tx_DV),
        .i_Tx_Byte(r_Tx_Byte),
        .o_Tx_Active(o_Tx_Active),
        .o_Tx_Serial(),
        .o_Tx_Done(w_Tx_Done)
    );

    reg [9:0] cnf_reg;

    // 0 - 7 : data
    // 8 : start
    // 9 : done

    always @(posedge clk, posedge rst) begin
        if(rst)
            cnf_reg <= 10'b0;
        else if(write && addr[2:0] == 3'd0)
            cnf_reg[7:0] = data_in;
        else if(w_Tx_Done)
            cnf_reg[9] = 1'b1;
        else if(write && addr[2:0] == 3'd4 && data_in[0] == 1'b1)
            cnf_reg[8] = 1'b1;
        else if(cnf_reg[8] == 1'b1)
            cnf_reg[8] = 1'b0;
    end

    assign r_Tx_DV = cnf_reg[8];
    assign r_Tx_Byte = cnf_reg[7:0];
    assign ready = ~o_Tx_Active;

endmodule