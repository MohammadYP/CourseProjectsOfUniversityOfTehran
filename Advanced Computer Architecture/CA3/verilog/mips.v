module mips(
	clk,
	rst,
);
	input clk,rst;

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
		.opcode(opcode)
	);
endmodule
