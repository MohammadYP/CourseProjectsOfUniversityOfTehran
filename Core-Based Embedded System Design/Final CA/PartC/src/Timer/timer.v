module timer (
    input clk,
    input rst,
    input read,
    input write,
    input [31:0] IRQTime,
    output [31:0] dataOut,
    output IRQ
);
    wire IRQSignal;
    wire readPulse;
    wire [31:0] IRQSavedTime;
    reg [31:0] Time;
    always @(posedge clk , posedge rst)begin
        if (rst)
            Time <= 0;
        else if(write)
            Time <= 0;
        else 
            Time <= Time + 1'b1;
    end
    Timerregister #(.N(32)) IRQTimeReg(
        .in(IRQTime),
        .clk(clk),
        .rst(rst),
        .clear(1'b0),
        .en(write),
        .out(IRQSavedTime)
    );

Timerregister #(
    .N(1)
    ) IRQReg(
        .in(1'b1),
        .clk(clk),.rst(rst),
        .en(IRQSignal&~write),
        .clear(readPulse),
        .out(IRQ)
    );

    One_Pulser readPulser (
        .clk(clk),
        .rst(rst),
        .sigIn(read),
        .sigOut(readPulse)
    );

    assign IRQSignal = (Time == IRQTime) ? 1'b1: 1'b0;
    assign dataOut = {31'b0,IRQ};

endmodule

module Timerregister # (parameter N = 32)(
    input [N-1:0] in,
    input clk,
    input rst,
    input clear,
    input en,
    output reg[N-1:0] out
);
    always@(posedge clk, posedge rst)begin
        if(rst)
            out <= 0;
        else if (clear)
            out <= 0;
        else if(en)
            out <= in;
        else
            out <= out;
    end

endmodule

module One_Pulser (clk, sigIn, rst, sigOut);
  input clk, sigIn, rst;
  output sigOut;

  reg [1:0] ns,ps;
	
  parameter[1:0]
  A = 0, B = 1, C = 2;
	
  always@(ps, sigIn) begin
    ns = A; 
    case(ps)
      A: ns = sigIn ? B : A;
      B: ns = sigIn ? B : C; 
      C: ns = A;
   endcase
  end
	
  assign sigOut = (ps == C)? 1'b1:1'b0;
	
  always@(posedge clk, posedge rst) begin
    if(rst) 
      ps <= A;
    else 
      ps <= ns; 
    end
endmodule
