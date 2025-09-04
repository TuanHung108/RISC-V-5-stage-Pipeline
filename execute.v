module execute (
    input clk, rst_n,
    input regwriteE, memrwE, 
    input brunE, branchE, jumpE,
    input [2:0] funct3E,
    input bselE,
    input [1:0] wbselE,
    input [2:0] ALUselE,
    input [1:0] forwardAE, forwardBE,
    input [4:0] rs1E, rs2E, rdE,
    input [31:0] resultW,
    input [31:0] rd1E, rd2E,
    input [31:0] imm_exE, pcE, pc4E,

    output regwriteM, memrwM, 
    output pcselE,
    output [1:0] wbselM,
    output [31:0] pc4M, pcTargetE,
    output [4:0] rdM,
    output [31:0] ALUresM, data_writeM
);

    // Declaration of register
    reg regwriteE_reg;
    reg memrwE_reg;
    reg [1:0] wbselE_reg;
    reg [4:0] rdE_reg;
    reg [31:0] rs2E_reg, ALUresE_reg, pc4E_reg;

    // ALU logic
    wire [31:0] src_B_inter;
    wire [31:0] src_A, src_B;
    reg [31:0] ALUresE;

    assign src_A = (forwardAE == 2'b00) ? rd1E : 
                        (forwardAE == 2'b01) ? resultW :
                        (forwardAE == 2'b10) ? ALUresM : 32'b0;
    assign src_B_inter = (forwardBE == 2'b00) ? rd2E : 
                        (forwardBE == 2'b01) ? resultW :
                        (forwardBE == 2'b10) ? ALUresM : 32'b0; 

    assign src_B = bselE ? imm_exE : src_B_inter;

    assign pcTargetE = pcE + imm_exE;
    localparam ADD = 3'b000,
                SUB = 3'b001,
                AND = 3'b010,
                OR = 3'b011,
                XOR = 3'b100;
    
    
    always @(ALUselE, src_A, src_B) begin
        ALUresE = 32'b0;
        case (ALUselE)
            ADD: ALUresE = src_A + src_B;
            SUB: ALUresE = src_A - src_B;
            AND: ALUresE = src_A & src_B;
    
            OR: ALUresE = src_A | src_B;
            XOR: ALUresE = src_A ^ src_B;
            default: ALUresE  = 32'b0;
        endcase
    end



    // Branch Comp
    wire breqE, brltE;
    wire [31:0] cmpA, cmpB;
    reg conditionE;

    assign cmpA = src_A;
    assign cmpB = src_B_inter;

    assign breqE = (cmpA == cmpB);
    assign brltE = brunE ? (cmpA < cmpB) : ($signed(cmpA) < $signed(cmpB));

    always @(funct3E, breqE, brltE) begin
        case (funct3E)
            3'b000: conditionE = breqE;
            3'b001: conditionE = !breqE;
            3'b100: conditionE = brltE;
            3'b101: conditionE = !brltE;
            default: conditionE = 1'b0;
        endcase
    end

    assign pcselE = (branchE & conditionE) | jumpE;

    // Register logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            regwriteE_reg <= 1'b0;
            memrwE_reg <= 1'b0;
            wbselE_reg <= 2'b0;
            ALUresE_reg <= 32'b0;
            rs2E_reg <= 32'b0;
            rdE_reg <= 5'b0;
            pc4E_reg <= 32'b0;
        end
        else begin
            regwriteE_reg <= regwriteE;
            memrwE_reg <= memrwE;
            wbselE_reg <= wbselE;
            ALUresE_reg <= ALUresE;
            rs2E_reg <= rs2E;
            rdE_reg <= rdE;
            pc4E_reg <= pc4E;
        end
    end

    assign regwriteM = regwriteE_reg;
    assign memrwM = memrwE_reg;
    assign wbselM = wbselE_reg;
    assign ALUresM = ALUresE_reg;
    assign rdM = rdE_reg;
    assign data_writeM = rs2E_reg;
    assign pc4M = pc4E_reg;

endmodule


