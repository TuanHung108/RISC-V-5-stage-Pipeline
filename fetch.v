module fetch (
    input clk, rst_n,
    input pcselE,
    input [31:0] pcTargetE,
    input [31:0] instrF,
    input stallF, stallD,
    input flushD,

    output [31:0] instrD,
    output [31:0] pc4D, pcD
);
    wire [31:0] pc4F, pc_next;
    reg [31:0] pcF;

    assign pc4F = pcF + 32'd4;
    assign pc_next = pcselE ? pcTargetE : pc4F;


    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pcF <= 32'b0;
        else begin
            if(!stallF) pcF <= pc_next;
            else pcF <= pcF;
        end
    end

    // Declaration of register
    reg [31:0] instrF_reg;
    reg [31:0] pcF_reg, pc4F_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instrF_reg <= 32'b0;
            pcF_reg <= 32'b0;
            pc4F_reg <= 32'b0;
        end
        else begin
            if(flushD && !stallD) begin
                nstrF_reg <= 32'b0;
                pcF_reg <= 32'b0;
                pc4F_reg <= 32'b0;
            end else if(!stallD) begin
                instrF_reg <= instrF;
                pcF_reg <= pcF;
                pc4F_reg <= pc4F;
            end else begin
                instrF_reg <= instrF_reg;
                pcF_reg <= pcF_reg;
                pc4F_reg <= pc4F_reg;
            end
            
        end
    end

    assign instrD = instrF_reg;
    assign pcD = pcF_reg;
    assign pc4D = pc4F_reg;

endmodule 
