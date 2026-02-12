module Forwarding_Unit(
    input  [4:0] rs_D,
    input  [4:0] rt_D,

    input        RegWrite_E,
    input        MemtoReg_E,
    input  [4:0] write_reg_E,

    input        RegWrite_M,
    input        MemtoReg_M,
    input  [4:0] write_reg_M,

    input        RegWrite_W,
    input        DataC_W,
    input  [4:0] write_reg_W,

    output reg [2:0] ASrc,
    output reg [2:0] BSrc
);

always @(*) begin
    ASrc = 3'b000;
    BSrc = 3'b000;

    if (RegWrite_E && (write_reg_E != 5'd0) && (write_reg_E == rs_D) && (MemtoReg_E == 1'b0)) ASrc = 3'b001;
    if (RegWrite_E && (write_reg_E != 5'd0) && (write_reg_E == rt_D) && (MemtoReg_E == 1'b0)) BSrc = 3'b001;

    if ((ASrc == 3'b000) && RegWrite_M && (write_reg_M != 5'd0) && (write_reg_M == rs_D) && (MemtoReg_M == 1'b1)) ASrc = 3'b010;
    if ((BSrc == 3'b000) && RegWrite_M && (write_reg_M != 5'd0) && (write_reg_M == rt_D) && (MemtoReg_M == 1'b1)) BSrc = 3'b010;

    if ((ASrc == 3'b000) && RegWrite_M && (write_reg_M != 5'd0) && (write_reg_M == rs_D) && (MemtoReg_M == 1'b0)) ASrc = 3'b011;
    if ((BSrc == 3'b000) && RegWrite_M && (write_reg_M != 5'd0) && (write_reg_M == rt_D) && (MemtoReg_M == 1'b0)) BSrc = 3'b011;

    if ((ASrc == 3'b000) && RegWrite_W && (write_reg_W != 5'd0) && (write_reg_W == rs_D)) ASrc = 3'b100;
    if ((BSrc == 3'b000) && RegWrite_W && (write_reg_W != 5'd0) && (write_reg_W == rt_D)) BSrc = 3'b100;

    if ((ASrc == 3'b000) && DataC_W && (rs_D == 5'd31)) ASrc = 3'b101;
    if ((BSrc == 3'b000) && DataC_W && (rt_D == 5'd31)) BSrc = 3'b101;
end

endmodule
