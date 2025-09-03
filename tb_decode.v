`timescale 1ns/1ps

module tb_decode;
    reg clk, rst_n;
    reg regwriteW;
    reg [4:0] rdW;
    reg [31:0] instrD, pcD, pc4D, resultW;

    wire regwriteE, memrwE;
    wire aselE, bselE;
    wire [1:0] wbselE;
    wire [2:0] ALUselE;
    wire [4:0] rdE, rs1E, rs2E;
    wire [31:0] rd1E, rd2E, imm_exE, pcE, pc4E;

    // DUT
    decode uut (
        .clk(clk), .rst_n(rst_n),
        .regwriteW(regwriteW),
        .rdW(rdW),
        .instrD(instrD), .pcD(pcD), .pc4D(pc4D),
        .resultW(resultW),

        .regwriteE(regwriteE), .memrwE(memrwE),
        .aselE(aselE), .bselE(bselE),
        .wbselE(wbselE), .ALUselE(ALUselE),
        .rdE(rdE), .rs1E(rs1E), .rs2E(rs2E),
        .rd1E(rd1E), .rd2E(rd2E),
        .imm_exE(imm_exE),
        .pcE(pcE), .pc4E(pc4E)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0;
        regwriteW = 0; rdW = 0; instrD = 0; pcD = 0; pc4D = 4; resultW = 0;
        #12 rst_n = 1;

        // ADDI x1, x0, 10
        instrD = {20'd10, 5'd0, 3'b000, 5'd1, 7'b0010011};
        #10;

        // ADD x2, x1, x1
        instrD = {7'b0000000, 5'd1, 5'd1, 3'b000, 5'd2, 7'b0110011};
        #10;

        // LW x3, 0(x1)
        instrD = {12'd0, 5'd1, 3'b010, 5'd3, 7'b0000011};
        #10;

        // SW x3, 4(x1)
        instrD = {7'b0000000, 5'd3, 5'd1, 3'b010, 5'd1, 7'b0100011};
        #10;

        // JAL x1, 16
        instrD = {20'd16, 5'd1, 7'b1101111};
        #10;

        $stop;
    end
endmodule
