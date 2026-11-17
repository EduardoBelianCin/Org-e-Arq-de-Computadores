// =============================================================================
// pl_alu_ctrl.sv
// Unidade de Controle da ALU -- RV32I pipelined (P&H secao 4.4)
//
// Entradas (do estagio EX -- registrador ID/EX):
//   ALUOp[2:0] : codigo do controlador principal
//     3'b000 : Load/Store  -> forcar ADD
//     3'b001 : Branch BEQ  -> forcar SUB
//     3'b010 : R-type      -> decodificar via Funct3/Funct7
//     3'b011 : I-type      -> decodificar via Funct3/Funct7
//     3'b100 : LUI         -> copiar imediato
//     3'b101 : AUIPC       -> somar PC e imediato
//   Funct7[6:0], Funct3[2:0] : campos da instrucao
//
// Saida Operation[3:0] -> pl_alu.sv:
//   4'd01 ADD  4'd02 SUB  4'd04 OR   4'd05 AND  4'd06 XOR
//   4'd07 SLL  4'd08 SRL  4'd09 SRA  4'd10 COPY_B
//   4'd11 SLT  4'd12 SLTU
// =============================================================================

`timescale 1ns / 1ps

module pl_alu_ctrl (
    input  logic [2:0] ALUOp,
    input  logic [6:0] Funct7,
    input  logic [2:0] Funct3,
    output logic [3:0] Operation
);

    always_comb begin
        case (ALUOp)
            3'b000: Operation = 4'd01;  // Load / Store -> ADD

            3'b001: Operation = 4'd02;  // Branch BEQ   -> SUB

            3'b010: begin               // R-type: decodificar Funct
                case (Funct3)
                    3'h0: Operation = Funct7[5] ? 4'd02 : 4'd01; // SUB ou ADD
                    3'h1: Operation = 4'd07;  // SLL
                    3'h6: Operation = 4'd04;  // OR
                    3'h7: Operation = 4'd05;  // AND
                    3'h2: Operation = 4'd11;  // SLT
                    3'h3: Operation = 4'd12;  // SLTU
                    3'h4: Operation = 4'd06;  // XOR
                    3'h5: Operation = Funct7[5] ? 4'd09 : 4'd08; // SRA ou SRL
                    default: Operation = 4'd01;
                endcase
            end

            3'b011: begin                // I-type: decodificar Funct
                case (Funct3)
                    3'h0: Operation = 4'd01;  // ADDI
                    3'h1: Operation = 4'd07;  // SLLI
                    3'h2: Operation = 4'd11;  // SLTI
                    3'h4: Operation = 4'd06;  // XORI
                    3'h5: Operation = Funct7[5] ? 4'd09 : 4'd08; // SRAI ou SRLI
                    3'h6: Operation = 4'd04;  // ORI
                    3'h7: Operation = 4'd05;  // ANDI
                    default: Operation = 4'd01;
                endcase
            end

            3'b100: Operation = 4'd10;  // LUI: resultado = imediato
            3'b101: Operation = 4'd01;  // AUIPC: resultado = PC + imediato

            default: Operation = 4'd01;
        endcase
    end

endmodule
