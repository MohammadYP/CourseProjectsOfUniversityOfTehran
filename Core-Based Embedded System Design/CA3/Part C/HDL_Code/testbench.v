`timescale 1ns/1ns

module testbench();
	// Core inputs
    reg clk = 1'b0;
    reg rst = 1'b0;
    wire memReady;
    // wire [7:0] dataBus;
    wire [7:0] dataBusIn;
    wire [7:0] dataBusOut;
    reg [15:0] platformInterruptSignals = 16'd0;
    reg machineExternalInterrupt = 1'b0;
    reg machineTimerInterrupt = 1'b0;
    reg machineSoftwareInterrupt = 1'b0;
    reg userExternalInterrupt = 1'b0;
    reg userTimerInterrupt = 1'b0;
    reg userSoftwareInterrupt = 1'b0;

	// Core outputs
    wire memRead;
    wire memWrite;
    wire interruptProcessing;
    wire [31:0] memAddr;

    aftab_core MUT(
        .clk(clk),
        .rst(rst),
        .memReady(memReady),
        .memDataIn(dataBusOut),
        .memDataOut(dataBusIn),
        .memRead(memRead),
        .memWrite(memWrite),
        .memAddr(memAddr),
        .machineExternalInterrupt(machineExternalInterrupt),
        .machineTimerInterrupt(machineTimerInterrupt),
        .machineSoftwareInterrupt(machineSoftwareInterrupt),
        .userExternalInterrupt(userExternalInterrupt),
        .userTimerInterrupt(userTimerInterrupt),
        .userSoftwareInterrupt(userSoftwareInterrupt),
        .platformInterruptSignals(platformInterruptSignals),
        .interruptProcessing(interruptProcessing)
    );

    Bus bus (
        .clk(clk),
        .rst(rst),
        .readMem(memRead),
        .writemem(memWrite),
        .addressBus(memAddr),
        .dataBusIn(dataBusIn),
        .memDataReady(memReady),
        .dataBusOut(dataBusOut)
    );

    initial begin
    	$dumpfile("test.vcd");
	    $dumpvars(0,testbench);
    end

    always #15 clk = ~ clk;

    initial begin
        rst=1;
        #40;
        rst=0;

      #800000
        machineExternalInterrupt = 1'b1;
        #10000;
        machineExternalInterrupt = 1'b0;
        #1306000;
        $stop;
    end


  endmodule
