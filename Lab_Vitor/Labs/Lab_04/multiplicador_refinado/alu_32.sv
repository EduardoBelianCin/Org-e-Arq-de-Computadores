// alu_32.sv
// ALU de 32 bits para a unidade de multiplicacao
// Baseado na Figura 3.3 - Patterson & Hennessy, Computer Organization and Design
//
// Para o algoritmo de multiplicacao, apenas a operacao de soma e necessaria.

module alu_32 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] sum
);
    assign sum = a + b;

endmodule