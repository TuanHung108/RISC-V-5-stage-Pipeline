`timescale 1ns/1ps

module tb_memory;

    reg clk, rst_n;
    reg regwriteM, memrwM;
    reg [1:0] wbselM;
    reg [4:0] rdM;
    reg [31:0] data_writeM, ALUresM, pc4M;

    wire regwriteW;
    wire [1:0] wbselW;
    wire [4:0] rdW;
    wire [31:0] ALUresW, data_readW, pc4W;

    // Instantiate DUT
    memory uut (
        .clk(clk), .rst_n(rst_n),
        .regwriteM(regwriteM), .memrwM(memrwM),
        .wbselM(wbselM), .rdM(rdM),
        .data_writeM(data_writeM), .ALUresM(ALUresM), .pc4M(pc4M),
        .regwriteW(regwriteW), .wbselW(wbselW), .rdW(rdW),
        .ALUresW(ALUresW), .data_readW(data_readW), .pc4W(pc4W)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Stimulus
    initial begin
        // init
        rst_n = 0;
        regwriteM = 0; memrwM = 0; wbselM = 2'b00;
        rdM = 0; data_writeM = 0; ALUresM = 0; pc4M = 0;

        #12 rst_n = 1; // release reset

        // --- Test 1: Write 32'hA5A5A5A5 to dmem[1] ---
        #10;
        regwriteM = 1; memrwM = 1; wbselM = 2'b01;
        rdM = 5'd1;
        data_writeM = 32'hA5A5A5A5;
        ALUresM = 32'h0000_0004; // addr = 1 (ALUresM[9:2])
        pc4M = 32'h4;

        // --- Test 2: Write 32'h12345678 to dmem[2] ---
        #10;
        rdM = 5'd2;
        data_writeM = 32'h12345678;
        ALUresM = 32'h0000_0008; // addr = 2
        pc4M = 32'h8;

        // --- Test 3: Read dmem[1] ---
        #10;
        memrwM = 0; // read mode
        rdM = 5'd3;
        ALUresM = 32'h0000_0004; // addr = 1
        pc4M = 32'hC;

        // --- Test 4: Read dmem[2] ---
        #10;
        rdM = 5'd4;
        ALUresM = 32'h0000_0008; // addr = 2
        pc4M = 32'h10;

        #50 $finish;
    end

    // Monitor
    initial begin
        $monitor("t=%0t | memrwM=%b ALUresM=%h data_writeM=%h | data_readW=%h | rdW=%d regwriteW=%b pc4W=%h",
                 $time, memrwM, ALUresM, data_writeM,
                 data_readW, rdW, regwriteW, pc4W);
    end

endmodule
