// **************************************************************************************
// Filename: aftab_controller.v
// Project: AFTAB
// Version: 1.0
// Date:
//
// Module Name: aftab_controller
// Description:
//
// Dependencies:
//
// File content description:
// aftab_controller for AFTAB core
//
// **************************************************************************************
`timescale 1ns/1ns

`define fetch 6'b000000
`define getInstr 6'b000001
`define decode 6'b000010
`define loadInstr1 6'b000011
`define loadInstr2 6'b000100
`define getData 6'b000101
`define storeInstr1 6'b000110
`define storeInstr2 6'b000111
`define putData 6'b001000
`define addSub 6'b001001
`define compare 6'b001010
`define logical 6'b001011
`define shift 6'b001100
`define multiplyDivide1 6'b001101
`define multiplyDivide2 6'b001110
`define conditionalBranch 6'b001111
`define JAL 6'b010000
`define JALR 6'b010010
`define LUI 6'b010011
`define checkDelegation 6'b010100
`define updateTrapValue 6'b010101
`define updateMip 6'b010110
`define updateUip 6'b010111
`define updateCause 6'b011000
`define readMstatus 6'b011001
`define updateMstatus 6'b011010
`define updateUstatus 6'b011011
`define updateEpc 6'b011100
`define readTvec1 6'b011101
`define readTvec2 6'b011110
`define CSR 6'b011111
`define mirrorCSR 6'b100000
`define retEpc 6'b100001
`define retReadMstatus 6'b100010
`define retUpdateMstatus 6'b100011
`define retUpdateUstatus 6'b100100
`define ecall 6'b100101
// FPU - uncomment later
// `define fpu_SignInject 6'b100111
// `define fpu_MinMax 6'b101000
// `define fpu_Convert 6'b101001
// `define fpu_Move 6'b101010
// `define fpu_Compare 6'b101011
// `define fpu_FusedMulAdd 6'b101100   // floating point fused multiply-add
// `define fpu_FusedMulAdd2 6'b101101
// `define fpu_AddSub 6'b101110
// `define fpu_AddSub2 6'b101111
// `define fpu_Mul 6'b110000
// `define fpu_Mul2 6'b110001
// `define fpu_Div 6'b110010

// Constants
`define iTypeImm 12'b010011001001
`define sTypeImm 12'b010011010010
`define uTypeImm 12'b100000100100
`define jTypeImm 12'b101001001100
`define bTypeImm 12'b010101010100
`define Loads 7'b0000011
`define Stores 7'b0100011
`define Arithmetic 7'b0110011
`define ImmediateArithmetic 7'b0010011
`define JumpAndLink 7'b1101111
`define JumpAndLinkRegister 7'b1100111
`define Branch 7'b1100011
`define LoadUpperImmediate 7'b0110111
`define AddUpperImmediatePC 7'b0010111
`define SystemAndCSR 7'b1110011
// `define FPU_Load            7'b0000111
// `define FPU_Store           7'b0100111
// `define FPU_MultiplyAdd     7'b1000011
// `define FPU_MultiplySub     7'b1000111
// `define FPU_NegMultiplySub  7'b1001011
// `define FPU_NegMultiplyAdd  7'b1001111
// `define FPU_Arithmetic      7'b1010011

module aftab_controller(
    // inputs
    input clk,
    input rst,
    input completeDARU,
    input completeDAWU,
    input completeAAU,
    input lt,
    input eq,
    input gt,
    input [31:0] IR,

    // interrupt's inputs
    input interruptRaise,
    input exceptionRaise,
    input instrMisalignedOut,
	input loadMisalignedOut,
	input storeMisalignedOut,
	input dividedByZeroOut,
	input validAccessCSR,
	input readOnlyCSR,
	input mirror,
	input ldMieReg,
	input ldMieUieField,
    input [1:0] delegationMode,
    input [1:0] previousPRV,
    input [1:0] modeTvec,

    //FPU
    // input fpuEq,
    // input fpuLt,
    // input fmaReady,
    //outputs
    output reg [11:0] muxCode,
	output reg [1:0] nBytes,
	output reg [1:0] selLogic,
	output reg [1:0] selShift,
	output reg selPC,
	output reg selI4,
	output reg selP1,
	output reg selP2,
	output reg selJL,
	output reg selADR,
	output reg selPCJ,
	output reg selImm,
	output reg selAdd,
	output reg selInc4PC,
	output reg selBSU,
	output reg selLLU,
	output reg selASU,
	output reg selAAU,
	output reg selDARU,
	output reg dataInstrBar,
    output reg writeRegFile,
	output reg addSubBar,
	output reg pass,
	output reg selAuipc,
	output reg comparedsignedunsignedbar,
	output reg ldIR,
    output reg ldADR,
	output reg ldPC,
	output reg ldDr,
	output reg ldByteSigned,
	output reg ldHalfSigned,
	output reg load,
	output reg setOne,
	output reg setZero,
	output reg startDARU,
	output reg startDAWU,
	output reg startMultiplyAAU,
	output reg startDivideAAU,
	output reg signedSigned,
	output reg signedUnsigned,
	output reg unsignedUnsigned,
	output reg selAAL,
	output reg selAAH,

    // FPU
    // output reg selFPURegFile,
    // output reg fmaStart,
    // output reg fmaSel,
    // output reg selp1FPU,
    // output reg selp2FPU,
    // output reg rs1SignInject,
    // output reg rs1SignXOR,
    // output reg rs1SignNeg,
    // output reg rs3SignNeg,
    // output reg sgnSel,
    // output reg selP1WriteData,
    // output reg fpuCompSel,
    // output reg [1:0] minmaxSel,
    // output reg rs2SignNeg,
    // output reg addsubSel,
    // output reg mulSel,

    // interrupt's outputs
    output reg ecallFlag,
    output reg illegalInstrFlag,
    output reg mipCCLdDisable,
    output reg selCCMip_CSR,
    output reg selCause_CSR,
    output reg selPC_CSR,
    output reg selTval_CSR,
    output reg selMedeleg_CSR,
    output reg selMideleg_CSR,
    output reg [2:0] ldValueCSR,
    output reg ldCntCSR,
    output reg dnCntCSR,
    output reg upCntCSR,
    output reg ldFlags,
    output reg zeroFlags,
    output reg ldDelegation,
    output reg ldMachine,
    output reg ldUser,
    output reg loadMieReg,
    output reg loadMieUieField,
    output reg mirrorUser,
    output reg selCSR,
    output reg selP1CSR,
    output reg selReadWriteCSR,
    output reg selImmCSR,
    output reg setCSR,
    output reg clrCSR,
    output reg writeRegBank,
    output reg selCSRAddrFromInst,
    output reg selRomAddress,
    output reg selMepc_CSR,
    output reg selInterruptAddressDirect,
    output reg selInterruptAddressVectored,
    output reg checkMisalignedDARU,
    output reg checkMisalignedDAWU,
    output reg machineStatusAlterationPreCSR,
    output reg userStatusAlterationPreCSR,
    output reg machineStatusAlterationPostCSR,
    output reg userStatusAlterationPostCSR,
    output reg zeroCntCSR
    );

    wire [2:0] func3;
    wire [6:0] opcode;
    wire [6:0] func7;
    wire [11:0] func12;
    wire [4:0] func5;
    wire mretOrUretBar;

    reg [5:0] p_state, n_state;


    assign func3 = IR[14:12];
    assign opcode = IR[6:0];
    assign func7 = IR[31:25];
    assign func12 = IR[31:20];
    assign func5 = IR[31:27];
    assign mretOrUretBar = IR[29];


    always @(posedge clk, posedge rst) begin
        if(rst)
        begin
            p_state <= `fetch;
        end
        else
            p_state <= n_state;
    end

    always @(p_state, completeDARU, completeDAWU, completeAAU,
             opcode, func3, func7, func12, mirror,
             exceptionRaise, interruptRaise, dividedByZeroOut,
             instrMisalignedOut, storeMisalignedOut, modeTvec, loadMisalignedOut/*, fmaReady*/)
    begin
        n_state <= `fetch;
        case(p_state)
            `fetch: begin
                if(exceptionRaise || interruptRaise)
                    n_state <=  `checkDelegation;
                else if(instrMisalignedOut)
                    n_state <= `fetch;
                else
                    n_state <= `getInstr;
            end
            `getInstr: begin
                if(completeDARU)
                    n_state <= `decode;
                else
                    n_state <= `getInstr;
            end
            `decode: begin
                if(opcode == `Loads)
                    n_state <= `loadInstr1;
                else if(opcode == `Stores)
                    n_state <= `storeInstr1;
                else if(opcode == `Arithmetic) begin
                    if(func7[0])
                        n_state <= `multiplyDivide1;
                    else if(func3 == 3'b000)
                        n_state <= `addSub;
                    else if(func3 == 3'b010 || func3 == 3'b011)
                        n_state <= `compare;
                    else if(func3 == 3'b100 || func3 == 3'b110 || func3 == 3'b111)
                        n_state <= `logical;
                    else if(func3 == 3'b001 || func3 == 3'b101)
                        n_state <= `shift;
                    else
                        n_state <= `fetch;
                end
                else if(opcode == `ImmediateArithmetic) begin
                    if (func3 == 3'b000)
                        n_state <= `addSub;
                    else if (func3 == 3'b010 || func3 == 3'b011)
                        n_state <= `compare;
                    else if (func3 == 3'b100 || func3 == 3'b110 || func3 == 3'b111)
                        n_state <= `logical;
                    else if (func3 == 3'b001 || func3 == 3'b101)
                        n_state <= `shift;
                    else
                        n_state <= `fetch;
                end
                else if(opcode == `JumpAndLink)
                    n_state <= `JAL;
                else if(opcode == `JumpAndLinkRegister)
                    n_state <= `JALR;
                else if(opcode == `Branch)
                    n_state <= `conditionalBranch;
                else if(opcode == `LoadUpperImmediate || opcode == `AddUpperImmediatePC)
                    n_state <= `LUI;
                else if(opcode == `SystemAndCSR) begin
                    if (func3 == 3'b000 && func12 == 12'h000)
                        n_state <= `ecall;
                    else if (func3 == 3'b000 && (func12 == 12'h302 || func12 == 12'h002))
                        n_state <= `retEpc;
                    else
                        n_state <= `CSR;
                end
                // FPU - uncomment later
                // else if(opcode == `FPU_Load) // FLW
                //     n_state <= `loadInstr1;
                // else if(opcode == `FPU_Store) // FSW
                //     n_state <= `storeInstr1;
                // else if(opcode == `FPU_MultiplyAdd      || opcode == `FPU_MultiplySub ||
                //         opcode == `FPU_NegMultiplySub   || opcode == `FPU_NegMultiplyAdd) // FMADD, FNMADD, FMSUB, FNMSUB
                //     n_state <= `fpu_FusedMulAdd;
                // else if(opcode == `FPU_Arithmetic) begin
                //     if(func5 == 5'b00000 || func5 == 5'b00001) // FADD, FSUB
                //         n_state <= `fpu_AddSub;
                //     else if(func5 == 5'b00010) // FMUL
                //         n_state <= `fpu_Mul;
                //     else if(func5 == 5'b00011)  // FDIV
                //         n_state <= `fpu_Div;
                //     else if(func5 == 5'b00100) // FSGNJ, FSGNJN, FSGNJX
                //         n_state <= `fpu_SignInject;
                //     else if(func5 == 5'b00101) // FMIN, FMAX
                //         n_state <= `fpu_MinMax;
                //     else if(func5 == 5'b11000 || func5 == 5'b11010) // FCVT.W.S, FCVT.WU.S, FCVT.S.W, FCVT.S.WU
                //         n_state <= `fpu_Convert;
                //     else if(func5 == 5'b11100 || func5 == 5'b11110) // FMV.W.X, FMV.X.W
                //         n_state <= `fpu_Move;
                //     else if(func5 == 5'b10100) // FEQ, FLT, FLE
                //         n_state <= `fpu_Compare;
                // end
                else
                    n_state <= `fetch;
                end
            `loadInstr1:
                n_state <= `loadInstr2;
            `loadInstr2: begin
                if (loadMisalignedOut)
                    n_state <= `fetch;
                else
                    n_state <= `getData;
            end
            `getData: begin
                if (completeDARU)
                    n_state <= `fetch;
                else
                    n_state <= `getData;
            end
            `storeInstr1:
                n_state <= `storeInstr2;
            `storeInstr2: begin
                if (storeMisalignedOut)
                    n_state <= `fetch;
                else
                    n_state <= `putData;
            end
            `putData: begin
                if (completeDAWU)
                    n_state <= `fetch;
                else
                    n_state <= `putData;
            end
            `addSub:
                n_state <= `fetch;
            `compare:
                n_state <= `fetch;
            `logical:
                n_state <= `fetch;
            `shift:
                n_state <= `fetch;
            `multiplyDivide1: begin
                if (dividedByZeroOut)
                    n_state <= `fetch;
                else
                    n_state <= `multiplyDivide2;
            end
            `multiplyDivide2: begin
                if (completeAAU)
                    n_state <= `fetch;
                else
                    n_state <= `multiplyDivide2;
            end
            `JAL:
                n_state <= `fetch;
            `JALR:
                n_state <= `fetch;
            `conditionalBranch:
                n_state <= `fetch;
            `LUI:
                n_state <= `fetch;
            `CSR: begin
                if (~mirror)
                    n_state <= `fetch;
                else
                    n_state <= `mirrorCSR;
            end
            `mirrorCSR:
                n_state <= `fetch;
            `retEpc:
                n_state <= `retReadMstatus;
            `retReadMstatus:
                n_state <= `retUpdateMstatus;
            `retUpdateMstatus:
                n_state <= `retUpdateUstatus;
            `retUpdateUstatus:
                n_state <= `fetch;
            `ecall:
                n_state <= `fetch;
            `checkDelegation: begin
                if (interruptRaise)
                    n_state <= `updateMip;
                else
                    n_state <= `updateTrapValue;
            end
            `updateTrapValue:
                n_state <= `updateCause;
            `updateMip:
                n_state <= `updateUip;
            `updateUip:
                n_state <= `updateCause;
            `updateCause:
                n_state <= `updateEpc;
            `updateEpc:
                n_state <= `readTvec1;
            `readTvec1:
                n_state <= `readTvec2;
            `readTvec2:
                n_state <= `readMstatus;
            `readMstatus:
                n_state <= `updateMstatus;
            `updateMstatus:
                n_state <= `updateUstatus;
            `updateUstatus:
                n_state <= `fetch;
            // FPU - uncomment later
            // `fpu_FusedMulAdd:
            //     n_state <= `fpu_FusedMulAdd2;
            // `fpu_FusedMulAdd2:
            //     n_state <= (fmaReady == 1'b0) ? `fpu_FusedMulAdd2 : `fetch;
            // `fpu_AddSub:
            //     n_state <= `fpu_AddSub2;
            // `fpu_AddSub2:
            //     n_state <= (fmaReady == 1'b0) ? `fpu_AddSub2 : `fetch;
            // `fpu_Mul:
            //     n_state <= `fpu_Mul2;
            // `fpu_Mul2:
            //     n_state <= (fmaReady == 1'b0) ? `fpu_Mul2 : `fetch;
            // `fpu_Div:
            //     n_state <= `fpu_Div;
            // `fpu_SignInject:
            //     n_state <= `fetch;
            // `fpu_MinMax:
            //     n_state <= `fetch;
            // `fpu_Convert:
            //     n_state <= `fetch;
            // `fpu_Move:
            //     n_state <= `fetch;
            // `fpu_Compare:
            //     n_state <= `fetch;
            default:
                n_state <= `fetch;
        endcase
    end

    always @(p_state, exceptionRaise, interruptRaise, instrMisalignedOut,
             completeDARU, completeAAU, opcode, func3, func12, func7,
             gt, lt, eq, loadMisalignedOut, storeMisalignedOut, dividedByZeroOut,
             validAccessCSR, readOnlyCSR, ldMieReg, ldMieUieField,
             mretOrUretBar, previousPRV, modeTvec, delegationMode/*, fmaReady*/)
    begin
        {selPC, selI4, selP2, selPCJ, selADR, selJL, selImm, selAdd, selInc4PC, selBSU,
		 selLLU, selASU, selAAU, selDARU, dataInstrBar, writeRegFile, addSubBar,
		 comparedsignedunsignedbar, ldIR, ldADR, ldPC, ldDr, ldByteSigned, ldHalfSigned,
		 load, setOne, setZero, startDARU, startDAWU, startMultiplyAAU, startDivideAAU,
		 signedSigned, signedUnsigned, unsignedUnsigned, selAAL, selAAH, muxCode, nBytes,
		 selLogic, selShift, pass, selAuipc, selP1, selTval_CSR, zeroCntCSR, mipCCLdDisable,
		 upCntCSR, dnCntCSR, selRomAddress, selCCMip_CSR, writeRegBank, selCause_CSR,
		 machineStatusAlterationPostCSR, userStatusAlterationPostCSR, selPC_CSR,
		 ldValueCSR, selCSRAddrFromInst, selP1CSR, selImmCSR, selReadWriteCSR, setCSR,
		 clrCSR, selCSR, selMepc_CSR, ldCntCSR, selInterruptAddressDirect,
		 selInterruptAddressVectored, ldFlags, zeroFlags, illegalInstrFlag, checkMisalignedDARU,
		 checkMisalignedDAWU, ecallFlag, machineStatusAlterationPreCSR, userStatusAlterationPreCSR,
		 selMedeleg_CSR, selMideleg_CSR, ldUser, ldMachine, mirrorUser, ldDelegation,
		 loadMieUieField, loadMieReg} <= 0;
        // FPU
        //  {selFPURegFile, fmaStart, fmaSel, selp1FPU, selp2FPU, rs1SignInject, rs1SignXOR, rs1SignNeg,
        //   rs3SignNeg, sgnSel, selP1WriteData, fpuCompSel, rs2SignNeg, addsubSel, mulSel} <= 0;
        //   minmaxSel <= 2'b00;

        case(p_state)
            `fetch: begin
                if(exceptionRaise)  begin
                    ldValueCSR <= 3'b111;
                    ldCntCSR <= 1'b1;
                    selMedeleg_CSR <= 1'b1;
                end
                else if (interruptRaise) begin
                    zeroCntCSR <= 1'b1;
                    mipCCLdDisable <= 1'b1;
                    selMideleg_CSR <= 1'b1;
                end
                else begin
                    nBytes <= 2'b11;
                    selPCJ <= 1'b1;
                    dataInstrBar <= 1'b0;
                    selPC <= 1'b1;
                    startDARU <= 1'b1; // ~instrMisalignedOut;
                    ldFlags <= 1'b1;
                    checkMisalignedDARU <= 1'b1;
                end
            end
            `getInstr: begin
                dataInstrBar <= 1'b0;
                if (completeDARU)
                    ldIR <= 1'b1;
                else
                    ldIR <= 1'b0;
            end
            `decode: begin
                ldFlags <= 1'b1;
                if (opcode == `Loads ||
                    opcode == `Stores ||
                    opcode == `Arithmetic ||
                    opcode == `ImmediateArithmetic ||
                    opcode == `JumpAndLink ||
                    opcode == `JumpAndLinkRegister ||
                    opcode == `Branch ||
                    opcode == `LoadUpperImmediate ||
                    opcode == `AddUpperImmediatePC ||
                    opcode == `SystemAndCSR
                )
                    illegalInstrFlag <= 1'b0;
                else
                    illegalInstrFlag <= 1'b1;

                if (opcode == `SystemAndCSR) begin
                    if (func3 == 3'b000 && (func12 == 12'h302 || func12 == 12'h002))
                        ldValueCSR          <= 3'b010;
                        ldCntCSR            <= 1'b1;
                    if (func3 != 3'b000)
                        selCSRAddrFromInst  <= 1'b1;
                end
            end
            `loadInstr1: begin
                muxCode <= `iTypeImm;
                ldADR <= 1'b1;
                selJL <= 1'b1;
                selP1 <= 1'b1;
                ldPC <= 1'b1;
                selI4 <= 1'b1;
                dataInstrBar <= 1'b1;
            end
            `loadInstr2: begin
                selADR <= 1'b1;
                startDARU <= ~loadMisalignedOut;
                ldFlags <= 1'b1;
                dataInstrBar <= 1'b1;
                nBytes <= {func3[1], (func3[1] || func3[0])};
            end
            `getData: begin
                ldByteSigned <= ~func3[2] && ~func3[1] && ~func3[0];
                ldHalfSigned <= ~func3[2] && ~func3[1] && func3[0]; // edited
                load <= func3[2] || func3[1];
                dataInstrBar <= 1'b1;
                if (completeDARU) begin
                    // selFPURegFile <= (opcode == `FPU_Load) ? 1'b1 : 1'b0; // FPU
                    writeRegFile <= 1'b1;
                    selDARU <= 1'b1;
                end
                else begin
                    writeRegFile <= 1'b0;
                    selDARU <= 1'b0;
                end
            end
            `storeInstr1: begin
                muxCode <= `sTypeImm;
                ldDr  <= 1'b1;
                ldADR <= 1'b1;
                selJL <= 1'b1;
                selP1 <= 1'b1;
                ldPC <= 1'b1;
                selI4 <= 1'b1;
                // selp2FPU <= (opcode == `FPU_Store) ? 1'b1 : 1'b0; // FPU
            end
            `storeInstr2: begin
                checkMisalignedDAWU <= 1'b1;
                ldFlags <= 1'b1;
                selADR <= 1'b1;
                startDAWU <= ~storeMisalignedOut;
                nBytes <= {func3[1] , (func3[1] || func3[0])};
            end
            `putData:
                ;
            `addSub: begin
                muxCode <= `iTypeImm;
                selImm <= ~opcode[5];
                selP1 <= 1'b1;
                selP2 <= opcode[5];
                addSubBar <= func7[5] && opcode[5];
                selASU <= 1'b1;
                writeRegFile <= 1'b1;
                ldPC <= 1'b1;
                selI4 <= 1'b1;
            end
            `compare: begin
                muxCode <= `iTypeImm;
                selImm <= ~opcode[5];
                selP1 <= 1'b1;
                selP2 <= opcode[5];
                comparedsignedunsignedbar <= ~func3[0];
                if (lt)
                    setOne <= 1'b1;
                else
                    setZero <= 1'b1;
                ldPC <= 1'b1;
                selI4 <= 1'b1;
            end
            `logical: begin
                muxCode <= `iTypeImm;
                selImm <= ~opcode[5];
                selP1 <= 1'b1;
                selP2 <= opcode[5];
                selLogic <= func3[1:0];
                selLLU <= 1'b1;
                writeRegFile <= 1'b1;
                ldPC <= 1'b1;
                selI4 <= 1'b1;
            end
            `shift: begin
                muxCode <= `iTypeImm;
                selImm <= ~opcode[5];
                selP1 <= 1'b1;
                selP2 <= opcode[5];
                selShift <= {func3[2], func7[5]};
                selBSU <= 1'b1;
                writeRegFile <= 1'b1;
                ldPC <= 1'b1;
                selI4 <= 1'b1;
            end
            `multiplyDivide1: begin
                ldFlags <= 1'b1;
                illegalInstrFlag <= dividedByZeroOut;
                selP1 <= 1'b1;
                selP2 <= 1'b1;
                startDivideAAU <= func3[2];
                startMultiplyAAU <= ~func3[2];
                if (~func3[2]) begin
                    if (func3[1:0] == 2'b00)
                        signedSigned <= 1'b1;
                    else if (func3[1:0] == 2'b01)
                        signedSigned <= 1'b1;
                    else if (func3[1:0] == 2'b10)
                        signedUnsigned <= 1'b1;
                    else if (func3[1:0] == 2'b11)
                        unsignedUnsigned <= 1'b1;
                end
                else if (func3[2]) begin
                    if (func3[1:0] == 2'b00 || func3[1:0] == 2'b10)
                        signedSigned <= 1'b1;
                    else if (func3[1:0] == 2'b01 || func3[1:0] == 2'b11)
                        unsignedUnsigned <= 1'b1;
                end
            end
            `multiplyDivide2: begin
                //edited start
                selP1 <= 1'b1;
				selP2 <= 1'b1;
				if (func3[2] == 1'b0)
                begin
					if (func3[1:0] == 2'b00)
						signedSigned <= 1'b1;
					else if (func3[1:0] == 2'b01)
						signedSigned <= 1'b1;
					else if (func3[1:0] == 2'b10)
						signedUnsigned <= 1'b1;
					else if (func3[1:0] == 2'b11)
						unsignedUnsigned <= 1'b1;
                end
				else if (func3[2] == 1'b1)
                begin
					if (func3[1:0] == 2'b00 || func3[1:0] == 2'b10)
						signedSigned <= 1'b1;
					else if (func3[1:0] == 2'b01 || func3[1:0] == 2'b11)
						unsignedUnsigned <= 1'b1;
                end
                // edited end
                if (completeAAU) begin
                    if (~func3[2]) begin
                        selAAL <= ~(func3[1] || func3[0]);
                        selAAH <= func3[1] || func3[0];
                    end
                    else if (func3[2]) begin
                        selAAL <= func3[1];
                        selAAH <= ~func3[1];
                    end
                end
                else begin
                    selAAL <= 1'b0;
                    selAAH <= 1'b0;
                end
                selAAU <= completeAAU;
                writeRegFile <= completeAAU;
                ldPC <= completeAAU;
                selI4 <= completeAAU;
            end
            `JAL: begin
                muxCode <= `jTypeImm;
                selInc4PC <= 1'b1;
                writeRegFile <= 1'b1;
                selPC <= 1'b1;
                selAdd <= 1'b1;
                ldPC <= 1'b1;
            end
            `JALR: begin
                    muxCode <= `iTypeImm;
                    selInc4PC <= 1'b1;
                    writeRegFile <= 1'b1;
                    selJL <= 1'b1;
                    ldPC <= 1'b1;
                    selP1 <= 1'b1;
                    selAdd <= 1'b1;
            end
            `conditionalBranch: begin
                muxCode <= `bTypeImm;
                selP1 <= 1'b1;
                selP2 <= 1'b1;
                comparedsignedunsignedbar <= ~func3[1];
                selPC <= 1'b1;
                ldPC <= 1'b1;
                if (func3[2] && ~func3[0]) //BLT, BLTU
                    if (lt)
                        selAdd <= 1'b1;
                    else
                        selI4 <= 1'b1;
                else if (func3[2] && func3[0]) //BGE, BGEU
                    if (gt || eq)
                        selAdd <= 1'b1;
                    else
                        selI4 <= 1'b1;
                else if (~func3[2] && ~func3[0]) //BEQ
                    if (eq)
                        selAdd <= 1'b1;
                    else
                        selI4 <= 1'b1;
                else if (~func3[2] && func3[0]) //BNE
                    if (~eq)
                        selAdd <= 1'b1;
                    else
                        selI4 <= 1'b1;
            end
            `LUI: begin
                muxCode <= `uTypeImm;
                selImm <= 1'b1;
                selASU <= 1'b1;
                writeRegFile <= 1'b1;
                ldPC <= 1'b1;
                selI4 <= 1'b1;
                pass <= opcode[5];
                // addSubBar <= ~opcode[5];
                addSubBar <= 1'b0;
                selAuipc <= ~opcode[5];
            end
            `CSR: begin
                selCSRAddrFromInst <= 1'b1;
                selCSR <= 1'b1 & validAccessCSR;
                writeRegFile <= 1'b1 & validAccessCSR;
                writeRegBank <= 1'b1 & (validAccessCSR & ~(readOnlyCSR));
                selP1CSR <= ~ (func3[2]) & (validAccessCSR & ~(readOnlyCSR));
                selImmCSR <= func3[2] & (validAccessCSR & ~(readOnlyCSR));
                selReadWriteCSR <= ~(func3[1]) & (validAccessCSR & ~(readOnlyCSR));
                setCSR <= ~(func3[0]) & (validAccessCSR & ~(readOnlyCSR));
                clrCSR <= (func3[1] & func3[0]) & (validAccessCSR & ~(readOnlyCSR));
                ldPC <= 1'b1 & (validAccessCSR & ~(readOnlyCSR));
                selI4 <= 1'b1 & (validAccessCSR & ~(readOnlyCSR));
                loadMieReg <= ldMieReg & validAccessCSR;
                loadMieUieField <= ldMieUieField & validAccessCSR;
                illegalInstrFlag <= ~(validAccessCSR);
                // illegalInstrFlag <= ~(validAccessCSR) | readOnlyCSR;
                ldFlags <= 1'b1;
            end
            `mirrorCSR: begin
                selCSRAddrFromInst <= 1'b1;
                selCSR <= 1'b1;
                writeRegBank <= 1'b1;
                selP1CSR <= ~ (func3[2]);
                selImmCSR <= func3[2];
                selReadWriteCSR <= ~(func3[1]);
                setCSR <= ~(func3[0]);
                clrCSR <= func3[1] & func3[0];
                mirrorUser <= 1'b1;
            end
            `retEpc: begin
                mirrorUser <= ~(mretOrUretBar);
                selRomAddress <= 1'b1;
                ldValueCSR <= 3'b100;
                ldCntCSR <= 1'b1;
            end
            `retReadMstatus: begin
                selMepc_CSR <= 1'b1;
                ldPC <= 1'b1;
                mirrorUser <= 1'b0;
                selRomAddress <= 1'b1;
            end
            `retUpdateMstatus: begin
                mirrorUser <= 1'b0;
                selRomAddress <= 1'b1;
                if (mretOrUretBar) begin
                        ldMachine <= previousPRV[0];
                        ldUser <= ~(previousPRV[0]);
                end
                else begin
                    ldMachine <= 1'b0;
                    ldUser <= 1'b1;
                end
                loadMieUieField <= ldMieUieField;
                machineStatusAlterationPostCSR <= mretOrUretBar;
                userStatusAlterationPostCSR <= ~(mretOrUretBar);
                writeRegBank <= 1'b1;
            end
            `retUpdateUstatus: begin
                selRomAddress <= 1'b1;
                mirrorUser <= 1'b1;
                machineStatusAlterationPostCSR <= mretOrUretBar;
                userStatusAlterationPostCSR <= ~(mretOrUretBar);
                writeRegBank <= 1'b1;
                zeroCntCSR <= 1'b1;
            end
            `ecall: begin
                ecallFlag <= 1'b1;
                ldFlags <= 1'b1;
            end
            `checkDelegation: begin
                selMideleg_CSR <= interruptRaise;
                selMedeleg_CSR <= exceptionRaise;
                ldDelegation <= 1'b1;
                mipCCLdDisable <= 1'b1;
            end
            `updateTrapValue: begin
                mirrorUser <= ~(delegationMode[0]);
                selRomAddress <= 1'b1;
                ldValueCSR <= 3'b001;
                ldCntCSR <= 1'b1;
                selTval_CSR <= 1'b1;
                writeRegBank <= 1'b1;
                mipCCLdDisable <= 1'b1;
            end
            `updateMip: begin
                mirrorUser <= 1'b0;
                selRomAddress <= 1'b1;
                selCCMip_CSR <= 1'b1;
                writeRegBank <= 1'b1;
                mipCCLdDisable <= 1'b1;
            end
            `updateUip: begin
                selRomAddress <= 1'b1;
                mirrorUser <= 1'b1;
                upCntCSR <= 1'b1;
                selCCMip_CSR <= 1'b1;
                writeRegBank <= 1'b1;
                mipCCLdDisable <= 1'b1;
            end
            `updateCause: begin
                mirrorUser <= ~(delegationMode[0]);
                selRomAddress <= 1'b1;
                upCntCSR <= 1'b1;
                selCause_CSR <= 1'b1;
                writeRegBank <= 1'b1;
                mipCCLdDisable <= 1'b1;
            end
            `updateEpc: begin
                mirrorUser <= ~(delegationMode[0]);
                selRomAddress <= 1'b1;
                upCntCSR <= 1'b1;
                selPC_CSR <= 1'b1;
                writeRegBank <= 1'b1;
                mipCCLdDisable <= 1'b1;
            end
            `readTvec1: begin
                mirrorUser <= ~(delegationMode[0]);
                selRomAddress <= 1'b1;
                mipCCLdDisable <= 1'b1;
            end
            `readTvec2: begin
                selRomAddress <= 1'b1;
                mirrorUser <= ~(delegationMode[0]);
                ldMachine <= delegationMode[0];
                ldUser <= ~(delegationMode[0]);
                upCntCSR <= 1'b1;
                ldPC <= 1'b1;
                mipCCLdDisable <= 1'b1;
                zeroFlags <= exceptionRaise;
                if (modeTvec == 2'b00)
                    selInterruptAddressDirect <= 1'b1;
                else if (modeTvec == 2'b01)
                    selInterruptAddressVectored <= 1'b1;
            end
            `readMstatus: begin
                mirrorUser <= 1'b0;
                selRomAddress <= 1'b1;
                mipCCLdDisable <= 1'b1;
            end
            `updateMstatus: begin
                mirrorUser <= 1'b0;
                selRomAddress <= 1'b1;
                loadMieUieField <= ldMieUieField;
                machineStatusAlterationPreCSR <= delegationMode[0];
                userStatusAlterationPreCSR <= ~(delegationMode[0]);
                writeRegBank <= 1'b1;
                mipCCLdDisable <= 1'b1;
            end
            `updateUstatus: begin
                mirrorUser <= 1'b1;
                selRomAddress <= 1'b1;
                mirrorUser <= 1'b1;
                machineStatusAlterationPreCSR <= delegationMode[0];
                userStatusAlterationPreCSR <= ~(delegationMode[0]);
                writeRegBank <= 1'b1;
                mipCCLdDisable <= 1'b1;
                ldMachine <= delegationMode[0];
                ldUser <= ~(delegationMode[0]);
            end
            // FPU - uncomment later
            //  `fpu_FusedMulAdd: begin
            //     fmaSel <= 1'b1;
            //     selFPURegFile <= 1'b1;
            //     rs1SignNeg <= (opcode[3:0] == 4'b1011) ? 1'b1 : // FNMSUB
            //                   (opcode[3:0] == 4'b1111);         // FNMADD
            //     rs3SignNeg <= (opcode[3:0] == 4'b0111) ? 1'b1 : // FMSUB
            //                   (opcode[3:0] == 4'b1111);         // FNMADD
            //     fmaStart <= 1'b1;
            // end
            // `fpu_FusedMulAdd2: begin
            //     fmaSel <= 1'b1;
            //     selFPURegFile <= 1'b1;
            //     rs1SignNeg <= (opcode[3:0] == 4'b1011) ? 1'b1 : // FNMSUB
            //                   (opcode[3:0] == 4'b1111);         // FNMADD
            //     rs3SignNeg <= (opcode[3:0] == 4'b0111) ? 1'b1 : // FMSUB
            //                   (opcode[3:0] == 4'b1111);         // FNMADD
            //     writeRegFile <= fmaReady;
            //     ldFlags <= fmaReady;
            //     ldPC <= fmaReady;
            //     selI4 <= fmaReady;
            // end
            // `fpu_AddSub: begin
            //     addsubSel <= 1'b1;
            //     selFPURegFile <= 1'b1;
            //     rs2SignNeg <= (func5 == 5'b00001) ? 1'b1 :  // FSUB
            //                   1'b0;                         // FADD
            //     fmaStart <= 1'b1;
            // end
            // `fpu_AddSub2: begin
            //     addsubSel <= 1'b1;
            //     selFPURegFile <= 1'b1;
            //     rs2SignNeg <= (func5 == 5'b00001) ? 1'b1 :  // FSUB
            //                   1'b0;                         // FADD
            //     writeRegFile <= fmaReady;
            //     ldFlags <= fmaReady;
            //     ldPC <= fmaReady;
            //     selI4 <= fmaReady;
            // end
            // `fpu_Mul: begin
            //     mulSel <= 1'b1;
            //     selFPURegFile <= 1'b1;
            //     fmaStart <= 1'b1;
            // end
            // `fpu_Mul2: begin
            //     mulSel <= 1'b1;
            //     selFPURegFile <= 1'b1;
            //     writeRegFile <= fmaReady;
            //     ldFlags <= fmaReady;
            //     ldPC <= fmaReady;
            //     selI4 <= fmaReady;
            // end
            // `fpu_Div: begin
            //     // future work
            //     ldPC <= 1'b1;
            //     selI4 <= 1'b1;
            // end
            // `fpu_SignInject: begin
            //     if(func3 == 3'b000)         // FSGNJ
            //     begin
            //         rs1SignInject <= 1'b1;
            //     end
            //     else if(func3 == 3'b001)    // FSGNJN
            //     begin
            //         rs1SignInject <= 1'b1;
            //         rs1SignNeg <= 1'b1;
            //     end
            //     else if(func3 == 3'b010)    // FSGNJX
            //     begin
            //         rs1SignXOR <= 1'b1;
            //     end
            //     writeRegFile <= 1'b1;
            //     selFPURegFile <= 1'b1;
            //     sgnSel <= 1'b1;

            //     ldFlags <= 1'b1;
            //     ldPC <= 1'b1;
            //     selI4 <= 1'b1;
            // end
            // `fpu_MinMax: begin
            //     minmaxSel <= {1'b1, func3[0]};
            //     writeRegFile <= 1'b1;
            //     selFPURegFile <= 1'b1;

            //     ldFlags <= 1'b1;
            //     ldPC <= 1'b1;
            //     selI4 <= 1'b1;
            // end
            // `fpu_Convert: begin

            // end
            // `fpu_Move: begin
            //     if(func5 == 5'b11100)       // FMV.X.W
            //     begin
            //         selp1FPU <= 1'b1;
            //         selP1WriteData <= 1'b1;
            //         selFPURegFile <= 1'b0;
            //         writeRegFile <= 1'b1;
            //     end
            //     else if(func5 == 5'b11110)  // FMV.W.X
            //     begin
            //         selp1FPU <= 1'b0;
            //         selP1WriteData <= 1'b1;
            //         selFPURegFile <= 1'b1;
            //         writeRegFile <= 1'b1;
            //     end

            //     ldFlags <= 1'b1;
            //     ldPC <= 1'b1;
            //     selI4 <= 1'b1;
            // end
            // `fpu_Compare: begin
            //     fpuCompSel <= 1'b1;
            //     selFPURegFile <= 1'b0;
            //     if(func3 == 3'b010)     // FEQ
            //     begin
            //         if (fpuEq)
            //             setOne <= 1'b1;
            //         else
            //             setZero <= 1'b1;
            //     end
            //     else if(func3 == 3'b001)    // FLT
            //     begin
            //         if (fpuLt)
            //             setOne <= 1'b1;
            //         else
            //             setZero <= 1'b1;
            //     end
            //     else if(func3 == 3'b000)    // FLE
            //     begin
            //         if (fpuLt | fpuEq)
            //             setOne <= 1'b1;
            //         else
            //             setZero <= 1'b1;
            //     end

            //     ldFlags <= 1'b1;
            //     ldPC <= 1'b1;
            //     selI4 <= 1'b1;
            // end
            default:
                {selPC, selI4, selP2, selPCJ, selADR, selJL, selImm, selAdd, selInc4PC, selBSU,
                 selLLU, selASU, selAAU, selDARU, dataInstrBar, writeRegFile, addSubBar,
                 comparedsignedunsignedbar, ldIR, ldADR, ldPC, ldDr, ldByteSigned, ldHalfSigned,
                 load, setOne, setZero, startDARU, startDAWU, startMultiplyAAU, startDivideAAU,
                 signedSigned, signedUnsigned, unsignedUnsigned, selAAL, selAAH, muxCode, nBytes,
                 selLogic, selShift, pass, selAuipc, selP1, selTval_CSR, zeroCntCSR, mipCCLdDisable,
                 upCntCSR, dnCntCSR, selRomAddress, selCCMip_CSR, writeRegBank, selCause_CSR,
                 machineStatusAlterationPostCSR, userStatusAlterationPostCSR, selPC_CSR,
                 ldValueCSR, selCSRAddrFromInst, selP1CSR, selImmCSR, selReadWriteCSR, setCSR,
                 clrCSR, selCSR, selMepc_CSR, ldCntCSR, selInterruptAddressDirect,
                 selInterruptAddressVectored, ldFlags, zeroFlags, illegalInstrFlag, checkMisalignedDARU,
                 checkMisalignedDAWU, ecallFlag, machineStatusAlterationPreCSR, userStatusAlterationPreCSR,
                 selMedeleg_CSR, selMideleg_CSR, ldUser, ldMachine, mirrorUser, ldDelegation,
                 loadMieUieField, loadMieReg} <= 0;
        endcase
    end

endmodule
