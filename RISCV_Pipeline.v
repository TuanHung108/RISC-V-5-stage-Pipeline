module riscv (
    input clk,
    input rst_n
);

    wire [31:0] instrF;
    wire memrwM;
    wire [31:0] ALUresM, data_writeM, data_readM, pcF;

    // IMEM
    imem #(.COL(32), .ROW(256)) imem_inst (
        .pc (pcF),
        .ins(instrF)
    );

    data_memory data_memory_inst (
        .clk        (clk),
        .memrw      (memrwM),
        .address    (ALUresM),
        .data_write (data_writeM),
        .data_read  (data_readM)
    );

    top top_inst (
        .clk(clk),
        .rst_n(rst_n),
        .instrF(instrF),
        .dmem_we(memrwM),
        .dmem_addr(ALUresM),
        .dmem_wdata(data_writeM),

        .data_readM(data_readM),
        .pcF(pcF)
    );

endmodule