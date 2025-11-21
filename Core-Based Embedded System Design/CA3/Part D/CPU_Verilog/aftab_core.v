// **************************************************************************************
// Filename: aftab_core.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_core
// Description:
//
// Dependencies:
//
// File content description:
// aftab_core for AFTAB
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_core #(parameter size = 32) (
    input clk,
    input rst,
    input memReady,
    input [7:0] memDataIn,
    output [7:0] memDataOut,
    output memRead,
    output memWrite,
    output [size-1:0] memAddr,
    input machineExternalInterrupt,
    input machineTimerInterrupt,
    input machineSoftwareInterrupt,
    input userExternalInterrupt,
    input userTimerInterrupt,
    input userSoftwareInterrupt,
    input [15:0] platformInterruptSignals,
    output interruptProcessing
);

    wire selPC;
	wire selI4;
	wire selP2;
	wire selP1;
	wire selJL;
	wire selADR;
	wire selPCJ;
	wire selImm;
	wire selAdd;
	wire selInc4PC;
	wire selBSU;
	wire selLLU;
	wire selDARU;
	wire selASU;
	wire selAAU;
	wire dataInstrBar;
	wire writeRegFile;
	wire addSubBar;
	wire pass;
	wire selAuipc;
	wire comparedsignedunsignedbar;
	wire ldIR;
	wire ldADR;
	wire ldPC;
	wire ldDr;
	wire ldByteSigned;
	wire ldHalfSigned;
	wire load;
	wire setOne;
	wire setZero;
	wire startDARU;
	wire startDAWU;
	wire completeDARU;
	wire completeDAWU;
	wire startMultiplyAAU;
	wire startDivideAAU;
	wire completeAAU;
	wire signedSigned;
	wire signedUnsigned;
	wire unsignedUnsigned;
	wire selAAL;
	wire selAAH;
	wire eq;
	wire gt;
	wire lt;
	wire [1:0] nBytes;
	wire [1:0] selLogic;
	wire [1:0] selShift;
	wire [11:0] muxCode;
	wire [1:0] modeTvec;
	wire [1:0] previousPRV;
	wire [1:0] delegationMode;
	wire [size-1:0] IR;
	wire selCSR;
	wire interruptRaise;
	wire mipCCLdDisable;
	wire [2:0] ldValueCSR;
	wire selImmCSR;
	wire selReadWriteCSR;
	wire selP1CSR;
	wire clrCSR;
	wire setCSR;
	wire selPC_CSR;
	wire selCCMip_CSR;
	wire selCause_CSR;
	wire selMepc_CSR;
	wire machineStatusAlterationPreCSR;
	wire userStatusAlterationPreCSR;
	wire machineStatusAlterationPostCSR;
	wire userStatusAlterationPostCSR;
	wire writeRegBank;
	wire dnCntCSR;
	wire upCntCSR;
	wire ldCntCSR;
	wire zeroCntCSR;
	wire ldFlags;
	wire zeroFlags;
	wire ldDelegation;
	wire ldMachine;
	wire ldUser;
	wire loadMieReg;
	wire loadMieUieField;
	wire mirrorUser;
	wire selCSRAddrFromInst;
	wire selRomAddress;
	wire validAccessCSR;
	wire readOnlyCSR;
	wire selInterruptAddressDirect;
	wire selInterruptAddressVectored;
	wire ecallFlag;
	wire illegalInstrFlag;
	wire instrMisalignedOut;
	wire loadMisalignedOut;
	wire storeMisalignedOut;
	wire selTval_CSR;
	wire exceptionRaise;
	wire checkMisalignedDARU;
	wire checkMisalignedDAWU;
	wire dividedByZeroOut;
	wire mirror;
	wire ldMieReg;
	wire ldMieUieField;
	wire selMedeleg_CSR;
	wire selMideleg_CSR;

    // FPU
    // wire selFPURegFile;
    // wire fmaStart;
    // wire fmaSel;
    // wire selp1FPU;
    // wire selp2FPU;
    // wire rs1SignInject;
    // wire rs1SignXOR;
    // wire rs1SignNeg;
    // wire rs3SignNeg;
    // wire sgnSel;
    // wire selP1WriteData;
    // wire fpuCompSel;
    // wire fpuEq;
    // wire fpuLt;
    // wire [1:0] minmaxSel;
    // wire rs2SignNeg;
    // wire addsubSel;
    // wire mulSel;
    // wire fmaReady;

    aftab_datapath #(size) datapath (
        .clk(clk),
        .rst(rst),
        .writeRegFile(writeRegFile),
        .setOne(setOne),
        .setZero(setZero),
        .compareSignedUnsignedBar(comparedsignedunsignedbar),
        .selPC(selPC),
        .selI4(selI4),
        .selAdd(selAdd),
        .selJL(selJL),
        .selADR(selADR),
        .selPCJ(selPCJ),
        .selInc4PC(selInc4PC),
        .selBSU(selBSU),
        .selLLU(selLLU),
        .selASU(selASU),
        .selAAU(selAAU),
        .selDARU(selDARU),
        .selP1(selP1),
        .selP2(selP2),
        .selImm(selImm),
        .ldPC(ldPC),
        .zeroPC(1'b0),
        .ldADR(ldADR),
        .zeroADR(1'b0),
        .ldDR(ldDr),
        .zeroDR(1'b0),
        .ldIR(ldIR),
        .zeroIR(1'b0),
        .ldByteSigned(ldByteSigned),
        .ldHalfSigned(ldHalfSigned),
        .load(load),
        .selShift(selShift),
        .addSubBar(addSubBar),
        .pass(pass),
        .selAuipc(selAuipc),
        .muxCode(muxCode),
        .selLogic(selLogic),
        .startDAWU(startDAWU),
        .startDARU(startDARU),
        .startMultiplyAAU(startMultiplyAAU),
        .startDivideAAU(startDivideAAU),
        .signedSigned(signedSigned),
        .signedUnsigned(signedUnsigned),
        .unsignedUnsigned(unsignedUnsigned),
        .selAAL(selAAL),
        .selAAH(selAAH),
        .dataInstrBar(dataInstrBar),
        .nBytes(nBytes),
        .memReady(memReady),
        .memDataIn(memDataIn),
        .memDataOut(memDataOut),
        .memAddrDAWU(memAddr),
        .memAddrDARU(memAddr),
        .writeMem(memWrite),
        .readMem(memRead),
        .IR(IR),
        .lt(lt),
        .eq(eq),
        .gt(gt),
        .completeDAWU(completeDAWU),
        .completeDARU(completeDARU),
        .completeAAU(completeAAU),
        .selCSR(selCSR),
        .machineExternalInterrupt(machineExternalInterrupt),
        .machineTimerInterrupt(machineTimerInterrupt),
        .machineSoftwareInterrupt(machineSoftwareInterrupt),
        .userExternalInterrupt(userExternalInterrupt),
        .userTimerInterrupt(userTimerInterrupt),
        .userSoftwareInterrupt(userSoftwareInterrupt),
        .platformInterruptSignals(platformInterruptSignals),
        .ldValueCSR(ldValueCSR),
        .mipCCLdDisable(mipCCLdDisable),
        .selImmCSR(selImmCSR),
        .selP1CSR(selP1CSR),
        .selReadWriteCSR(selReadWriteCSR),
        .clrCSR(clrCSR),
        .setCSR(setCSR),
        .selPC_CSR(selPC_CSR),
        .selTval_CSR(selTval_CSR),
        .selMedeleg_CSR(selMedeleg_CSR),
        .selMideleg_CSR(selMideleg_CSR),
        .selCCMip_CSR(selCCMip_CSR),
        .selCause_CSR(selCause_CSR),
        .selMepc_CSR(selMepc_CSR),
        .selInterruptAddressDirect(selInterruptAddressDirect),
        .selInterruptAddressVectored(selInterruptAddressVectored),
        .writeRegBank(writeRegBank),
        .dnCntCSR(dnCntCSR),
        .upCntCSR(upCntCSR),
        .ldCntCSR(ldCntCSR),
        .zeroCntCSR(zeroCntCSR),
        .ldFlags(ldFlags),
        .zeroFlags(zeroFlags),
        .ldDelegation(ldDelegation),
        .ldMachine(ldMachine),
        .ldUser(ldUser),
        .loadMieReg(loadMieReg),
        .loadMieUieField(loadMieUieField),
        .mirrorUser(mirrorUser),
        .machineStatusAlterationPreCSR(machineStatusAlterationPreCSR),
        .userStatusAlterationPreCSR(userStatusAlterationPreCSR),
        .machineStatusAlterationPostCSR(machineStatusAlterationPostCSR),
        .userStatusAlterationPostCSR(userStatusAlterationPostCSR),
        .checkMisalignedDARU(checkMisalignedDARU),
        .checkMisalignedDAWU(checkMisalignedDAWU),
        .selCSRAddrFromInst(selCSRAddrFromInst),
        .selRomAddress(selRomAddress),
        .ecallFlag(ecallFlag),
        .illegalInstrFlag(illegalInstrFlag),
        .instrMisalignedOut(instrMisalignedOut),
        .loadMisalignedOut(),
        .storeMisalignedOut(),
        .dividedByZeroOut(dividedByZeroOut),
        .validAccessCSR(validAccessCSR),
        .readOnlyCSR(readOnlyCSR),
        .mirror(mirror),
        .ldMieReg(ldMieReg),
        .ldMieUieField(ldMieUieField),
        .interruptRaise(interruptRaise),
        .exceptionRaise(exceptionRaise),
        .delegationMode(delegationMode),
        .previousPRV(previousPRV),
        .modeTvec(modeTvec)

        // //FPU - uncomment later
        // .selFPURegFile(selFPURegFile),
        // .fmaStart(fmaStart),
        // .fmaSel(fmaSel),
        // .selp1FPU(selp1FPU),
        // .selp2FPU(selp2FPU),
        // .rs1SignInject(rs1SignInject),
        // .rs1SignXOR(rs1SignXOR),
        // .rs1SignNeg(rs1SignNeg),
        // .rs3SignNeg(rs3SignNeg),
        // .sgnSel(sgnSel),
        // .selP1WriteData(selP1WriteData),
        // .fpuCompSel(fpuCompSel),
        // .fpuEq(fpuEq),
        // .fpuLt(fpuLt),
        // .minmaxSel(minmaxSel),
        // .rs2SignNeg(rs2SignNeg),
        // .addsubSel(addsubSel),
        // .mulSel(mulSel),
        // .fmaReady(fmaReady)
        );

    aftab_controller CU (
        .clk(clk),
        .rst(rst),
        .completeDARU(completeDARU),
        .completeDAWU(completeDAWU),
        .completeAAU(completeAAU),
        .lt(lt),
        .eq(eq),
        .gt(gt),
        .IR(IR),
        .interruptRaise(interruptRaise),
        .exceptionRaise(exceptionRaise),
        .instrMisalignedOut(instrMisalignedOut),
        .loadMisalignedOut(1'b0),
        .storeMisalignedOut(1'b0),
        .dividedByZeroOut(dividedByZeroOut),
        .validAccessCSR(validAccessCSR),
        .readOnlyCSR(readOnlyCSR),
        .mirror(mirror),
        .ldMieReg(ldMieReg),
        .ldMieUieField(ldMieUieField),
        .delegationMode(delegationMode),
        .previousPRV(previousPRV),
        .modeTvec(modeTvec),
        .muxCode(muxCode),
        .nBytes(nBytes),
        .selLogic(selLogic),
        .selShift(selShift),
        .selPC(selPC),
        .selI4(selI4),
        .selP1(selP1),
        .selP2(selP2),
        .selJL(selJL),
        .selADR(selADR),
        .selPCJ(selPCJ),
        .selImm(selImm),
        .selAdd(selAdd),
        .selInc4PC(selInc4PC),
        .selBSU(selBSU),
        .selLLU(selLLU),
        .selASU(selASU),
        .selAAU(selAAU),
        .selDARU(selDARU),
        .dataInstrBar(dataInstrBar),
        .writeRegFile(writeRegFile),
        .addSubBar(addSubBar),
        .pass(pass),
        .selAuipc(selAuipc),
        .comparedsignedunsignedbar(comparedsignedunsignedbar),
        .ldIR(ldIR),
        .ldADR(ldADR),
        .ldPC(ldPC),
        .ldDr(ldDr),
        .ldByteSigned(ldByteSigned),
        .ldHalfSigned(ldHalfSigned),
        .load(load),
        .setOne(setOne),
        .setZero(setZero),
        .startDARU(startDARU),
        .startDAWU(startDAWU),
        .startMultiplyAAU(startMultiplyAAU),
        .startDivideAAU(startDivideAAU),
        .signedSigned(signedSigned),
        .signedUnsigned(signedUnsigned),
        .unsignedUnsigned(unsignedUnsigned),
        .selAAL(selAAL),
        .selAAH(selAAH),
        .ecallFlag(ecallFlag),
        .illegalInstrFlag(illegalInstrFlag),
        .mipCCLdDisable(mipCCLdDisable),
        .selCCMip_CSR(selCCMip_CSR),
        .selCause_CSR(selCause_CSR),
        .selPC_CSR(selPC_CSR),
        .selTval_CSR(selTval_CSR),
        .selMedeleg_CSR(selMedeleg_CSR),
        .selMideleg_CSR(selMideleg_CSR),
        .ldValueCSR(ldValueCSR),
        .ldCntCSR(ldCntCSR),
        .dnCntCSR(dnCntCSR),
        .upCntCSR(upCntCSR),
        .ldFlags(ldFlags),
        .zeroFlags(zeroFlags),
        .ldDelegation(ldDelegation),
        .ldMachine(ldMachine),
        .ldUser(ldUser),
        .loadMieReg(loadMieReg),
        .loadMieUieField(loadMieUieField),
        .mirrorUser(mirrorUser),
        .selCSR(selCSR),
        .selP1CSR(selP1CSR),
        .selReadWriteCSR(selReadWriteCSR),
        .selImmCSR(selImmCSR),
        .setCSR(setCSR),
        .clrCSR(clrCSR),
        .writeRegBank(writeRegBank),
        .selCSRAddrFromInst(selCSRAddrFromInst),
        .selRomAddress(selRomAddress),
        .selMepc_CSR(selMepc_CSR),
        .selInterruptAddressDirect(selInterruptAddressDirect),
        .selInterruptAddressVectored(selInterruptAddressVectored),
        .checkMisalignedDARU(checkMisalignedDARU),
        .checkMisalignedDAWU(checkMisalignedDAWU),
        .machineStatusAlterationPreCSR(machineStatusAlterationPreCSR),
        .userStatusAlterationPreCSR(userStatusAlterationPreCSR),
        .machineStatusAlterationPostCSR(machineStatusAlterationPostCSR),
        .userStatusAlterationPostCSR(userStatusAlterationPostCSR),
        .zeroCntCSR(zeroCntCSR)

        // .selFPURegFile(selFPURegFile),
        // .fmaStart(fmaStart),
        // .fmaSel(fmaSel),
        // .selp1FPU(selp1FPU),
        // .selp2FPU(selp2FPU),
        // .rs1SignInject(rs1SignInject),
        // .rs1SignXOR(rs1SignXOR),
        // .rs1SignNeg(rs1SignNeg),
        // .rs3SignNeg(rs3SignNeg),
        // .sgnSel(sgnSel),
        // .selP1WriteData(selP1WriteData),
        // .fpuCompSel(fpuCompSel),
        // .fpuEq(fpuEq),
        // .fpuLt(fpuLt),
        // .minmaxSel(minmaxSel),
        // .rs2SignNeg(rs2SignNeg),
        // .addsubSel(addsubSel),
        // .mulSel(mulSel),
        // .fmaReady(fmaReady)
    );

    assign interruptProcessing = mipCCLdDisable;

endmodule


