`timescale 1ns/1ns

module testbench();

    parameter c_BIT_PERIOD = 8600;

	// Core inputs
    reg clk = 1'b0;
    reg rst = 1'b0;
    wire memReady;
    // wire [7:0] dataBus;
    wire [7:0] dataBusIn;
    wire [7:0] dataBusOut;
    reg [15:0] platformInterruptSignals = 16'd0;
    wire machineExternalInterrupt;
    reg machineTimerInterrupt = 1'b0;
    reg machineSoftwareInterrupt = 1'b0;
    reg userExternalInterrupt = 1'b0;
    reg userTimerInterrupt = 1'b0;
    reg userSoftwareInterrupt = 1'b0;

	// Core outputs
    wire memRead;
    wire memWrite;
    wire interruptProcessing;
    reg r_Rx_Serial = 1;
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
        .to_embedded(r_Rx_Serial),
        .addressBus(memAddr),
        .dataBusIn(dataBusIn),
        .memDataReady(memReady),
        .uart_interrupt(machineExternalInterrupt),
        .dataBusOut(dataBusOut)
    );

    // Takes in input byte and serializes it 
    task UART_WRITE_BYTE;
        input [7:0] i_Data;
        integer     ii;
        begin
            
            // Send Start Bit
            r_Rx_Serial <= 1'b0;
            #(c_BIT_PERIOD);
            #1000;
            
            
            // Send Data Byte
            for (ii=0; ii<8; ii=ii+1)
            begin
                r_Rx_Serial <= i_Data[ii];
                #(c_BIT_PERIOD);
            end
            
            // Send Stop Bit
            r_Rx_Serial <= 1'b1;
            #(c_BIT_PERIOD);
        end
    endtask // UART_WRITE_BYTE

    initial begin
    	$dumpfile("test.vcd");
	    $dumpvars(0,testbench);
    end

    always #50 clk = ~ clk;

    initial begin
        rst=1;
        #40;
        rst=0;

        // #1750000
        // #550000
        #2290000; // write timer
      #140000; // read timer
      #206000; // read temp
      #109000; // read humidity
      #103000; // read FLS
        #2552000; // write timer
        #500000; // for TX Uart just went 1ms further
        $stop;
    end


  endmodule
