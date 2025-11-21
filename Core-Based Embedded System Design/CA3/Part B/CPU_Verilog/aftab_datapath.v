// **************************************************************************************
// Filename: aftab_datapath.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_datapath
// Description:
//
// Dependencies:
//
// File content description:
// DP for AFTAB core
//
// **************************************************************************************
`timescale 1ns/1ns

module aftab_datapath #(parameter size = 32) (
    input clk,
    input rst,
    input writeRegFile,
    input setOne,
    input setZero,
    input compareSignedUnsignedBar,
    input selPC,
    input selI4,
    input selAdd,
    input selJL,
    input selADR,
    input selPCJ,
    input selInc4PC,
    input selBSU,
    input selLLU,
    input selASU,
    input selAAU,
    input selDARU,
    input selP1,
    input selP2,
    input selImm,
    input ldPC,
    input zeroPC,
    input ldADR,
    input zeroADR,
    input ldDR,
    input zeroDR,
    input ldIR,
    input zeroIR,
    input ldByteSigned,
    input ldHalfSigned,
    input load,
    input [1:0] selShift,
    input addSubBar,
    input pass,
    input selAuipc,
    input [11:0] muxCode,
    input [1:0] selLogic,
    input startDAWU,
    input startDARU,
    input startMultiplyAAU,
    input startDivideAAU,
    input signedSigned,
    input signedUnsigned,
    input unsignedUnsigned,
    input selAAL,
    input selAAH,
    input dataInstrBar,
    input [1:0] nBytes,
    input memReady,
    input [7:0] memDataIn,
    output [7:0] memDataOut,
    output [size-1:0] memAddrDAWU,
    output [size-1:0] memAddrDARU,
    output writeMem,
    output readMem,
    output [size-1:0] IR,
    output lt,
    output eq,
    output gt,
    output completeDAWU,
    output completeDARU,
    output completeAAU,
    input selCSR,
    input machineExternalInterrupt,
    input machineTimerInterrupt,
    input machineSoftwareInterrupt,
    input userExternalInterrupt,
    input userTimerInterrupt,
    input userSoftwareInterrupt,
    input [15:0] platformInterruptSignals,
    input [2:0] ldValueCSR,
    input mipCCLdDisable,
    input selImmCSR,
    input selP1CSR,
    input selReadWriteCSR,
    input clrCSR,
    input setCSR,
    input selPC_CSR,
    input selTval_CSR,
    input selMedeleg_CSR,
    input selMideleg_CSR,
    input selCCMip_CSR,
    input selCause_CSR,
    input selMepc_CSR,
    input selInterruptAddressDirect,
    input selInterruptAddressVectored,
    input writeRegBank,
    input dnCntCSR,
    input upCntCSR,
    input ldCntCSR,
    input zeroCntCSR,
    input ldFlags,
    input zeroFlags,
    input ldDelegation,
    input ldMachine,
    input ldUser,
    input loadMieReg,
    input loadMieUieField,
    input mirrorUser,
    input machineStatusAlterationPreCSR,
    input userStatusAlterationPreCSR,
    input machineStatusAlterationPostCSR,
    input userStatusAlterationPostCSR,
    input checkMisalignedDARU,
    input checkMisalignedDAWU,
    input selCSRAddrFromInst,
    input selRomAddress,
    input ecallFlag,
    input illegalInstrFlag,

    // FPU
    // input selFPURegFile,
    // input fmaStart,
    // input fmaSel,
    // input selp1FPU,
    // input selp2FPU,
    // input rs1SignInject,
    // input rs1SignXOR,
    // input rs1SignNeg,
    // input rs3SignNeg,
    // input sgnSel,
    // input selP1WriteData,
    // input fpuCompSel,
    // input [1:0] minmaxSel,
    // input rs2SignNeg,
    // input addsubSel,
    // input mulSel,

    // output fpuEq,
    // output fpuLt,
    // output fmaReady,

    output instrMisalignedOut,
    output loadMisalignedOut,
    output storeMisalignedOut,
    output dividedByZeroOut,
    output validAccessCSR,
    output readOnlyCSR,
    output mirror,
    output ldMieReg,
    output ldMieUieField,
    output interruptRaise,
    output exceptionRaise,
    output [1:0] delegationMode,
    output [1:0] previousPRV,
    output [1:0] modeTvec
);

    wire [size-1:0] immediate;
    wire [size-1:0] inst;
    wire [size-1:0] resAAH;
    wire [size-1:0] resAAL;
    wire [size-1:0] p1/*, p1_FPU, p1_Integer*/;
    wire [size-1:0] p2/*, p2_FPU, p2_Integer*/;
    wire [size-1:0] writeData;
    wire [size-1:0] outMux6;
    wire [size-1:0] dataDARU;
    wire [size-1:0] dataDAWU;
    wire [size-1:0] adjDARU;
    wire [size-1:0] addResult;
    wire [size-1:0] lluResult;
    wire [size-1:0] asuResult;
    wire [size-1:0] aauResult;
    wire [size-1:0] bsuResult;
    wire [size-1:0] outADR;
    wire [size-1:0] outMux2;
    wire [size-1:0] inPC;
    wire [size-1:0] outPC;
    wire [size-1:0] inc4PC;
    wire [size-1:0] outMux5;
    wire [size-1:0] addrIn;
    wire exceptionRaiseTemp;
    wire interruptRaiseTemp;
    wire CCmieField;
    wire CCuieField;
    wire mipCCLd;
    wire instrMisalignedFlag;
    wire dividedByZeroFlag;
    wire mirrorUserBar;
    wire mirrorUstatus;
    wire mirrorUie;
    wire mirrorUip;
    wire [1:0] curPRV;
    wire [2:0] cntOutput;
    wire [5:0] exceptionSources;
    wire [5:0] tempFlags;
    wire [5:0] causeCodeTemp;
    wire [11:0] preAddressRegBank;
    wire [11:0] mirrorAddress;
    wire [11:0] addressRegBank;
    wire [11:0] outAddr;
    wire [size-1:0] interruptSources;
    wire [size-1:0] CCmip;
    wire [size-1:0] outCSR;
    wire [size-1:0] inCSR;
    wire [size-1:0] causeCode;
    wire [size-1:0] trapValue;
    wire [size-1:0] CCmie;
    wire [size-1:0] interruptStartAddressDirect;
    wire [size-1:0] interruptStartAddressVectored;
    wire validAddressCSR;

    // edited
    aftab_CSR_address_ctrl CSR_address_ctrl(
        .addressRegBank(addressRegBank),
        .validAddressCSR(validAddressCSR)
    );
    assign validAccessCSR = (curPRV >= addressRegBank[9:8] && validAddressCSR == 1'b1) ? 1'b1 : 1'b0;
    assign readOnlyCSR = (addressRegBank[11:10] == 2'b11) ? 1'b1 : 1'b0;
    assign IR = inst;

    // FPU - uncomment later
    // aftab_fpu_datapath FPU_DP
    // (
    //     .clk(clk),
    //     .rst(rst),
    //     .setZeroReg(setZero & selFPURegFile),
    //     .setOneReg(setOne & selFPURegFile),
    //     .inst(inst),
    //     .writeRegFileFPU(writeRegFile & selFPURegFile),
    //     .writeData(writeData),
    //     .fmaStart(fmaStart),
    //     .fmaSel(fmaSel),
    //     .sgnSel(sgnSel),
    //     .rs1SignInject(rs1SignInject),
    //     .rs1SignXOR(rs1SignXOR),
    //     .rs1SignNeg(rs1SignNeg),
    //     .rs2SignNeg(rs2SignNeg),
    //     .rs3SignNeg(rs3SignNeg),
    //     .compSel(fpuCompSel),
    //     .minmaxSel(minmaxSel),
    //     .addsubSel(addsubSel),
    //     .mulSel(mulSel),

    //     .p1_FPU(p1_FPU),
    //     .p2_FPU(p2_FPU),
    //     .NV_flag(),
    //     .OF_flag(),
    //     .UF_flag(),
    //     .NX_flag(),
    //     .DZ_flag(),
    //     .fmaReady(fmaReady),
    //     .eq(fpuEq),
    //     .lt(fpuLt)
    // );

    aftab_registerFile #(size) registerFile (
        .clk(clk),
        .rst(rst),
        .setZero(setZero/* & ~selFPURegFile*/),
        .setOne(setOne/* & ~selFPURegFile*/),
        .rs1(inst[19:15]),
        .rs2(inst[24:20]),
        .rd(inst[11:7]),
        .writeData(writeData),
        .writeRegFile(writeRegFile/* & ~selFPURegFile*/),
        .p1(p1/*_Integer*/),
        .p2(p2/*_Integer*/)
    );

    // assign p1 = selp1FPU ? p1_FPU : p1_Integer;
    // assign p2 = selp2FPU ? p2_FPU : p2_Integer;

    aftab_register #(size) regIR (
        .clk(clk),
        .rst(rst),
        .zero(zeroIR),
        .ldR(ldIR),
        .in(dataDARU),
        .out(inst)
    );

    aftab_immSelSignExt #(size) immSelSignEx(
        .IR7(inst[7]),
        .IR20(inst[20]),
        .IR31(inst[31]),
        .IR11_8(inst[11:8]),
        .IR19_12(inst[19:12]),
        .IR24_21(inst[24:21]),
        .IR30_25(inst[30:25]),
        .selI(muxCode[0]),
        .selS(muxCode[1]),
        .selBUJ(muxCode[2]),
        .selIJ(muxCode[3]),
        .selSB(muxCode[4]),
        .selU(muxCode[5]),
        .selISBJ(muxCode[6]),
        .selIS(muxCode[7]),
        .selB(muxCode[8]),
        .selJ(muxCode[9]),
        .selISB(muxCode[10]),
        .selUJ(muxCode[11]),
        .Imm(immediate)
    );

    aftab_adder #(size) adder(
        .a(immediate),
        .b(outMux2),
        .cin(1'b0),
        .cout(),
        .sum(addResult)
    );

    // mux1
    assign inPC = (selAdd == 1'b1) ? addResult :
                  (selI4 == 1'b1) ? inc4PC :
                  (selMepc_CSR == 1'b1) ? outCSR :
                  (selInterruptAddressDirect == 1'b1) ? interruptStartAddressDirect :
                  (selInterruptAddressVectored == 1'b1) ? interruptStartAddressVectored :
                  {(size){1'b0}};

    aftab_register #(size) regPC (
        .clk(clk),
        .rst(rst),
        .zero(zeroPC),
        .ldR(ldPC),
        .in(inPC),
        .out(outPC)
    );

    aftab_mux2to1_2sel #(size) mux2 (
        .i0(outMux6),
        .i1(outPC),
        .s0(selJL),
        .s1(selPC),
        .w(outMux2)
    );

    aftab_register #(size) regADR (
        .clk(clk),
        .rst(rst),
        .zero(zeroADR),
        .ldR(ldADR),
        .in(addResult),
        .out(outADR)
    );

    aftab_adder #(size) i4PC(
        .a(outPC),
        .b({{(size-3){1'b0}}, 3'b100}),
        .cin(1'b0),
        .cout(),
        .sum(inc4PC)
    );

    // mux10
    assign writeData = (selInc4PC == 1'b1) ? inc4PC :
                       (selBSU == 1'b1) ? bsuResult :
                       (selLLU == 1'b1) ? lluResult :
                       (selASU == 1'b1) ? asuResult :
                       (selAAU == 1'b1) ? aauResult :
                       (selDARU == 1'b1) ? adjDARU :
                       (selCSR == 1'b1) ? outCSR :
                    //    (selP1WriteData == 1'b1) ? p1 :
                       {(size){1'b0}};

    aftab_register #(size) regDR (
        .clk(clk),
        .rst(rst),
        .zero(zeroDR),
        .ldR(ldDR),
        .in(p2),
        .out(dataDAWU)
    );

    aftab_mux2to1_2sel #(size) mux5 (
        .i0(p2),
        .i1(immediate),
        .s0(selP2),
        .s1(selImm),
        .w(outMux5)
    );

    aftab_mux2to1_2sel #(size) mux6 (
        .i0(p1),
        .i1(outPC),
        .s0(selP1),
        .s1(selAuipc),
        .w(outMux6)
    );

    aftab_LLU #(size) LLU (
        .a(outMux6),
        .b(outMux5),
        .selLogic(selLogic),
        .lluResult(lluResult)
    );

    aftab_BSU #(size) BSU (
        .dataIn(outMux6),
        .shiftAmount(outMux5[4:0]),
        .selShift(selShift),
        .dataOut(bsuResult)
    );

    aftab_comparator #(size) comparator (
        .a(outMux6),
        .b(outMux5),
        .comparedSignedUnsignedBar(compareSignedUnsignedBar),
        .lt(lt),
        .eq(eq),
        .gt(gt)
    );

    aftab_adder_subtractor #(size) addSub (
        .a(outMux6),
        .b(outMux5),
        .subsel(addSubBar),
        .pass(pass),
        .cout(),
        .result(asuResult)
    );

    aftab_AAU #(size) AAU (
        .A(outMux6),
        .B(outMux5),
        .clk(clk),
        .rst(rst),
        .multAAU(startMultiplyAAU),
        .divideAAU(startDivideAAU),
        .signedSigned(signedSigned),
        .signedUnsigned(signedUnsigned),
        .unsignedUnsigned(unsignedUnsigned),
        .H(resAAH),
        .L(resAAL),
        .completeAAU(completeAAU),
        .dividedByZeroFlag(dividedByZeroFlag)
    );

    aftab_mux2to1_2sel #(size) mux9 (
        .i0(resAAH),
        .i1(resAAL),
        .s0(selAAH),
        .s1(selAAL),
        .w(aauResult)
    );

    aftab_mux2to1_2sel #(size) mux3 (
        .i0(outADR),
        .i1(outMux2),
        .s0(selADR),
        .s1(selPCJ),
        .w(addrIn)
    );

    aftab_MEM_DAWU #(size) DAWU (
        .addrIn(addrIn),
        .dataIn(dataDAWU),
        .nBytes(nBytes),
        .startDAWU(startDAWU),
        .memReady(memReady),
        .clk(clk),
        .rst(rst),
        .checkMisalignedDAWU(checkMisalignedDAWU),
        .addrOut(memAddrDAWU),
        .dataOut(memDataOut),
        .storeMisalignedFlag(),
        .completeDAWU(completeDAWU),
        .writeMem(writeMem)
    );

    aftab_MEM_DARU #(size) DARU (
        .clk(clk),
        .rst(rst),
        .startDARU(startDARU),
        .memReady(memReady),
        .dataInstrBar(dataInstrBar),
        .checkMisalignedDARU(checkMisalignedDARU),
        .addrIn(addrIn),
        .memData(memDataIn),
        .nBytes(nBytes),
        .completeDARU(completeDARU),
        .readMem(readMem),
        .instrMisalignedFlag(instrMisalignedFlag),
        .loadMisalignedFlag(),
        .dataOut(dataDARU),
        .addrOut(memAddrDARU)
    );

    aftab_sulu #(size) sulu (
        .loadByteSigned(ldByteSigned),
        .loadHalfSigned(ldHalfSigned),
        .load(load),
        .dataIn(dataDARU),
        .dataOut(adjDARU)
    );

    assign mipCCLd = ~mipCCLdDisable;

    assign interruptSources = {platformInterruptSignals, 4'b0000, machineExternalInterrupt, 2'b00,
                               userExternalInterrupt, machineTimerInterrupt, 2'b00,
                               userTimerInterrupt, machineSoftwareInterrupt, 2'b00,
                               userSoftwareInterrupt};

    aftab_register #(size) interSrcSynchReg (
        .clk(clk),
        .rst(rst),
        .zero(1'b0),
        .ldR(mipCCLd),
        .in(interruptSources),
        .out(CCmip)
    );


    aftab_CSRISL #(size) CSRISL (
        .selP1(selP1CSR),
        .selIm(selImmCSR),
        .selReadWrite(selReadWriteCSR),
        .clr(clrCSR),
        .set(setCSR),
        .selPC(selPC_CSR),
        .selmip(selCCMip_CSR),
        .selCause(selCause_CSR),
        .selTval(selTval_CSR),
        .machineStatusAlterationPreCSR(machineStatusAlterationPreCSR),
        .userStatusAlterationPreCSR(userStatusAlterationPreCSR),
        .machineStatusAlterationPostCSR(machineStatusAlterationPostCSR),
        .userStatusAlterationPostCSR(userStatusAlterationPostCSR),
        .mirrorUstatus(mirrorUstatus),
        .mirrorUie(mirrorUie),
        .mirrorUip(mirrorUip),
        .mirrorUser(mirrorUser),
        .curPRV(curPRV),
        .ir19_15(inst[19:15]),
        .CCmip(CCmip),
        .causeCode(causeCode),
        .trapValue(trapValue),
        .P1(p1),
        .PC(outPC),
        .outCSR(outCSR),
        .previousPRV(previousPRV),
        .inCSR(inCSR)
    );


    aftab_register_bank #(size) register_bank (
        .clk(clk),
        .rst(rst),
        .writeRegBank(writeRegBank),
        .addressRegBank(addressRegBank),
        .inputRegBank(inCSR),
        .loadMieReg(loadMieReg),
        .loadMieUieField(loadMieUieField),
        .outRegBank(outCSR),
        // .nonExistingCSR(nonExistingCSRFlag),
        .mirrorUstatus(mirrorUstatus),
        .mirrorUie(mirrorUie),
        .mirrorUip(mirrorUip),
        .mirror(mirror),
        .ldMieReg(ldMieReg),
        .ldMieUieField(ldMieUieField),
        .outMieFieldCCreg(CCmieField),
        .outUieFieldCCreg(CCuieField),
        .outMieCCreg(CCmie),
        .MSTATUS_INT_MODE()
    );


    aftab_CSR_counter #(3) CSRCounter (
        .clk(clk),
        .rst(rst),
        .dnCnt(dnCntCSR),
        .upCnt(upCntCSR),
        .ldCnt(ldCntCSR),
        .zeroCnt(zeroCntCSR),
        .ldValue(ldValueCSR),
        .outCnt(cntOutput)
    );


    aftab_CSR_addressing_decoder CSRAddressingDecoder (
        .cntOutput(cntOutput),
	    .outAddr(outAddr)
    );


    // mux7
    assign preAddressRegBank = (selCSRAddrFromInst == 1'b1) ? inst[31:20] :
                               (selRomAddress == 1'b1) ? outAddr :
                               (selMedeleg_CSR == 1'b1) ? 12'h302 :
                               (selMideleg_CSR == 1'b1) ? 12'h303 :
                               12'b0000_0000_0000;

    assign mirrorAddress = {4'b0000, preAddressRegBank[7:0]};


    aftab_mux2to1_2sel #(12) mux8 (
        .i0(preAddressRegBank),
        .i1(mirrorAddress),
        .s0(mirrorUserBar),
        .s1(mirrorUser),
        .w(addressRegBank)
    );

    assign mirrorUserBar = ~mirrorUser;

    aftab_ICCD #(size) interrCheckCauseDetection(
        .clk(clk),
        .rst(rst),
        .inst(inst),
        .outPC(outPC),
        .outADR(outADR),
        .mipCC(CCmip),
        .mieCC(CCmie),
        .midelegCSR(outCSR),
        .medelegCSR(outCSR),
        .mieFieldCC(CCmieField),
        .uieFieldCC(CCuieField),
        .ldDelegation(ldDelegation),
        .ldMachine(ldMachine),
        .ldUser(ldUser),
        .tempFlags(tempFlags),
        .interruptRaise(interruptRaiseTemp),
        .exceptionRaise(exceptionRaiseTemp),
        .delegationMode(delegationMode),
        .curPRV(curPRV),
        .causeCode(causeCode),
        .trapValue(trapValue)
    );


    aftab_register #(6) regExceptionFlags (
        .clk(clk),
        .rst(rst),
        .zero(zeroFlags),
        .ldR(ldFlags),
        .in(exceptionSources),
        .out(tempFlags)
    );


    assign exceptionSources = {ecallFlag, dividedByZeroFlag, illegalInstrFlag, instrMisalignedFlag, 1'b0, 1'b0};

    assign instrMisalignedOut = instrMisalignedFlag;
    assign loadMisalignedOut = 1'b0;
    assign storeMisalignedOut = 1'b0;
    assign dividedByZeroOut = dividedByZeroFlag;
    // assign nonExistingCSROut = nonExistingCSRFlag;

    assign interruptRaise = interruptRaiseTemp;
    assign exceptionRaise = exceptionRaiseTemp;

    assign causeCodeTemp = {causeCode[31], causeCode[4:0]};
    //assign causeCodeTemp = {1'b0, causeCode[4:0]};
    aftab_isagu #(size) interruptStartAddressGenerator (
        .tvecBase(outCSR),
        .causeCode(causeCodeTemp),
        .modeTvec(modeTvec),
        .interruptStartAddressDirect(interruptStartAddressDirect),
        .interruptStartAddressVectored(interruptStartAddressVectored)
    );

endmodule
