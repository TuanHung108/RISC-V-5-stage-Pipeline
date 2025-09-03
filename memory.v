module memory (
    input clk, rst_n,
    input regwriteM, memrwM,
    input [1:0] wbselM,
    input [4:0] rdM,
    input [31:0] data_writeM, ALUresM, pc4M,

    output regwriteW,
    output [1:0] wbselW,
    output [4:0] rdW,
    output [31:0] ALUresW, data_readW, pc4W
);
    wire [31:0] data_readM;

    // Declaration of register
    reg [31:0] ALUresM_reg, data_readM_reg, pc4M_reg;
    reg [4:0] rdM_reg;
    reg [1:0] wbselM_reg;
    reg regwriteM_reg;


    // Data Memory
    reg [31:0] dmem [0:255];         
    wire [7:0] addr = ALUresM[9:2]; 

    always @(posedge clk) begin
        if (memrwM) dmem[addr] <= data_writeM; // ghi
    end

    assign data_readM = dmem[addr];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ALUresM_reg <= 32'b0;
            data_readM_reg <= 32'b0;
            rdM_reg <= 5'b0;
            wbselM_reg <= 2'b0;
            regwriteM_reg <= 1'b0;
            pc4M_reg <= 32'b0;
        end
        else begin
            ALUresM_reg <= ALUresM;
            data_readM_reg <= data_readM;
            rdM_reg <= rdM;
            wbselM_reg <= wbselM;
            regwriteM_reg <= regwriteM;
            pc4M_reg <= pc4M;
        end
    end

    assign ALUresW = ALUresM_reg;
    assign data_readW = data_readM_reg;
    assign rdW = rdM_reg;
    assign wbselW = wbselM_reg;
    assign regwriteW = regwriteM_reg;
    assign pc4W = pc4M_reg;

endmodule