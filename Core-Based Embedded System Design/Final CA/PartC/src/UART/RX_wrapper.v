module RX_wrapper (
    input clk,
    input rst,
    input read,
    input write,
    input r_Rx_Serial,
    input [3:0] addr,
    input [7:0] data_in,

    output interrupt,
    output ready,
    output [7:0] data_out
);
    wire done;
    wire [7:0] w_Rx_Byte;

    uart_rx #(
        .CLKS_PER_BIT(87)
    ) UART_RX_INST (
        .i_Clock(clk),
        .i_Rx_Serial(r_Rx_Serial),
        .o_Rx_DV(done),
        .ready(ready),
        .o_Rx_Byte(w_Rx_Byte)
    );

    reg [7:0] cnf_reg;

    // 0 : interrupt
    // 1 : start
    always @(posedge clk, posedge rst) begin
        if(rst)
            cnf_reg <= 8'b0;
        else if (write && addr == 4'd0)
            cnf_reg <= data_in;
        else if (read && addr == 4'd4)
            cnf_reg[0] <= 1'b0;
        else if (done == 1'b1)
            cnf_reg[0] <= 1'b1;
    end

    assign interrupt = cnf_reg[0];
    assign data_out = (addr == 4'd4) ? cnf_reg :
                      (addr == 4'd8) ?  w_Rx_Byte :
                      8'b0; 

endmodule