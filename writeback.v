module writeback (
    input clk,
    input regwriteW,
    input [1:0] wbselW,
    input [31:0] data_readW, ALUresW, pc4W,

    output [31:0] resultW
);
    assign resultW = (wbselW == 2'b00) ? data_readW :
                    (wbselW == 2'b01) ? ALUresW :
                    (wbselW == 2'b10) ? pc4W : 32'b0;
endmodule