// ALU operation decoder for RV32I R-type and Etapa 02 instructions.

`timescale 1ns / 1ps

module pl_alu_ctrl (
    input  logic [1:0] ALUOp,
    input  logic [6:0] Funct7,
    input  logic [2:0] Funct3,
    output logic [3:0] Operation
);

    always_comb begin
        case (ALUOp)
            2'b00: Operation = 4'd01; // Loads, stores, LUI and AUIPC use ADD
            2'b01: Operation = 4'd02; // BEQ uses SUB

            2'b10, 2'b11: begin
                case (Funct3)
                    3'h0: Operation = (ALUOp == 2'b10 && Funct7[5]) ? 4'd02 : 4'd01;
                    3'h1: Operation = 4'd07; // SLL / SLLI
                    3'h2: Operation = 4'd11; // SLT / SLTI
                    3'h3: Operation = 4'd12; // SLTU
                    3'h4: Operation = 4'd06; // XOR / XORI
                    3'h5: Operation = Funct7[5] ? 4'd09 : 4'd08; // SRA(I) / SRL(I)
                    3'h6: Operation = 4'd04; // OR / ORI
                    3'h7: Operation = 4'd05; // AND / ANDI
                    default: Operation = 4'd01;
                endcase
            end

            default: Operation = 4'd01;
        endcase
    end

endmodule
