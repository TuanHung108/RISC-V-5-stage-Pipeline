module hazard_unit( 
    input [4:0] rs1E, rs2E,
    input [4:0] rs1D, rs2D,
    input [4:0] rdM, rdW, rdE,
    input regwriteM, regwriteW,
    input [1:0] wbselE,
    input pcsrcE,
    output reg flushE, // tín hiệu flushing
    output flushD,
    output reg stallF, stallD, // tín hiệu stalling
    output reg [1:0] forwardAE, forwardBE // tín hiệu forwarding
);
    // Forwarding Control
    always @(regwriteM, regwriteW, rs1E, rdM, rdW) begin
        if(regwriteM && (rs1E==rdM) && rdM!=0) begin
            forwardAE = 2'b10;
        end else if(regwriteW && (rs1E==rdW) && rdW!=0) begin
            forwardAE = 2'b01;
        end else begin
            forwardAE = 2'b00;
        end
    end

    always @(regwriteM, regwriteW, rs2E, rdM, rdW) begin
        if(regwriteM && (rs2E == rdM) && rdM != 0) begin
            forwardBE = 2'b10;
        end else if(regwriteW && (rs2E == rdW) && rdW != 0) begin
            forwardBE = 2'b01;
        end else begin
            forwardBE = 2'b00;
        end
    end

    // Stalling Control
    wire lwstall;
    assign lwstall = (wbselE == 2'b00) &&    // lệnh ở EX là load
          (rdE != 0) &&               // thanh ghi đích không phải x0
          ((rs1D == rdE) || (rs2D == rdE)); // lệnh sau cần rdE
    assign stallD = lwstall;
    assign stallF = lwstall;

    // Flushing Control
    assign flushD = pcsrcE;
    assign flushE = lwstall | pcsrcE;
    
endmodule