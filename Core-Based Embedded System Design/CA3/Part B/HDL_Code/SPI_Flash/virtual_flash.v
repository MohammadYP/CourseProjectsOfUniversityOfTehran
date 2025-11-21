`timescale 1ns/1ns
module virtual_flash #(parameter SECTOR_DEPTH = 4096)
(
    input SCK,
    input CSbar,
    input DI,
    output reg DO
);
    reg clk = 0;
    reg [31:0] din;
    reg [23:0] address;
    reg state, ld, cen, done, senddata;
    reg [31:0] cnt;
    reg [1:0] CS_rec;

    reg [7:0] mem[0:4095];
    integer i;
    initial begin
        $readmemh("mem.mem",mem,0);
    end

    always @(posedge SCK, ld) begin
        if(ld) begin
            address <= din[23:0];
            cnt <= din[23:0] * 8;
        end
        else if(cen)
            cnt <= cnt + 1;
        else
            cnt <= cnt;

        if((((address + SECTOR_DEPTH) * 8) - 1 )== cnt) begin
            cnt <= address * 8;
        end

    end

    always @(posedge SCK) begin
		// alireza added! it may remove a bug
		if(senddata)
			din <= 24'b0;
		else
			din <= {din[30:0], DI};
    end

    always @(negedge SCK) begin
        if(senddata) begin
            DO <= mem[cnt/8][7 - (cnt%8)];
            cen <= 1;
        end
        else begin
           cen <= 0;
        end
    end

    always @(posedge clk) begin
        CS_rec <= {CS_rec[0], CSbar};
        if(CS_rec == 2'b01)
            done <= 1;
        else
            done <= 0;
    end

    always @(posedge clk) begin
        state <= 0;  ld <= 0;

        case (state)
            0: begin
                senddata <= 0;
                if(din[31:24] == 8'h03) begin
                    state <= 1; ld <= 1;
                end
            end
            1: begin
                senddata <= 1;
                if(done)
                    state <= 0;
                else
                    state <= 1;
            end
            default: state <= 0;
        endcase
    end

    always #1 clk = ~clk;

endmodule