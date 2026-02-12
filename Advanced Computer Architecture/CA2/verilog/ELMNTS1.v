`timescale 1ns/1ns

module mux3_to_1 #(parameter num_bit)(input [num_bit-1:0]data1,data2,data3, input [1:0]sel,output [num_bit-1:0]out);
	
	assign out=~sel[1] ? (sel[0] ? data2 : data1 ) : data3;	
endmodule

module mux2_to_1 #(parameter num_bit)(input [num_bit-1:0]data1,data2, input sel,output [num_bit-1:0]out);
	
	assign out=~sel?data1:data2;
endmodule

module sign_extension(input [15:0]primary, output [31:0] extended);

	assign extended=$signed(primary);
endmodule

module shl2 #(parameter num_bit)(input [num_bit-1:0]adr, output [num_bit-1:0]sh_adr);

	assign sh_adr=adr<<2;
endmodule


`define OP_ADD    5'd0
`define OP_ADDU   5'd1
`define OP_SUB    5'd2
`define OP_SUBU   5'd3
`define OP_AND    5'd4
`define OP_OR     5'd5
`define OP_XOR    5'd6
`define OP_NOR    5'd7
`define OP_SLT    5'd8
`define OP_SLTU   5'd9
`define OP_SLL    5'd10
`define OP_SRL    5'd11
`define OP_SRA    5'd12
`define OP_SLLV   5'd13
`define OP_SRLV   5'd14
`define OP_SRAV   5'd15
`define OP_LUI    5'd16

module ALU(
    input  [31:0] A,
    input  [31:0] B,
    input  [4:0]  shamt,
    input  [4:0]  AluOperation,
    output reg [31:0] Result,
    output Zero
);

assign Zero = (Result == 0);

always @(A or B or shamt or AluOperation) begin
    case (AluOperation)

        `OP_ADD:    Result = A + B;
        `OP_ADDU:   Result = A + B;
        `OP_SUB:    Result = A - B;
        `OP_SUBU:   Result = A - B;

        `OP_AND:    Result = A & B;
        `OP_OR:     Result = A | B;
        `OP_XOR:    Result = A ^ B;
        `OP_NOR:    Result = ~(A | B);

        `OP_SLT:    Result = ($signed(A) < $signed(B));
        `OP_SLTU:   Result = (A < B);

        `OP_SLL:    Result = B << shamt;
        `OP_SRL:    Result = B >> shamt;
        `OP_SRA:    Result = $signed(B) >>> shamt;

        `OP_SLLV:   Result = B << A[4:0];
        `OP_SRLV:   Result = B >> A[4:0];
        `OP_SRAV:   Result = $signed(B) >>> A[4:0];

        `OP_LUI:    Result = B << 16;

        default:    Result = 32'd0;
    endcase
end

endmodule



module adder(input [31:0] data1,data2, output [31:0]sum);
	
	wire co;
	assign {co,sum}=data1+data2;
endmodule


module reg_file(
	input clk,
	input rst,
	input RegWrite,
	input [4:0] read_reg1,
	input [4:0] read_reg2,
	input [4:0] write_reg,
	input [31:0] write_data,
	output [31:0] read_data1,
	output [31:0] read_data2
);

	reg [31:0] register[0:31];
	integer i;
	always@(posedge clk, posedge rst) begin
		if(rst) begin
			for(i=0;i<32;i=i+1) register[i]<=32'b0;
		end
		else begin
			if(RegWrite) register[write_reg]<=write_data;
		end
	end
	assign read_data1=register[read_reg1];
	assign read_data2=register[read_reg2];
endmodule

module inst_memory(input clk,rst,input [31:0]adr,output [31:0]instruction);

	reg [31:0]mem_inst[0:255];
	initial begin
		$readmemb("instructionmemory.txt",mem_inst);
  	end
	assign instruction=mem_inst[adr>>2];
endmodule

module data_memory(input clk,rst,mem_read,mem_write,input [31:0]adr,write_data,output reg[31:0]read_data,
		   output [31:0] out1,out2);

	reg [31:0]mem_data[0:511];
	integer i,f;

	initial begin
		$readmemb("datamemory.txt",mem_data);
  	end

	always@(posedge clk) begin
		if(mem_write) mem_data[adr>>2]<=write_data;
	end

	always@(mem_read,adr) begin
		if(mem_read) read_data<=mem_data[adr>>2];
		else read_data<=32'b0;	
	end
	
	initial begin
		$writememb("datamemory.txt",mem_data); 
  	end

	initial begin
  		f = $fopen("datamemory.txt","w");
		for(i=0;i<512;i=i+1) begin
		$fwrite(f,"%b\n",mem_data[i]);
		end
		$fclose(f);  
	end

	assign out1=mem_data[500];
	assign out2=mem_data[501];
	
endmodule

module pc(
	input clk,
	input rst,
	input stall,
	input [31:0]in,
	output reg[31:0]out
);

	always @(posedge clk,rst) begin
		if(rst) 
			out<=32'b0;
		else if(~stall)
			out<=in;
	end
endmodule

module PipeReg #(
	parameter SIZE
) (
	input clk,
	input rst,
	input flush,
	input stall,
	input [SIZE-1 : 0] in,
	output reg  [SIZE-1 : 0] out
);

	always @(posedge clk, posedge rst) begin
		if(rst == 1'b1)
			out = 0;
		else if(flush)
			out = 0;
		else if(~stall)
			out = in;
	end
	
endmodule