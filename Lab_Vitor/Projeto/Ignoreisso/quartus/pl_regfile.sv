// =============================================================================
// pl_regfile.sv
// Banco de Registradores 32 x 32 bits -- RV32I pipelined
//
// Leitura  : assincrona (combinatorial) -- usada no estagio ID
// Escrita  : sincrona no POSEDGE do clock, proveniente do estagio WB
// x0       : hardwired a zero (escrita ignorada silenciosamente)
//
// Write-through nas leituras resolve o conflito WB/ID no mesmo ciclo sem
// inferir uma memoria acionada nas bordas positiva e negativa do clock.
// =============================================================================

`timescale 1ns / 1ps

module pl_regfile (
    input  logic        clk,
    input  logic        RegWrite,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] WriteData,
    output logic [31:0] ReadData1,
    output logic [31:0] ReadData2
);

    logic [31:0] rf [31:0];

    always_ff @(posedge clk) begin
        if (RegWrite && rd != 5'b0)
            rf[rd] <= WriteData;
    end

    assign ReadData1 = (rs1 == 5'b0) ? 32'b0 :
                       (RegWrite && (rd == rs1)) ? WriteData : rf[rs1];
    assign ReadData2 = (rs2 == 5'b0) ? 32'b0 :
                       (RegWrite && (rd == rs2)) ? WriteData : rf[rs2];

endmodule
