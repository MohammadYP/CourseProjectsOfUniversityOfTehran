module repository (
    input clk,
    input rst,
    input pump_activated,
    output reg [8:0] SensorOut
);

reg [8:0] waterLevel = 9'd100;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        waterLevel = 9'd100;
    end
    else if(pump_activated) begin
        if(waterLevel == 0) begin
            waterLevel = 0;
        end
        else begin
            waterLevel = waterLevel - 1;
        end
    end
end

always @(waterLevel) begin
    SensorOut <= 0;
    if (waterLevel < 7'd10)
        SensorOut <= 9'b0000000000;
    else if (waterLevel < 7'd20 && waterLevel > 7'd10)
        SensorOut <= 9'b000000001;
    else if (waterLevel < 7'd30 && waterLevel > 7'd20)
        SensorOut <= 9'b000000011;
    else if (waterLevel < 7'd40 && waterLevel > 7'd30)
        SensorOut <= 9'b000000111;
    else if (waterLevel < 7'd50 && waterLevel > 7'd40)
        SensorOut <= 9'b000001111;
    else if (waterLevel < 7'd60 && waterLevel > 7'd50)
        SensorOut <= 9'b000011111;
    else if (waterLevel < 7'd70 && waterLevel > 7'd60)
        SensorOut <= 9'b000111111;
    else if (waterLevel < 7'd80 && waterLevel > 7'd70)
        SensorOut <= 9'b001111111;
    else if (waterLevel < 7'd90 && waterLevel > 7'd80)
        SensorOut <= 9'b011111111;
    else
        SensorOut <= 9'b111111111;
end


endmodule