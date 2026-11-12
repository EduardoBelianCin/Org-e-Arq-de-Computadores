// =============================================================================
// pl_dmem.sv
// Memoria de dados -- RV32I pipelined
//
// Capacidade : 256 palavras x 32 bits = 1 KB
// Init file  : data.mif   (sintese Quartus)
//              data.hex   (simulacao ModelSim via $readmemh)
//
// Leitura  : assincrona (combinatorial) -- disponivel no estagio MEM
// Escrita  : sincrona (posedge clk, gated por MemWrite & ~mmio_sel)
// Endereco : alu_result[9:2] (palavra) + alu_result[1:0] (byte dentro da palavra)
// Stores SB/SH/SW escrevem somente os bytes selecionados; halfwords devem estar
// alinhados. Loads usam a palavra bruta e a extensao por funct3 no datapath.
// =============================================================================

`timescale 1ns / 1ps

module pl_dmem (
    input  logic        clk,
    input  logic        MemWrite,
    input  logic [7:0]  addr,
    input  logic [1:0]  byte_offset,
    input  logic [2:0]  funct3,
    input  logic [31:0] WriteData,
    output logic [31:0] ReadData
);

    (* ram_init_file = "data.mif" *) logic [31:0] ram [0:255];

    // synthesis translate_off
    initial begin
        for (int i = 0; i < 256; i++) ram[i] = 32'h00000000;
        $readmemh("data.hex", ram);
    end
    // synthesis translate_on

    always_ff @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: ram[addr][byte_offset*8 +: 8] <= WriteData[7:0]; // SB
                3'b001: if (byte_offset[0] == 1'b0)
                            ram[addr][byte_offset*8 +: 16] <= WriteData[15:0]; // SH
                3'b010: ram[addr] <= WriteData; // SW
                default: ;
            endcase
        end
    end

    assign ReadData = ram[addr];

endmodule
