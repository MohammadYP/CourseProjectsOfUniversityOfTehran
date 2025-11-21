`define IDLE 3'b000
`define READ1 3'b001
`define READ2 3'b010
`define READ3 3'b011
`define WRITE1 3'b100
`define WRITE2 3'b101

module off_chip_spi_flash_controller (
    input clk,
    input rst,
    input read,
    input write,
    input [5:0] countOut,

    output reg cntECnt,
    output reg clearCnt,
    output reg loadSh1,
    output reg loadSh3,
    output reg shift1,
    output reg shift2,
    output reg shift3,
    output reg sel,
    output reg ready,
    output reg CSbar
);

    reg [2:0] ps, ns;

    always @(*) begin
        cntECnt = 1'b0;
        clearCnt = 1'b0;

        loadSh1 = 1'b0;
        loadSh3 = 1'b0;
        shift1 = 1'b0;
        shift2 = 1'b0;
        shift3 = 1'b0;

        sel = 1'b0;
        CSbar = 1'b1;
        ready = 1'b0;

        case (ps)
            `IDLE: begin
                ready = read ? 1'b0 : 1'b1;
                ns = read ? `READ1 : 
                    write ? `WRITE1 :
                    `IDLE;
                clearCnt = read | write;
                loadSh1 = read;
            end
            `READ1: begin
                cntECnt = 1'b1;
                ready = 1'b0;
                CSbar = 1'b0;
                shift1 = 1'b1;
                sel = 1'b1;

                clearCnt = (countOut == 64'd31) ? 1'b1 : 1'b0;
                ns = (countOut == 64'd31) ? `READ2 : `READ1;
            end
            `READ2: begin
                cntECnt = 1'b1;
                CSbar = 1'b0;
                shift2 = 1'b1;
                ready = 1'b0;
                sel = 1'b1;
                ns = (countOut == 64'd31) ? `READ3 : `READ2;
            end
            `READ3: begin
                ready = 1'b1;
                sel = 1'b1;
                ns = (read == 1'b1) ? `READ3 : `IDLE;
            end 

            `WRITE1: begin
                ready = 1'b1;
                // shift3 = ~write;
                // cntECnt = ~write;
                // sel = 1'b0;

                loadSh3 = ~write;
                ns = (write == 1'b1) ? `WRITE1 : `WRITE2;
            end

            `WRITE2: begin
                ready = 1'b1;
                shift3 = 1'b1;
                cntECnt = 1'b1;
                sel = 1'b0;

                ns = (countOut == 64'd63) ? `IDLE : `WRITE2;
            end
            
        endcase
    end

    always @(posedge clk, posedge rst) begin
        if(rst == 1'b1)
            ps <= 0;
        else
            ps <= ns;
    end


endmodule