module registerStatus(
    input clk,
    input rst,

    //read for decode
    input   [4:0]   regp1,
    output  [3:0]   P_index_p1,

    input   [4:0]   regp2,
    output  [3:0]   P_index_p2,

    //write from decode
    input           update,
    input   [4:0]   regdest,
    input   [3:0]   P_index_wr,

    //commit update
    input           clear,
    input   [4:0]   regclear,
    output  [3:0]   checkP_index
);

reg [3:0] regstat [0:31];

assign P_index_p1   = regstat[regp1];
assign P_index_p2   = regstat[regp2];
assign checkP_index = regstat[regclear];

integer i;

always @(posedge clk , posedge rst) begin
    if(rst) begin
        for(i = 0; i < 32; i = i + 1) begin
            regstat[i] <= 0;
        end
    end
    else begin
        if ((regdest == regclear) && update && clear && (regdest != 5'b00000))
            regstat[regdest] <= P_index_wr;
        else begin
            if(update && (regdest != 5'b00000))
                regstat[regdest] <= P_index_wr;
            if(clear)
                regstat[regclear] <= 4'b0000;
        end
    end
end

endmodule