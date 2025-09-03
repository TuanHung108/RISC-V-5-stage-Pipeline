`timescale 1ns/1ps

module tb_execute;
    reg clk, rst_n;
    reg regwriteE, memrwE;
    reg [1:0] wbselE;
    reg [2:0] ALUselE;
    reg aselE, bselE;
    reg [1:0] forwardAE, forwardBE;
    reg [31:0] resultW;
    reg [31:0] rd1E, rd2E;
    reg [31:0] imm_exE, pcE, pc4E;
    reg [4:0] rs1E, rs2E, rdE;

    wire regwriteM, memrwM;
    wire [1:0] wbselM;
    wire [31:0] pc4M;
    wire [4:0] rdM;
    wire [31:0] ALUresM, data_writeM;

    execute uut (
        .clk(clk), .rst_n(rst_n),
        .regwriteE(regwriteE), .memrwE(memrwE),
        .wbselE(wbselE),
        .ALUselE(ALUselE),
        .aselE(aselE), .bselE(bselE),
        .forwardAE(forwardAE), .forwardBE(forwardBE),
        .resultW(resultW),
        .rd1E(rd1E), .rd2E(rd2E),
        .imm_exE(imm_exE), .pcE(pcE), .pc4E(pc4E),
        .rs1E(rs1E), .rs2E(rs2E), .rdE(rdE),
        .regwriteM(regwriteM), .memrwM(memrwM),
        .wbselM(wbselM),
        .pc4M(pc4M), .rdM(rdM),
        .ALUresM(ALUresM), .data_writeM(data_writeM)
    );

    initial begin
        clk= 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 0;
        regwriteE = 0; memrwE = 0; wbselE = 0;
        ALUselE = 3'b000;
        aselE = 0; bselE = 0;
        forwardAE = 2'b00; forwardBE = 2'b00;
        resultW = 0;
        rd1E = 0; rd2E = 0; imm_exE = 0;
        pcE = 0; pc4E = 0;
        rs1E = 0; rs2E = 0; rdE = 0;

        #12 rst_n = 1; // release reset

        // Test 1: ADD (10 + 20)
        #10;
        regwriteE = 1;
        wbselE = 2'b01;
        ALUselE = 3'b000; // add
        rd1E = 32'd10;
        rd2E = 32'd20;
        rdE = 5'd1;
        pc4E = 32'h4;

        // Test 2: SUB (50 - 30)
        #10;
        ALUselE = 3'b001;
        rd1E = 32'd50;
        rd2E = 32'd30;
        rdE = 5'd2;
        pc4E = 32'h8;

        // Test 3: AND (0xF0 & 0x0F)
        #10;
        ALUselE = 3'b010;
        rd1E = 32'hF0;
        rd2E = 32'h0F;
        rdE = 5'd3;

        // Test 4: OR (0xF0 | 0x0F)
        #10;
        ALUselE = 3'b011;
        rd1E = 32'hF0;
        rd2E = 32'h0F;
        rdE = 5'd4;

        // Test 5: XOR (0xAA ^ 0x55)
        #10;
        ALUselE = 3'b100;
        rd1E = 32'hAA;
        rd2E = 32'h55;
        rdE = 5'd5;

        #50 $finish;
    end

    // Monitor
    initial begin
        $monitor("t=%0t | ALUselE=%b rd1E=%d rd2E=%d | ALUresM=%d rdM=%d regwriteM=%b",
                 $time, ALUselE, rd1E, rd2E, ALUresM, rdM, regwriteM);
    end

endmodule