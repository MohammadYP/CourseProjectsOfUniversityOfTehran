// **************************************************************************************
// Filename: aftab_factorial_TB.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_factorial_TB
// Description:
//
// Dependencies:
//
// File content description:
// TB_ft for AFTAB core factorial test
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_testbench();
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

    mem_controller MMUT (
        .readmem(memRead),
        .writemem(memWrite),
        .addressBus(memAddr),
        .dataBusIn(dataBusIn),
        .dataBusOut(dataBusOut),
        .memDataReady(memReady)
    );

    initial begin
    	$dumpfile("test.vcd");
	    $dumpvars(0,aftab_testbench);
    end

    always #15 clk = ~ clk;

    initial begin
        rst=1;
        #40;
        rst=0;
        // $display("PC\t:\tResult (1:Passed/0:Failed)");
        // @(negedge MUT.datapath.regPC.out == 4  ) @(posedge clk) $display("0 \t:\t%1d", (MUT.datapath.registerFile.register_file[2] == 32'd1024));
        // @(negedge MUT.datapath.regPC.out == 8  ) @(posedge clk) $display("4 \t:\t%1d", (MUT.datapath.registerFile.register_file[1] == 32'd255));
        // @(negedge MUT.datapath.regPC.out == 12 ) @(posedge clk) $display("8 \t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[1] == 32'b11000100100110011100000000000000));
        // @(negedge MUT.datapath.regPC.out == 16 ) @(posedge clk) $display("12\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[2] == 32'b01000001010000000000000000000000));
        // @(negedge MUT.datapath.regPC.out == 20 ) @(posedge clk) $display("16\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[3] == 32'b01000110000100000000000000000000));
        // @(negedge MUT.datapath.regPC.out == 24 ) @(posedge clk) $display("20\t:\t%1d", (MMUT.seg2.mem[2052-2048] == 8'd255));
        // @(negedge MUT.datapath.regPC.out == 28 ) @(posedge clk) $display("24\t:\t%1d", (MMUT.seg2.mem[2048-2048] == 8'b00000000));
        // @(negedge MUT.datapath.regPC.out == 32 ) @(posedge clk) $display("28\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[4] == 32'b11000100100110011100000000000000));
        // @(negedge MUT.datapath.regPC.out == 36 ) @(posedge clk) $display("32\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[5] == 32'b01000100100110011100000000000000));
        // @(negedge MUT.datapath.regPC.out == 40 ) @(posedge clk) $display("36\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[6] == 32'b11000100100110011100000000000000));
        // @(negedge MUT.datapath.regPC.out == 44 ) @(posedge clk) $display("40\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[7] == 32'b01000100100110011100000000000000));
        // @(negedge MUT.datapath.regPC.out == 48 ) @(posedge clk) $display("44\t:\t%1d", (MUT.datapath.registerFile.register_file[3] == 32'b01000001010000000000000000000000));
        // @(negedge MUT.datapath.regPC.out == 52 ) @(posedge clk) $display("48\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[8] == 32'b00000000000000000000000011111111));
        // @(negedge MUT.datapath.regPC.out == 56 ) @(posedge clk) $display("52\t:\t%1d", (MUT.datapath.registerFile.register_file[4] == 32'd1));
        // @(negedge MUT.datapath.regPC.out == 60 ) @(posedge clk) $display("56\t:\t%1d", (MUT.datapath.registerFile.register_file[5] == 32'd0));
        // @(negedge MUT.datapath.regPC.out == 64 ) @(posedge clk) $display("60\t:\t%1d", (MUT.datapath.registerFile.register_file[6] == 32'd1));
        // @(negedge MUT.datapath.regPC.out == 68 ) @(posedge clk) $display("64\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[9] == 32'b11000100100110011100000000000000));
        // @(negedge MUT.datapath.regPC.out == 72 ) @(posedge clk) $display("68\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[10] == 32'b01000110000100000000000000000000));
        // @(negedge MUT.datapath.regPC.out == 76 ) @(posedge clk) $display("72\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[11] == 32'b11000101101011010100000000000000));
        // @(negedge MUT.datapath.regPC.out == 80 ) @(posedge clk) $display("76\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[12] == 32'b11000110101110110101000000000000));
        // @(negedge MUT.datapath.regPC.out == 84 ) @(posedge clk) $display("80\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[13] == 32'b01000110101110110101000000000000));
        // @(negedge MUT.datapath.regPC.out == 88 ) @(posedge clk) $display("84\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[14] == 32'b01000101101011010100000000000000));
        // @(negedge MUT.datapath.regPC.out == 92 ) @(posedge clk) $display("88\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[15] == 32'b11000100100110000100000000000000));
        // @(negedge MUT.datapath.regPC.out == 96 ) @(posedge clk) $display("92\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[16] == 32'b11000100100110110100000000000000));
        // @(negedge MUT.datapath.regPC.out == 100) @(posedge clk) $display("96\t:\t%1d", (MUT.datapath.FPU_DP.FPU_registerFile.register_file[17] == 32'b11000110011001101010000000000000));
        // @(negedge MUT.datapath.regPC.out == 836) @(posedge clk)
        #20000
        machineExternalInterrupt = 1'b1;
        #1000;
        machineExternalInterrupt = 1'b0;
        #54000;
        $stop;
    end

  endmodule
