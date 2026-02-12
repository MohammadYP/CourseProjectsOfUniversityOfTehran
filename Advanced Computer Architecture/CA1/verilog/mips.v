module mips(
	clk,
	rst,
	out1,
	out2
);
	input clk,rst;
	output wire [31:0] out1,out2;

	wire [5:0] opcode,func;
	wire [1:0] RegDst,Jmp;
	wire DataC,Regwrite,AluSrc,Branch,BranchNe,MemRead,MemWrite,MemtoReg;
	wire [4:0] AluOperation;

	cntrl CU(
		.opcode(opcode),
		.func(func),
		.RegDst(RegDst),
		.Jmp(Jmp),
		.DataC(DataC),
		.Regwrite(Regwrite),
		.AluSrc(AluSrc),
		.Branch(Branch),
		.BranchNe(BranchNe),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.MemtoReg(MemtoReg),
		.AluOperation(AluOperation)
	);

	data_path DP(
		.clk(clk),
		.rst(rst),
		.RegDst(RegDst),
		.Jmp(Jmp),
		.DataC(DataC),
		.RegWrite(Regwrite),
		.AluSrc(AluSrc),
		.Branch(Branch),
		.BranchNe(BranchNe),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.MemtoReg(MemtoReg),
		.AluOperation(AluOperation),
		.func(func),
		.opcode(opcode),
		.out1(out1),
		.out2(out2)
	);
endmodule
