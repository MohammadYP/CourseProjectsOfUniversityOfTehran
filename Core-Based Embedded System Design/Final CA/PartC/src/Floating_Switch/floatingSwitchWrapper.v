module FLSWrapper (
    input clk,
    input rst,
    input pump_activated,
    input [1:0] address,
    output [7:0] sensOut
);
    wire [7:0] temp;
    wire [8:0] SensorOut;

    repository waterLevelSensor(
        .clk(clk),
        .rst(rst),
        .pump_activated(pump_activated),
        .SensorOut(SensorOut)
    );

    assign temp =   (SensorOut == 9'b000000000) ? 8'd0 :
                    (SensorOut == 9'b000000001) ? 8'd10 :
                    (SensorOut == 9'b000000011) ? 8'd20 :
                    (SensorOut == 9'b000000111) ? 8'd30 :
                    (SensorOut == 9'b000001111) ? 8'd40 :
                    (SensorOut == 9'b000011111) ? 8'd50 :
                    (SensorOut == 9'b000111111) ? 8'd60 :
                    (SensorOut == 9'b001111111) ? 8'd70 :
                    (SensorOut == 9'b011111111) ? 8'd80 :
                    (SensorOut == 9'b111111111) ? 8'd90 :
                    8'd0;

    assign sensOut = (address == 2'b00) ? {temp} :8'b0;


endmodule