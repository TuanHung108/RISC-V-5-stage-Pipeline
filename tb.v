`timescale 1ns/1ps

module riscv_tb;
    reg clk;
    reg rst_n;

    // wire kết nối giữa CPU và IMEM
    wire [31:0] pcF;
    wire [31:0] instrF;

    // DUT (CPU core)
    riscv dut (
        .clk   (clk),
        .rst_n (rst_n),
        .instrF(instrF),
        .pcF   (pcF)
    );

    // Instruction memory instance
    imem imem_inst (
        .pc (pcF),
        .ins(instrF)
    );

    // clock 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // reset + stimulus
    initial begin
        rst_n = 0;
        #20 rst_n = 1;

        // chạy mô phỏng 500ns
        #500;
        $finish;
    end

    // quan sát waveform hoặc in log
    initial begin
        $monitor("t=%0t pcF=%h instrF=%h ALUresM=%h memrwM=%b dataW=%h dataR=%h",
                  $time,
                  pcF,
                  instrF,
                  dut.ALUresM,
                  dut.memrwM,
                  dut.data_writeM,
                  dut.data_readM);
    end
endmodule
