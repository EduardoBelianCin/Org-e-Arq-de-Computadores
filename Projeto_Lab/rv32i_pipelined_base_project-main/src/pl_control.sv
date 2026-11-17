// =============================================================================
// pl_control.sv
// Unidade de Controle Principal -- RV32I pipelined (P&H secao 4.4)
//
// Decodifica o opcode de 7 bits (estagio ID) e gera os sinais de controle
// que serao propagados pelos registradores de pipeline.
//
// Instrucoes suportadas:
//   R-type  (0110011): operacoes entre registradores
//   I-type  (0010011): operacoes com imediato
//   I-type  (0000011): lw
//   S-type  (0100011): sw
//   B-type  (1100011): beq
//   U-type  (0110111): lui
//   U-type  (0010111): auipc
//
// Para operacoes com imediato, ALUSrc seleciona ImmExt como segundo operando.
// AUIPC tambem ativa ALUSrcA_PC para selecionar o PC como primeiro operando.
// =============================================================================

`timescale 1ns / 1ps

module pl_control (
    input  logic [6:0] Opcode,
    output logic       ALUSrc,
    output logic       ALUSrcA_PC,
    output logic       MemtoReg,
    output logic       RegWrite,
    output logic       MemRead,
    output logic       MemWrite,
    output logic       Branch,
    output logic [2:0] ALUOp
);

    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011;
    localparam LOAD   = 7'b0000011;
    localparam STORE  = 7'b0100011;
    localparam BRANCH = 7'b1100011;
    localparam LUI    = 7'b0110111;
    localparam AUIPC  = 7'b0010111;

    always_comb begin
        ALUSrc   = 1'b0;
        ALUSrcA_PC = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 3'b000;

        case (Opcode)
            R_TYPE: begin
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 3'b010;
            end
            I_TYPE: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 3'b011;
            end
            LOAD: begin
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUOp    = 3'b000;
            end
            STORE: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 3'b000;
            end
            BRANCH: begin
                Branch   = 1'b1;
                ALUOp    = 3'b001;
            end
            LUI: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 3'b100;
            end
            AUIPC: begin
                ALUSrc     = 1'b1;
                ALUSrcA_PC = 1'b1;
                RegWrite   = 1'b1;
                ALUOp      = 3'b101;
            end
            default: ; // sinais permanecem em zero (seguro)
        endcase
    end

endmodule
