module pump_model (
    input wire clk,
    input wire rst,

    input wire pump_on_signal,

    output reg previous_enable_state
);

    

    always @(posedge clk , posedge rst) begin
        if (rst) begin
            previous_enable_state <= 1'b0;
        end else begin
            if (pump_on_signal == 1'b1 && previous_enable_state == 1'b0) begin
                $display("SIM_LOG [PUMP_MODEL]: Activated at time %t", $time);
            end

            if (pump_on_signal == 1'b0 && previous_enable_state == 1'b1) begin
                $display("SIM_LOG [PUMP_MODEL]: Deactivated at time %t", $time);
            end
            previous_enable_state <= pump_on_signal;
        end
    end

endmodule


module pumpWrapper (
    input clk,
    input rst,
    input write,
    input [1:0] address,
    input [7:0] dataIn,

    output pump_activated
);
    reg pumpOn;
    always @(posedge clk, posedge rst) begin
        if(rst)
            pumpOn = 0;
        else if(address == 2'b00 && write)
            pumpOn = dataIn[0];
    end
    // assign pumpOn = (address == 2'b00 && write) ? 1'b1: 1'b0;
    pump_model pump(
        .clk(clk),
        .rst(rst),
        .pump_on_signal(pumpOn),
        .previous_enable_state(pump_activated)
    );

endmodule