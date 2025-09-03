module decode (
    input clk, rst_n,
    input regwriteW,
//    input [2:0] immselD,
    input [4:0] rdW,
    input [31:0] instrD, pcD, pc4D,
    input [31:0] resultW,

    output regwriteE, memrwE,
    output aselE, bselE,
    output [1:0] wbselE,
    output [2:0] ALUselE,
    output [4:0] rdE, rs1E, rs2E,
    output [31:0] rd1E, rd2E,
    output [31:0] imm_exE,
    output [31:0] pcE, pc4E
);

    // Declaration of register
    reg regwriteD_reg, memrwD_reg, aselD_reg, bselD_reg;
    reg [1:0] wbselD_reg;
    reg [2:0] aluselD_reg;
    reg [31:0] pcD_reg, pc4D_reg;
    reg [31:0] rd1D_reg, rd2D_reg, imm_exD_reg;
    reg [4:0] rdD_reg, rs1D_reg, rs2D_reg;


    // Control Unit
    // PCSelD_ImmSelD_RegWriteD_brun_ASelD_BSelD_ALUSelD_MemRWD_WBSelD
    wire pcselD, regwriteD, memrwD;
    wire aselD, bselD;
    wire [1:0] wbselD;
    wire [2:0] immselD, aluselD;
    wire [4:0] rs1D, rs2D, rdD;

    wire [6:0] opcode = instrD[6:0];
    wire [2:0] funct3 = instrD[14:12];
    wire [6:0] funct7 = instrD[31:25];

    reg [13:0] control_signals;
    assign {pcselD, immselD, regwriteD, aselD, bselD, aluselD, memrwD, wbselD} = control_signals;

    always @(funct3, funct7, opcode/*, breq, brlt*/) begin
        control_signals = 14'b0_000_0_0_0_000_0_00;
        case (opcode)
            7'b0110011: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            control_signals = 14'b0_000_1_0_0_000_0_01; // add
                        else
                            control_signals = 14'b0_000_1_0_0_001_0_01; // sub
                    end
                    3'b111: control_signals = 14'b0_000_1_0_0_010_0_01; // and
                    3'b110: control_signals = 14'b0_000_1_0_0_011_0_01; // or
                    3'b100: control_signals = 14'b0_000_1_0_0_100_0_01; // xor
                    default:control_signals = 14'b0_000_1_0_0_000_0_01;
                endcase
            end

            7'b0010011: control_signals = 14'b0_001_1_0_1_000_0_01; // addi
            7'b0000011: control_signals = 14'b0_001_1_0_1_000_0_00; // lw
            7'b1100111: control_signals = 14'b1_001_1_0_1_000_0_11; // jalr
            7'b0100011: control_signals = 14'b0_010_0_0_1_000_1_00; // sw

            // 7'b1100011: begin
            //     case (funct3)
            //         3'b000: control_signals =  (breq)  ? 14'b1_011_0_0_1_1_000_0_00
            //                                  : 14'b0_011_0_0_1_1_000_0_00; // beq
            //         3'b001: control_signals = (!breq)  ? 14'b1_011_0_0_1_1_000_0_00
            //                                  : 14'b0_011_0_0_1_1_000_0_00; // bne
            //         3'b100: control_signals =  (brlt)  ? 14'b1_011_0_0_1_1_000_0_00
            //                                  : 14'b0_011_0_0_1_1_000_0_00; // blt
            //         3'b101: control_signals = (!brlt)  ? 14'b1_011_0_0_1_1_000_0_00
            //                                  : 14'b0_011_0_0_1_1_000_0_00; // bge
            //         default:control_signals = 14'b0_000_0_0_0_0_000_0_00;
            //     endcase
            // end

            7'b1101111: control_signals = 14'b1_100_1_1_1_000_0_11; // jal
            default:    control_signals = 14'b0_000_0_0_0_000_0_00;
        endcase
    end

    // Register File
    reg [31:0] reg_file [0:31];
    reg [31:0] imm_exD;
    wire [31:0] rd1D, rd2D;

    localparam  I_type = 3'b001,
                S_type = 3'b010,
                B_type = 3'b011,
                J_type = 3'b100,
                U_type = 3'b101;

    // Imm for each instruction type
    always @(immselD, instrD) begin
        imm_exD = 32'b0;
        case (immselD)
            I_type: imm_exD = {{20{instrD[31]}}, instrD[31:20]};
            S_type: imm_exD = {{20{instrD[31]}}, instrD[31:25], instrD[11:7]};
            B_type: imm_exD = {{19{instrD[31]}}, instrD[31], instrD[7], instrD[30:25], instrD[11:8], 1'b0};
            J_type: imm_exD = {{11{instrD[31]}}, instrD[31], instrD[19:12], instrD[20], instrD[30:21], 1'b0};
            U_type: imm_exD = {instrD[31:12], 12'b0};
            default: imm_exD = 32'b0;
        endcase
    end

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'b0;
        end else begin
            if (regwriteW && (rdW != 5'd0)) begin
                reg_file[rdW] <= resultW;
            end
        end
    end

    assign rd1D = reg_file[instrD[19:15]];
    assign rd2D = reg_file[instrD[24:20]];

    assign rs1D = instrD[19:15];
    assign rs2D = instrD[24:20];
    assign rdD = instrD[11:7];

    // Register Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            regwriteD_reg <= 1'b0;
            memrwD_reg <= 1'b0; 
            aselD_reg <= 1'b0;
            bselD_reg <= 1'b0;
            wbselD_reg <= 2'b0;
            aluselD_reg <= 3'b0;
            pcD_reg <= 32'b0;
            pc4D_reg <= 32'b0;
            rd1D_reg <= 32'b0;
            rd2D_reg <= 32'b0;
            imm_exD_reg <= 32'b0;
            rdD_reg <= 5'b0;
            rs1D_reg <= 5'b0;
            rs2D_reg <= 5'b0;
        end
        else begin
            regwriteD_reg <= regwriteD;
            memrwD_reg <= memrwD; 
            aselD_reg <= aselD;
            bselD_reg <= bselD;
            wbselD_reg <= wbselD;
            aluselD_reg <= aluselD;
            pcD_reg <= pcD;
            pc4D_reg <= pc4D;
            rd1D_reg <= rd1D;
            rd2D_reg <= rd2D; 
            imm_exD_reg <= imm_exD;
            rdD_reg <= rdD;
            rs1D_reg <= rs1D;
            rs2D_reg <= rs2D;
        end
    end

    assign regwriteE = regwriteD_reg;
    assign memrwE = memrwD_reg;
    assign aselE = aselD_reg;
    assign bselE = bselD_reg;
    assign wbselE = wbselD_reg;
    assign aluselE = aluselD_reg;
    assign pcE = pcD_reg;
    assign pc4E = pc4D_reg;
    assign rd1E = rd1D_reg;
    assign rd2E = rd2D_reg;
    assign imm_exE = imm_exD_reg;
    assign rdE = rdD_reg;
    assign rs1E = rs1D_reg;
    assign rs2E = rs2D_reg;

endmodule
