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
//            suporta SB, SH e SW; acessos desalinhados nao sao suportados
// Endereco : word_addr seleciona a palavra; byte_addr seleciona byte/halfword
// =============================================================================

`timescale 1ns / 1ps

module pl_dmem (
    input  logic        clk,
    input  logic        MemWrite,
    input  logic [7:0]  word_addr,
    input  logic [1:0]  byte_addr,
    input  logic [2:0]  Funct3,
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

    always@(posedge clk) begin
        if (MemWrite) begin
            case (Funct3)
                3'b000: begin  // SB
                    case (byte_addr)
                        2'b00: ram[word_addr][7:0]   <= WriteData[7:0];
                        2'b01: ram[word_addr][15:8]  <= WriteData[7:0];
                        2'b10: ram[word_addr][23:16] <= WriteData[7:0];
                        2'b11: ram[word_addr][31:24] <= WriteData[7:0];
                    endcase
                end
                3'b001: begin  // SH
                    if (byte_addr[1]) ram[word_addr][31:16] <= WriteData[15:0];
                    else              ram[word_addr][15:0]  <= WriteData[15:0];
                end
                3'b010: ram[word_addr] <= WriteData;  // SW
                default: ;
            endcase
        end
    end

    assign ReadData = ram[word_addr];

endmodule
