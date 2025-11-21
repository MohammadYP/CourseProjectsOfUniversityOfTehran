module HumidityTemperatureSensor #(
    parameter ADDRESSH = 7'b0101010,
    parameter ADDRESST = 7'b0101010
) (
    input clk,
    input rst,
    input [6:0] addr,
    input [7:0] data_in,
    input enable,
    input read,

    output [7:0] HTS_out,
    output ready
);

    wire i2c_sda;
	wire i2c_scl;
    wire Inner_enable;
    wire [7:0] data_out;

    i2c_controller master (
		.clk(clk),
		.rst(rst),
		.addr(addr),
		.data_in(data_in),
		.enable(Inner_enable),
		.rw(read),
		.data_out(data_out),
		.ready(ready),
		.i2c_sda(i2c_sda),
		.i2c_scl(i2c_scl)
	);

    i2c_slave_controller #(
        .ADDRESS(ADDRESSH),
        .P1(40),
        .P2(100)
    ) humidity (
        .sda(i2c_sda), 
        .scl(i2c_scl)
    );

    i2c_slave_controller #(
        .ADDRESS(ADDRESST),
        .P1(0),
        .P2(40)
    ) temperature (
        .sda(i2c_sda), 
        .scl(i2c_scl)
    );

    assign HTS_out = (addr == ADDRESSH || addr == ADDRESST) ? data_out : 8'b0;
    assign Inner_enable = (addr == ADDRESSH || addr == ADDRESST) ? enable : 1'b0;

endmodule