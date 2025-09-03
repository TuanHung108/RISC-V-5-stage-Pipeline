`timescale 1ns/1ps

module tb_writeback;

    reg clk;
    reg regwriteW;
    reg [1:0] wbselW;
    reg [31:0] data_readW, ALUresW, pc4W;

    wire [31:0] resultW;

    // Instantiate DUT
    writeback uut (
        .clk(clk),
        .regwriteW(regwriteW),
        .wbselW(wbselW),
        .data_readW(data_readW),
        .ALUresW(ALUresW),
        .pc4W(pc4W),
        .resultW(resultW)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // init
        regwriteW = 0;
        wbselW = 2'b00;
        data_readW = 32'h11111111;
        ALUresW   = 32'h22222222;
        pc4W      = 32'h33333333;

        // test wbselW = 00 -> chọn data_readW
        #10 wbselW = 2'b00; regwriteW = 1;
        #10;

        // test wbselW = 01 -> chọn ALUresW
        #10 wbselW = 2'b01;
        #10;

        // test wbselW = 10 -> chọn pc4W
        #10 wbselW = 2'b10;
        #10;

        // test wbselW = 11 -> output = 0
        #10 wbselW = 2'b11;
        #10;

        $finish;
    end

    // Monitor
    initial begin
        $monitor("t=%0t | wbselW=%b | data_readW=%h ALUresW=%h pc4W=%h | resultW=%h",
                  $time, wbselW, data_readW, ALUresW, pc4W, resultW);
    end

endmodule
