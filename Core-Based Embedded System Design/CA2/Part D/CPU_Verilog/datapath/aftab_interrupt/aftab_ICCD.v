// **************************************************************************************
// Filename: aftab_ICCD.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_ICCD
// Description:
//
// Dependencies:
//
// File content description:
// aftab_ICCD for AFTAB interrupt
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_ICCD #(parameter len = 32)
(
	input clk,
	input rst,
	input [len-1 : 0] inst,
	input [len-1 : 0] outPC,
	input [len-1 : 0] outADR,
	input [len-1 : 0] mipCC,
	input [len-1 : 0] mieCC,
	input [len-1 : 0] midelegCSR,
	input [len-1 : 0] medelegCSR,
	input mieFieldCC,
	input uieFieldCC,
	input ldDelegation,
	input ldMachine,
	input ldUser,
	input [5:0] tempFlags,
	output interruptRaise,
	output exceptionRaise,
	output reg [1:0] delegationMode,
	output [1:0] curPRV,
	output reg [len-1 : 0] causeCode,
	output [len-1 : 0] trapValue
);

	wire interRaiseTemp;
    wire exceptionRaiseTemp;
	wire tempIllegalInstr;
    wire tempInstrAddrMisaligned;
    wire tempStoreAddrMisaligned;
    wire tempLoadAddrMisaligned;
    wire tempDividedByZero;
    wire tempEcallFlag;
    wire interRaiseReserved;
	reg [1:0] currentPRV;
    reg [1:0] delegationReg;
	wire [15:0] interReserved;
	wire interRaiseMachineExternal;
    wire interRaiseMachineSoftware;
    wire interRaiseMachineTimer;
    wire interRaiseUserExternal;
    wire interRaiseUserSoftware;
    wire interRaiseUserTimer;
    wire user;
    wire machine;

	always @(posedge clk, posedge rst)
	begin
		if(rst == 1'b1)
			currentPRV <= 2'b11;
		else
		begin
			if(ldMachine == 1'b1)
				currentPRV <= 2'b11;
			else if(ldUser == 1'b1)
				currentPRV <= 2'b00;
		end
	end

	assign curPRV = currentPRV;

	always @(posedge clk, posedge rst)
	begin
		if(rst == 1'b1)
			delegationMode <= 2'b00;
		else
		begin
			if(ldDelegation == 1'b1)
				delegationMode <= delegationReg;
		end
	end

	// Current Mode
	assign user = ~(currentPRV[1]) & ~(currentPRV[0]);
	assign machine = currentPRV[1] & currentPRV[0];

	// Exception Flags
	assign tempEcallFlag = tempFlags[5];
	assign tempDividedByZero = tempFlags[4];
	assign tempIllegalInstr = tempFlags[3];
	assign tempInstrAddrMisaligned = tempFlags[2];
	assign tempLoadAddrMisaligned = tempFlags[1];
	assign tempStoreAddrMisaligned = tempFlags[0];
	assign exceptionRaiseTemp = ((tempIllegalInstr | tempInstrAddrMisaligned) |
								 (tempStoreAddrMisaligned | tempLoadAddrMisaligned)) |
								  (tempDividedByZero | tempEcallFlag);
	assign exceptionRaise = exceptionRaiseTemp;

	// Interrupt Source
	assign interRaiseMachineExternal = (user | (machine & mieFieldCC)) &
								 	   (mipCC[11] & mieCC[11]);
	assign interRaiseMachineSoftware = (user | (machine & mieFieldCC)) &
								 	   (mipCC[3] & mieCC[3]);
	assign interRaiseMachineTimer = (user | (machine & mieFieldCC)) &
					             	(mipCC[7] & mieCC[7]);
	assign interRaiseUserExternal = (user & uieFieldCC) & (mipCC[8] & mieCC[8]);
	assign interRaiseUserSoftware = (user & uieFieldCC) & (mipCC[0] & mieCC[0]);
	assign interRaiseUserTimer = (user & uieFieldCC) & (mipCC[4] & mieCC[4]);

	assign interReserved = (mipCC[31:16] & mieCC[31:16]);
	assign interRaiseReserved = mieFieldCC & (|{interReserved});


	assign interRaiseTemp = interRaiseMachineExternal | interRaiseMachineSoftware |
							interRaiseMachineTimer | interRaiseUserExternal |
							interRaiseUserSoftware | interRaiseUserTimer |
							interRaiseReserved;
	assign interruptRaise = interRaiseTemp;

	// causeCodeGeneration
	always @( exceptionRaiseTemp, tempIllegalInstr, tempInstrAddrMisaligned,
			  tempStoreAddrMisaligned, tempLoadAddrMisaligned, tempDividedByZero,
			  tempEcallFlag, interRaiseTemp, mipCC
			)
	begin
		if(exceptionRaiseTemp == 1'b1)
		begin
			if (tempIllegalInstr == 1'b1)
				causeCode <= {1'b0, {(len-3){1'b0}}, (2'd2)};
			else if(tempInstrAddrMisaligned == 1'b1)
				causeCode <= {1'b0, {(len-1){1'b0}}};
			else if(tempStoreAddrMisaligned == 1'b1)
				causeCode <= {1'b0, {(len-4){1'b0}}, (3'd6)};
			else if(tempLoadAddrMisaligned == 1'b1)
				causeCode <= {1'b0, {(len-4){1'b0}}, (3'd4)};
			else if(tempEcallFlag == 1'b1)
				causeCode <= {1'b0, {(len-5){1'b0}}, (4'd8)}; // ecall from user
			else
				causeCode <= {(len){1'b0}};
		end
		else if(interRaiseTemp == 1'b1)
		begin
			if   (mipCC[11] == 1'b1)
				causeCode <= {1'b1, {(len-5){1'b0}}, (4'd11)};
			else if(mipCC[3] == 1'b1)
				causeCode <= {1'b1, {(len-3){1'b0}}, (2'd3)};
			else if(mipCC[7] == 1'b1)
				causeCode <= {1'b1, {(len-4){1'b0}}, (3'd7)};
			else if(mipCC[8] == 1'b1)
				causeCode <= {1'b1, {(len-5){1'b0}}, (4'd8)};
			else if(mipCC[0] == 1'b1)
				causeCode <= {1'b1, {(len-1){1'b0}}};
			else if(mipCC[4] == 1'b1)
				causeCode <= {1'b1, {(len-4){1'b0}}, (3'd4)};
			// for reserved
			else if(mipCC[16] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd16)};
			else if(mipCC[17] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd17)};
			else if(mipCC[18] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd18)};
			else if(mipCC[19] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd19)};
			else if(mipCC[20] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd20)};
			else if(mipCC[21] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd21)};
			else if(mipCC[22] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd22)};
			else if(mipCC[23] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd23)};
			else if(mipCC[24] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd24)};
			else if(mipCC[25] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd25)};
			else if(mipCC[26] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd26)};
			else if(mipCC[27] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd27)};
			else if(mipCC[28] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd28)};
			else if(mipCC[29] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd29)};
			else if(mipCC[30] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd30)};
			else if(mipCC[31] == 1'b1)
				causeCode <= {1'b1, {(len-6){1'b0}}, (5'd31)};
			else
				causeCode <= {(len){1'b0}};
		end
		else
			causeCode <= {(len){1'b0}};
	end

	// delegationCheck
	always @(exceptionRaiseTemp, interRaiseTemp, tempIllegalInstr,
			 tempInstrAddrMisaligned, tempStoreAddrMisaligned, tempDividedByZero,
			 tempLoadAddrMisaligned, tempEcallFlag,
			 mipCC, machine, user, medelegCSR, midelegCSR
			)
	begin
		if (exceptionRaiseTemp == 1'b1)
		begin
			if (tempIllegalInstr == 1'b1 && user == 1'b1 && medelegCSR[2] == 1'b1)
				delegationReg <= 2'b00;
			else if(tempInstrAddrMisaligned == 1'b1 && user == 1'b1 && medelegCSR[0] == 1'b1)
				delegationReg <= 2'b00;
			else if(tempStoreAddrMisaligned == 1'b1 && user == 1'b1 && medelegCSR[6] == 1'b1)
				delegationReg <= 2'b00;
			else if(tempLoadAddrMisaligned == 1'b1 && user == 1'b1 && medelegCSR[4] == 1'b1)
				delegationReg <= 2'b00;
			else if(tempDividedByZero == 1'b1 && user == 1'b1 && medelegCSR[10] == 1'b1)
				delegationReg <= 2'b00;
			else if(tempEcallFlag == 1'b1 && user == 1'b1 && medelegCSR[11] == 1'b1)
				delegationReg <= 2'b00;
			else
				delegationReg <= 2'b11;
		end
		else if(interRaiseTemp == 1'b1)
		begin
			if (mipCC[8] == 1'b1 && user == 1'b1 && midelegCSR[8] == 1'b1)
				delegationReg <= 2'b00;
			else if(mipCC[0] == 1'b1 && user == 1'b1 && midelegCSR[0] == 1'b1)
				delegationReg <= 2'b00;
			else if(mipCC[4] == 1'b1 && user == 1'b1 && midelegCSR[4] == 1'b1)
				delegationReg <= 2'b00;
			else
				delegationReg <= 2'b11; // Also for the 16 reserved interrupts
		end
		else
			delegationReg <= 2'b11;
	end

	assign trapValue = (tempIllegalInstr == 1'b1) ? inst :
					   (tempInstrAddrMisaligned == 1'b1) ? outPC :
					   (tempStoreAddrMisaligned == 1'b1 || tempLoadAddrMisaligned == 1'b1) ? outADR :
					   {(len){1'b0}};
endmodule
